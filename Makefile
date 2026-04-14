# =========================
# CONFIG (override if needed)
# =========================
APP_NAME ?= mission-status-api
APP_NAMESPACE ?= mission-status
ARGOCD_NAMESPACE ?= argocd

AWS_REGION ?= us-east-1
ACCOUNT_ID ?= 163895578832
IMAGE_TAG ?= latest

ECR_REPO ?= $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APP_NAME)

TF_ROOT ?= terraform
TF_ENV_FILE ?= environments/dev/dev.tfvars
TF_BACKEND_CONFIG ?= backend-configs/dev.hcl

BACKEND_ROOT ?= bootstrap/state-backend
STATE_BUCKET ?= mission-status-api-tfstate

LBC_RELEASE ?= aws-load-balancer-controller
LBC_NAMESPACE ?= kube-system

# =========================
# PHONY TARGETS
# =========================
.PHONY: all build push deploy infra validate helm teardown clean

# =========================
# FULL PIPELINE
# =========================
all: build push deploy

# =========================
# BUILD IMAGE
# =========================
build:
	docker build -t $(APP_NAME):$(IMAGE_TAG) .

# =========================
# PUSH IMAGE TO ECR
# =========================
push:
	aws ecr get-login-password --region $(AWS_REGION) | \
	docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	docker tag $(APP_NAME):$(IMAGE_TAG) $(ECR_REPO):$(IMAGE_TAG)
	docker push $(ECR_REPO):$(IMAGE_TAG)

# =========================
# TERRAFORM INFRA
# =========================
infra:
	terraform -chdir=$(TF_ROOT) init -backend-config=$(TF_BACKEND_CONFIG)
	terraform -chdir=$(TF_ROOT) apply -var-file=$(TF_ENV_FILE) -auto-approve

# =========================
# DEPLOY APP (HELM)
# =========================
deploy:
	helm upgrade --install $(APP_NAME) helm/$(APP_NAME) \
		-n $(APP_NAMESPACE) --create-namespace \
		--set image.repository=$(ECR_REPO) \
		--set image.tag=$(IMAGE_TAG)

# =========================
# VALIDATION
# =========================
validate:
	terraform -chdir=$(TF_ROOT) fmt -recursive
	terraform -chdir=$(TF_ROOT) validate
	helm lint helm/$(APP_NAME)

# =========================
# CLEAN LOCAL DOCKER
# =========================
clean:
	docker rmi $(APP_NAME):$(IMAGE_TAG) || true

# =========================
# TEARDOWN (FULL CLEANUP)
# =========================
teardown:
	APP_NAME=$(APP_NAME) \
	APP_NAMESPACE=$(APP_NAMESPACE) \
	ARGOCD_NAMESPACE=$(ARGOCD_NAMESPACE) \
	TF_ROOT=$(TF_ROOT) \
	TF_ENV_FILE=$(TF_ENV_FILE) \
	TF_BACKEND_CONFIG=$(TF_BACKEND_CONFIG) \
	BACKEND_ROOT=$(BACKEND_ROOT) \
	STATE_BUCKET=$(STATE_BUCKET) \
	LBC_RELEASE=$(LBC_RELEASE) \
	LBC_NAMESPACE=$(LBC_NAMESPACE) \
	./scripts/teardown.sh


# =========================
# GCP CONFIG
# =========================
GCP_PROJECT_ID ?= mission-status-api
GCP_REGION ?= us-east1
GCP_ZONE ?= us-east1-c
GKE_CLUSTER_NAME ?= mission-status-gke
GCP_ARTIFACT_REPO ?= mission-status

GCP_IMAGE_REPO ?= $(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT_ID)/$(GCP_ARTIFACT_REPO)/mission-status-api
GCP_IMAGE_TAG ?= latest

GCP_TF_ROOT ?= gcp/terraform

.PHONY: gcp-infra gcp-connect gcp-build gcp-push gcp-deploy gcp-ingress gcp-validate gcp-teardown gcp-all

gcp-validate:
	terraform -chdir=$(GCP_TF_ROOT) fmt -recursive
	terraform -chdir=$(GCP_TF_ROOT) validate
	helm lint helm/mission-status-api

gcp-infra:
	terraform -chdir=$(GCP_TF_ROOT) init
	terraform -chdir=$(GCP_TF_ROOT) apply -auto-approve

gcp-connect:
	gcloud container clusters get-credentials $(GKE_CLUSTER_NAME) --zone $(GCP_ZONE) --project $(GCP_PROJECT_ID)

gcp-build:
	docker build -t $(GCP_IMAGE_REPO):$(GCP_IMAGE_TAG) .

gcp-push:
	gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev --quiet
	docker push $(GCP_IMAGE_REPO):$(GCP_IMAGE_TAG)

gcp-deploy:
	helm upgrade --install mission-status-api ./helm/mission-status-api \
		-n mission-status \
		--create-namespace \
		-f helm/mission-status-api/values-gcp.yaml \
		--set image.repository=$(GCP_IMAGE_REPO) \
		--set image.tag=$(GCP_IMAGE_TAG)

gcp-ingress:
	kubectl apply -f gcp/k8s/managed-cert.yaml
	kubectl apply -f gcp/k8s/ingress-gke.yaml

gcp-teardown:
	helm uninstall mission-status-api -n mission-status || true
	kubectl delete -f gcp/k8s/ingress-gke.yaml --ignore-not-found=true
	kubectl delete -f gcp/k8s/managed-cert.yaml --ignore-not-found=true
	kubectl delete namespace mission-status --ignore-not-found=true
	terraform -chdir=$(GCP_TF_ROOT) destroy -auto-approve

gcp-all: gcp-infra gcp-connect gcp-build gcp-push gcp-deploy gcp-ingress
