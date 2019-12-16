# include kerberos-environment/terraform.tfvars
# export $(shell sed 's/=.*//' kerberos-environment/terraform.tfvars)

SETTINGS_FILE?=../settings.json


DEBUG?=false
BUILD_ARGS	:=build
export PACKER_LOG:=true
export PACKER_LOG_PATH=packer.log
export TF_LOG_PATH=terraform.log

ifeq ($(DEBUG), true)	
	BUILD_ARGS:=$(BUILD_ARGS) -debug
export TF_LOG=TRACE
endif

help: ## output this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build-server: ## building a new Kerberos AMI
	@echo "Building a new AMI"	
	cd  kerberos-server-ami && \
	cat /dev/null > $(PACKER_LOG_PATH) && \
	packer validate -var-file $(SETTINGS_FILE) template.json && \
	packer $(BUILD_ARGS) -var-file $(SETTINGS_FILE) template.json

start-server: get_hostname ## starting up the Kerberos Server
ifeq ($(AMI_ID), )
	@echo "Please provide AMI ID:\n\t $$ make start-server AMI_ID=ami-0ea1f0fbfefbe5956"
	@exit 1
endif
	@echo "Creating a new Kerberos Environment"
	cd kerberos-environment && \
	cat /dev/null > $(TF_LOG_PATH) && \
	terraform apply -var-file $(SETTINGS_FILE) \
					-var "SERVER_AMI=$(AMI_ID)" \
					-var "SERVER_HOSTNAME=$(SERVER_HOSTNAME)" \
	-target aws_route53_record.domain 

start-client: get_hostname ## starting up the Kerberos Client
	@echo "Starting up a new Client added in Kerberos environment"
	cd kerberos-environment && \
	cat /dev/null > $(TF_LOG_PATH) && \
	terraform apply -var-file $(SETTINGS_FILE) \
					-var "SERVER_HOSTNAME=$(SERVER_HOSTNAME)" \
					-target aws_instance.kerberos-client

delete-client: ## delete the client
	@echo "Deleting the Client added in Kerberos environment"
	cd kerberos-environment && \
	cat /dev/null > $(TF_LOG_PATH) && \
	terraform destroy -var-file $(SETTINGS_FILE) -target aws_instance.kerberos-client

cleanup: ## deleting existing Kerberos environment
	@echo "Deleting existing Kerberos Environment"
	cd kerberos-environment && \
	terraform destroy -var-file $(SETTINGS_FILE)

get_hostname:
	$(eval SERVER_HOSTNAME:=$(shell echo `iconv -f UTF-16 -t UTF-8 kerberos-server-ami/hostname`))
	@echo Server hostname: $(SERVER_HOSTNAME)