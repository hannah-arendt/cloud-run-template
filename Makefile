PROJECT_ID ?= my-project
REGION ?= my-region
IMAGE := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/my-project/my-project:latest
DATA_BUCKET := $(PROJECT_ID)-data
DATA_BACKUP_DIR := tmp/data

.PHONY: all update init set-project build push deploy force-deploy backup-data restore-data enable-services tf-init

all: set-project build push deploy

update: set-project build push force-deploy deploy

init: set-project enable-services tf-init deploy

set-project:
	gcloud auth application-default set-quota-project $(PROJECT_ID)
	gcloud config set project $(PROJECT_ID)

build:
	venv/bin/pip freeze > requirements.txt
	docker buildx build --platform=linux/amd64 -t my-project . --load

push:
	docker tag my-project $(IMAGE)
	docker push $(IMAGE)

deploy:
	cd infra && terraform apply -auto-approve

force-deploy:
	cd infra && terraform apply -replace=google_cloud_run_v2_service.my-project -auto-approve

backup-data:
	mkdir -p $(DATA_BACKUP_DIR)
	gsutil -m cp -r gs://$(DATA_BUCKET)/* $(DATA_BACKUP_DIR)/

restore-data:
	@read -p "Are you sure you want to restore data? This will overwrite data in the bucket. (y/n) " choice; \
	if [ "$$choice" != "y" ]; then \
		echo "Operation cancelled"; \
		exit 1; \
	fi
	gsutil -m cp -r $(DATA_BACKUP_DIR)/* $(DATA_BUCKET)/

enable-services:
	gcloud services enable run.googleapis.com
	gcloud services enable artifactregistry.googleapis.com
	gcloud services enable vpcaccess.googleapis.com
	gcloud services enable compute.googleapis.com
	gcloud services enable secretmanager.googleapis.com

tf-init:
	cd infra && terraform init -upgrade

