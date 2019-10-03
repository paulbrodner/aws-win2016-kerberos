# include kerberos-environment/terraform.tfvars
# export $(shell sed 's/=.*//' kerberos-environment/terraform.tfvars)

SETTINGS_FILE?=../settings.json


DEBUG?=false
BUILD_ARGS	:=build
export PACKER_LOG:=true
export PACKER_LOG_PATH=packer.log

ifeq ($(DEBUG), true)	
	BUILD_ARGS:=$(BUILD_ARGS) -debug
endif

help: ## output this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build-server: ## building a new Kerberos AMI
	@echo "Building a new AMI"
	@cat /dev/null > $(PACKER_LOG_PATH)
	cd  kerberos-server-ami && \
	packer validate -var-file $(SETTINGS_FILE) template.json && \
	packer $(BUILD_ARGS) -var-file $(SETTINGS_FILE) template.json

start-server: ## starting up the Kerberos Server
ifeq ($(AMI_ID), )
	@echo "Please provide AMI ID:\n\t $$ make start AMI_ID=ami-0ea1f0fbfefbe5956"
	@exit 1
endif
	@echo "Creating a new Kerberos Environment"
	cd kerberos-environment && \
	./generate-scripts.sh $(SETTINGS_FILE) && \
	terraform apply -var-file $(SETTINGS_FILE) -var "SERVER_AMI=$(AMI_ID)" -target aws_route53_record.domain 

start-client: ## starting up the Kerberos Client
	@echo "Starting up a new Client added in Kerberos environment"
	cd kerberos-environment && \
	./generate-scripts.sh $(SETTINGS_FILE) && \
	terraform apply -var-file $(SETTINGS_FILE) -target aws_instance.kerberos-client

cleanup: ## deleting existing Kerberos environment
	@echo "Deleting existing Kerberos Environment"
	cd kerberos-environment && \
	terraform destroy -var-file $(SETTINGS_FILE)
