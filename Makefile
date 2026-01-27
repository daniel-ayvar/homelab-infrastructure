venv:
	@if [ ! -d ".venv" ]; then \
		echo "Creating virtual environment..."; \
		python3 -m venv .venv; \
	else \
		echo "Virtual environment already exists."; \
	fi

retrieve-secrets:
	@echo "Retrieving secrets..."
	@./scripts/util/retrieve_secrets.sh

setup-ssh:
	@echo "Retrieving secrets..."
	. ./.env && \
	./scripts/ci/ssh_key_setup.sh

deploy/infra: venv retrieve-secrets setup-ssh
	@echo "Starting deployment..." && \
	. ./.venv/bin/activate && \
	. ./.env && \
	./deploy/deploy.sh

deploy/workloads/reverse-proxy: venv retrieve-secrets setup-ssh
	@echo "Starting workload deployment for reverse-proxy..." && \
	. ./.venv/bin/activate && \
	. ./.env && \
	./workloads/reverse-proxy/deploy.sh

deploy/workloads/talos-k8s: venv retrieve-secrets setup-ssh
	@echo "Starting workload deployment for talos-k8s..." && \
	. ./.venv/bin/activate && \
	. ./.env && \
	./workloads/talos-k8s/deploy.sh

deploy/workloads/docker-registry: venv retrieve-secrets setup-ssh
	@echo "Starting workload deployment for docker-registry..." && \
	. ./.venv/bin/activate && \
	. ./.env && \
	./workloads/docker-registry/deploy.sh

deploy/workloads/hytale: venv retrieve-secrets setup-ssh
	@echo "Starting workload deployment for hytale..." && \
	. ./.venv/bin/activate && \
	. ./.env && \
	./workloads/hytale/deploy.sh

deploy/tunnel: venv retrieve-secrets setup-ssh
	@echo "Starting tunnel deployment..." && \
	. ./.venv/bin/activate && \
	. ./.env && \
	./deploy/tunnel.sh

build/docker/hytale:
	@./scripts/docker/build_hytale_image.sh

build/docker/hytale-multi:
	@HYTALE_PLATFORMS="linux/amd64,linux/arm64" HYTALE_PUSH=1 ./scripts/docker/build_hytale_image.sh
