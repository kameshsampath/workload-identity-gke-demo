SHELL := /usr/bin/env bash
# ENV_FILE := .env
# include ${ENV_FILE}
# export $(shell sed 's/=.*//' ${ENV_FILE})
CURRENT_DIR = $(shell pwd)
TFVARS_FILE ?= terraform.tfvars

help: ## Show this help
		@echo Please specify one or more build target. The choices are:
		@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(INFO_COLOR)%-30s$(NO_COLOR) %s\n", $$1, $$2}'

clean:	## Clean all terraform artifacts/assets
	rm -rf .terraform .terraform.lock.hcl

format:	##	Format terraform files
	terraform fmt --recursive $(CURRENT_DIR)

init:	## Init terraform working directory
	terraform init

plan:	format	## Create terraform plan that will be applied
	terraform plan -var-file="$(TFVARS_FILE)"

validate:	format	## Validate the terraform resources
	terraform validate

apply:	validate	## Creates the terraform resources
	terraform apply -var-file="$(TFVARS_FILE)"

destroy:	##	Destroys terraform resources
	terraform destroy -var-file="$(TFVARS_FILE)"

build:	## Build the application under app and push the image to repository $KO_DOCKER_REPO
	cd "$(PWD)/app" && ko build --bare --platform=linux/amd64 --platform=linux/arm64 --image-label=org.opencontainers.image.source=https://github.com/kameshsampath/workload-identiy-gke-demo .

readme:	## Build the README.md
	@terraform-docs $(PWD) > "$(PWD)/README.md"

.PHONY:	apply	clean	destroy	init	plan	readme	validate