# Makefile
# venv: Creates a Python virtual environment in the "venv" directory if it doesn't exist.
venv:
	@if [ ! -d ".venv" ]; then \
		echo "Creating virtual environment..."; \
		python3 -m venv .venv; \
	else \
		echo "Virtual environment already exists."; \
	fi

# retrieve-secrets: Retrieves secrets by running the secrets script.
retrieve-secrets:
	@echo "Retrieving secrets..."
	@./scripts/util/retrieve_secrets.sh

# deploy: Depends on retrieve-secrets and then runs the deployment script.
deploy: venv retrieve-secrets
	@echo "Starting deployment..." && \
	. ./.venv/bin/activate && \
	. ./.env && \
	./deploy/deploy.sh

