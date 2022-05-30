#!/bin/bash

import std;
import bodyaccess;

include "backends.vcl";
include "whitelist.vcl";


# access control list for "purge": open to only localhost and Ampersand's office
acl purge {
    "127.0.0.1";
    "5.148.137.82"; # Ampersand's IP address
}


sub vcl_recv {

    unset req.http.X-Body-Len;

    set req.http.X-Forwarded-For = regsub(req.http.X-Forwarded-For, "^([^,]+),?.*$", "\1");

    if (req.http.X-Forwarded-Proto == "http") {
        return (synth(750, ""));
    }


    ## Blacklist anyone outside whitelist.vcl
    if (std.ip(regsub(req.http.X-Forwarded-For, "[, ].*$", ""), client.ip) !~ whitelist && req.url !~ "well-known") {
        return (synth(405, "Not allowed."));
    }

    # Allow PURGE for ips whitelisted at array in the beginning of this VCL
    if (req.method == "PURGE") {
        if (std.ip(regsub(req.http.X-Forwarded-For, "[, ].*$", ""), client.ip) !~ purge) {
            return (synth(405, "Method not allowed"));
        }
        if (!req.http.X-Magento-Tags-Pattern) {
            return (synth(400, "X-Magento-Tags-Pattern header required"));
        }
        ban("obj.http.X-Magento-Tags ~ " + req.http.X-Magento-Tags-Pattern);
        return (synth(200, "Purged"));
    }

    if (req.method != "GET" &&
        req.method != "HEAD" &&
        req.method != "PUT" &&
        req.method != "POST" &&
        req.method != "TRACE" &&
        req.method != "OPTIONS" &&
        req.method != "DELETE") {
          /* Non-RFC2616 or CONNECT which is weird. */
          return (pipe);
    }

    # We only deal with GET and HEAD by default, as well as POST but only for graphql
    if (req.method != "GET" && req.method != "HEAD" && req.method != "POST") {
        std.log("No caching, request method not cacheable: " + req.http.host + req.url);
        return (pass);
    }

    # Application urls to bypass
    if ( req.url ~ "/checkout"
       # nothing in checkout area or with paypal or braintree in the url
        || req.url ~ "/checkout"
        || req.url ~ "paypal"
        || req.url ~ "braintree"
       # nothing in account pages
        || req.url ~ "/customer"
        || req.url ~ "/sales"
        || req.url ~ "/wishlist"
        || req.url ~ "/vault"
       # nothing in the rest api
        || req.url ~ "/rest"
       # other various magento urls
        || req.url ~ "/catalogsearch"
	|| req.url ~ "o4badm"
       # ampersand custom urls
        || req.url ~ "/store-finder"
        || req.url ~ "/guest_checkout_login"
        || req.url ~ "/cookie-populator"
    ) {
        std.log("Not caching, url bypassed: " + req.http.host + req.url);
        return (pass);
    }

    # Authenticated GraphQL requests should not be cached by default
    if (req.url ~ "/graphql" && req.http.Authorization ~ "^Bearer") {
        std.log("Not caching graphQL request with Auth header for: " + req.http.host + req.url);
        return (pass);
    }

    # Only allow certain graphql queries to be cached. This is an explicit whitelist of queries to be
    # cached, so we default to not caching any.
    if (req.url ~ "/graphql"
        && req.url !~ "operationName=cmsBlocks"
        && req.url !~ "operationName=getCmsPage"
        && req.url !~ "operationName=getProductDetailForProductPage"
    ) {
        std.log("Not caching graphQL request: " + req.http.host + req.url);
        return (pass);
    } else {
        std.log("Allowing cache for graphQL request: " + req.http.host + req.url);
    }

    # No cache for no_cache=true in url or cookie
    if (req.http.Cookie ~ "^.*?no_cache=true;*.*$" || req.url ~ "no_cache=true") {
        std.log("Not caching, no_cache=true found: " + req.http.host + req.url);
        return (pass);
    }

    # normalize url in case of leading HTTP scheme and domain
    set req.url = regsub(req.url, "^http[s]?://", "");

    # if any part of the application requires authorization, pass
    if (req.http.Authorization && req.http.Authorization != "") {
        std.log("Not caching, authorization header found: " + req.http.host + req.url);
        return (pass);
    }

    ############################################
    ### Everything below here will be cached ###
    ############################################

    # collect all cookies
    std.collect(req.http.Cookie);

    # Compression filter. See https://www.varnish-cache.org/trac/wiki/FAQ/Compression
    if (req.http.Accept-Encoding) {
        if (req.url ~ "\.(jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|flv)$") {
            # No point in compressing these
            unset req.http.Accept-Encoding;
        } elsif (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate" && req.http.user-agent !~ "MSIE") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            # unkown algorithm
            unset req.http.Accept-Encoding;
        }
    }

    # Strip out query parameters that do not affect the page content
    set req.url = regsuball(req.url, "([\?|\&])+(awc|sv_source|sv_medium|sv_campaign|sv_term|utm_source|utm_medium|utm_campaign|utm_term|utm_content|gclid|gclsrc|adnetwork|affc|msclkid|dclid|istCompanyId|istItemId|istBid)=[^&\s]+", "\1");
    # Get rid of trailing & or ?
    set req.url = regsuball(req.url, "[\?|&]+$", "");
    # Replace ?&
    set req.url = regsub(req.url, "(\?\&)", "\?");

    # static files are always cacheable. remove SSL flag and cookie
    if (req.url ~ "^/(pub/)?(media|static)/.*\.(ico|css|js|jpg|jpeg|png|gif|tiff|bmp|mp3|ogg|svg|swf|woff|woff2|eot|ttf|otf)$") {
        unset req.http.Https;
        unset req.http.X-Forwarded-Proto;
    }

    # We'll want prerendered content to be cached separately for bots but ignore any assets.
    # Full list of bots and assets obtained from here: https://github.com/prerender/prerender-node/blob/master/index.js
    if (req.url ~ "_escaped_fragment_|prerender=true|prerender=1"
        || req.http.User-Agent ~ "(?i)googlebot|Yahoo!Slurp|bingbot|yandex|baiduspider|facebookexternalhit|twitterbot|rogerbot|linkedinbot|embedly|quoralinkpreview|showyoubot|outbrain|pinterest\/0\.|developers\.google\.com\/\+\/web\/snippet|slackbot|vkShare|W3C_Validator|redditbot|Applebot|WhatsApp|flipboard|tumblr|bitlybot|SkypeUriPreview|nuzzel|Discordbot|GooglePageSpeed|Qwantify|pinterestbot|Bitrixlinkpreview|XING-contenttabreceiver|Chrome-Lighthouse"
    ) {
		set req.backend_hint = prerender;
		set req.url = "/https://" + req.http.Host + req.url;
        set req.http.X-Amp-Prerender = "crawler";
    }

    return (hash);
}

sub vcl_hash {

    if (req.http.cookie ~ "X-Magento-Vary=") {
        hash_data(regsub(req.http.cookie, "^.*?X-Magento-Vary=([^;]+);*.*$", "\1"));
    }

    # For multi site configurations to not cache each other's content
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }

    if (req.url ~ "/graphql") {
        call process_graphql_headers;
    }

    # Hash key should be different for http and https except for asset contents which should be the same
    if (req.url !~ "^/(pub/)?(media|static)/.*\.(ico|css|js|jpg|jpeg|png|gif|tiff|bmp|mp3|ogg|svg|swf|woff|woff2|eot|ttf|otf)$") {
        hash_data(std.port(server.ip));
    }

    # To make sure http users don't see ssl warning
    if (req.http.X-Forwarded-Proto) {
        hash_data(req.http.X-Forwarded-Proto);
    }

    # To cache prerendered content separately
    if (req.http.X-Amp-Prerender) {
        std.log("Prerender: hashing by req.http.X-Amp-Prerender = " + req.http.X-Amp-Prerender +", user agent is " + req.http.User-Agent);
        hash_data(req.http.X-Amp-Prerender);
    }

}


sub vcl_backend_fetch {
    # The default behavior of Varnish is to pass POST requests to the backend. When we override this in vcl_recv, Varnish will
    # still change the request method to GET before calling sub vcl_backend_fetch. We need to undo this
    if (bereq.http.X-Body-Len) {
        set bereq.method = "POST";
    }
}

sub process_graphql_headers {
    if (req.http.Store) {
        hash_data(req.http.Store);
    }
    if (req.http.Content-Currency) {
        hash_data(req.http.Content-Currency);
    }
}

sub vcl_backend_response {

    set beresp.grace = 2d;
    set beresp.keep = 2d;

    if (bereq.url ~ "\.js$" || beresp.http.content-type ~ "text") {
        set beresp.do_gzip = true;
    }

    # Default cache lifetime, will be overridden below.
    set beresp.ttl = 15m;

    if (beresp.status == 500
        || beresp.status == 501
        || beresp.status == 502
        || beresp.status == 503
        || beresp.status == 504
        || beresp.status == 404
    ) {
        # if there's any bad response, mark as hit for pass for some time to try and avoid overloading servers
        set beresp.ttl = 15s;
        set beresp.uncacheable = true;
    } elsif (beresp.http.Cache-Control ~ "private") {
        set beresp.uncacheable = true;
        set beresp.ttl = 900s;
    } elseif (beresp.status != 200) {
        set beresp.ttl = 15s;
        set beresp.uncacheable = true;
        return (deliver);
    }

    # If page is not cacheable then bypass varnish for 2 minutes as Hit-For-Pass
    if (beresp.ttl <= 0s ||
        beresp.http.Surrogate-control ~ "no-store" ||
        (!beresp.http.Surrogate-Control && beresp.http.Vary == "*")
    ) {
        # Mark as Hit-For-Pass for the next 2 minutes
        set beresp.ttl = 120s;
        set beresp.uncacheable = true;
    }

    # Go straightly to delivery if hit-for-pass is detected.
    #
    # When vcl_recv return(pass), it goes to vcl_backend_response,
    # we should not remove cookies from those cookies, since they
    # are the urls that we don't want to cache
    if (beresp.uncacheable) {
        return(deliver);
    }

    # validate if we need to cache it and prevent from setting cookie
    # images, css and js are cacheable by default so we have to remove cookie also
    if (beresp.ttl > 0s && (bereq.method == "GET" || bereq.method == "HEAD")) {
        unset beresp.http.set-cookie;
        if (bereq.url !~ "\.(ico|css|js|jpg|jpeg|png|gif|tiff|bmp|gz|tgz|bz2|tbz|mp3|ogg|svg|swf|woff|woff2|eot|ttf|otf)(\?|$)") {
            set beresp.http.Pragma = "no-cache";
            set beresp.http.Expires = "-1";
            set beresp.http.Cache-Control = "no-store, no-cache, must-revalidate, max-age=0";
        }
    }

    if (beresp.http.X-Magento-Debug) {
        set beresp.http.X-Magento-Cache-Control = beresp.http.Cache-Control;
    }

    # no cookies for cached content
    unset beresp.http.Set-Cookie;
    unset beresp.http.pragma;

    # Remove User-Agent from vary header for all cached content, we don't want to vary by it.
    if (beresp.http.Vary ~ "User-Agent") {
        set beresp.http.Vary = regsub(beresp.http.Vary, ",? *User-Agent *", "");
        set beresp.http.Vary = regsub(beresp.http.Vary, "^, *", "");
        if (beresp.http.Vary == "") {
            unset beresp.http.Vary;
        }
    }

    if (bereq.url ~ "\.(css|js|jpg|jpeg|png|gif|tiff|bmp|gz|tgz|bz2|tbz|mp3|ogg|svg|swf|ico|woff)(\?|$)") {
        # No vary for assets
        unset beresp.http.Vary;

        # Cache for 3 hours
        set beresp.ttl = 3h;

        # clients browser cache for 15m
        set beresp.http.cache-control = "public, max-age=31536000";

        # Keep and grace for 3d to ensure it's keep for longer than documents, giving them a chance to be udpated with latest assets.
        set beresp.keep = 3d;
        set beresp.grace = 3d;
    } else {
        set beresp.http.cache-control = "no-store, no-cache, must-revalidate, post-check=0, pre-check=0, max-age=1";

        set beresp.ttl = 15m;
    }

    return (deliver);
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
set req.http.X-Forwarded-For = regsub(req.http.X-Forwarded-For, "^([^,]+),?.*$", "\1");

    unset resp.http.Age;
    #unset resp.http.X-Magento-Tags;
    unset resp.http.X-Powered-By;
    unset resp.http.Server;
    unset resp.http.X-Varnish;
    #unset resp.http.Via;
    #unset resp.http.Link;
}

sub vcl_pipe {
    # Note that only the first request to the backend will have
    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
    # have it set for all requests, make sure to have:
    set bereq.http.connection = "close";
}

sub vcl_synth {

    if (resp.status == 750) {
 
     if (req.http.host ==  "online4baby-pwa.ampdev.co" ) {
       set resp.status = 301;
       set resp.http.Location = "https://" + "online4baby-pwa.ampdev.co" + req.url;
       return(deliver);
      }
    

   }

}
