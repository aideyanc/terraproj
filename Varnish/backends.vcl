backend https {
  .host = "127.0.0.1";
  .port = "3000";
  .connect_timeout = 10s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 10s;
}

backend prerender {
  .host = "127.0.0.1";
  .port = "3001";
  .connect_timeout = 60s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
}
