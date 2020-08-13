# terraform init: pull downs providers that are needed, i.e: aws.
# Also, initialize the backend - connect to S3, download tf state and store it locally.
init:
	docker-compose -f deploy/docker-compose.yml run --rm terraform init

# terraform workspace: selects correct workspace to deploy to. i.e: dev, staging, production
# common practise: terraform workplace select staging || terraform workplace new staging 
workspaces:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace list


# upon running this command, it automatically selects the workspace for you.
new_workspace:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace new dev


fmt:
	docker-compose -f deploy/docker-compose.yml run --rm terraform fmt


validate:
	docker-compose -f deploy/docker-compose.yml run --rm terraform validate


# terraform plan: output to console logs all the changes that will be made to AWS
plan:
	docker-compose -f deploy/docker-compose.yml run --rm terraform plan

apply:
	docker-compose -f deploy/docker-compose.yml run --rm terraform apply


sequence: fmt validate plan apply