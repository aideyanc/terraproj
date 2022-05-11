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