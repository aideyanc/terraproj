terraform:
	terraform init
	terraform plan
	terraform apply -auto-approve

cleanup:
	terraform fmt
	terraform validate

destroy:
	terraform destroy -auto-approve

commit:
	git status
	git add .
	git commit -m "additional code"

push:
	git status
	git add .
	git commit -m "a few modifications to security groups, variables, provider, asg, S3 and a few additions including magento and varnish instances"
	git push