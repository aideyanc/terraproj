terraform:
	terraform init
	terraform plan
	terraform apply -auto-approve

cleanup:
	terraform fmt
	terraform validate

destroy:
	terraform destroy -auto-approve