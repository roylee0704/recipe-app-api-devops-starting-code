init:
	docker-compose -f deploy/docker-compose.yml run --rm terraform init


workspaces:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace list

new_workspace:
	docker-compose -f deploy/docker-compose.yml run --rm terraform workspace new dev


fmt:
	docker-compose -f deploy/docker-compose.yml run --rm terraform fmt


validate:
	docker-compose -f deploy/docker-compose.yml run --rm terraform validate

plan:
	docker-compose -f deploy/docker-compose.yml run --rm terraform plan

apply:
	docker-compose -f deploy/docker-compose.yml run --rm terraform apply


sequence: fmt validate plan apply