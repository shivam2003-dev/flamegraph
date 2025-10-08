.PHONY: build run profile clean help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Flamegraph Profiling - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

build: ## Build the Docker image
	@echo "$(BLUE)Building Docker image...$(NC)"
	docker-compose build

run: ## Start the container in interactive mode
	@echo "$(BLUE)Starting container...$(NC)"
	docker-compose run --rm flamegraph-profiler

profile-default: ## Run default profiling (10s, 99Hz)
	@echo "$(BLUE)Running default profiling...$(NC)"
	docker-compose run --rm flamegraph-profiler ./profile.sh default

profile-quick: ## Run quick profiling (5s, 99Hz)
	@echo "$(BLUE)Running quick profiling...$(NC)"
	docker-compose run --rm flamegraph-profiler ./profile.sh quick

profile-detailed: ## Run detailed profiling (20s, 997Hz)
	@echo "$(BLUE)Running detailed profiling...$(NC)"
	docker-compose run --rm flamegraph-profiler ./profile.sh detailed

profile-system: ## Run system-wide profiling
	@echo "$(BLUE)Running system-wide profiling...$(NC)"
	docker-compose run --rm flamegraph-profiler ./profile.sh system

run-app: ## Run the application without profiling
	@echo "$(BLUE)Running application...$(NC)"
	docker-compose run --rm flamegraph-profiler python3 /app/app.py

shell: ## Open a shell in the container
	@echo "$(BLUE)Opening shell...$(NC)"
	docker-compose run --rm flamegraph-profiler /bin/bash

view-output: ## List output files
	@echo "$(BLUE)Output files:$(NC)"
	@ls -lh output/ 2>/dev/null || echo "No output files yet. Run a profiling command first."

clean: ## Clean output files and Docker resources
	@echo "$(YELLOW)Cleaning output files...$(NC)"
	rm -rf output/*
	@echo "$(YELLOW)Stopping containers...$(NC)"
	docker-compose down
	@echo "$(GREEN)Clean complete!$(NC)"

clean-all: clean ## Clean everything including Docker images
	@echo "$(YELLOW)Removing Docker images...$(NC)"
	docker-compose down --rmi all
	@echo "$(GREEN)Clean complete!$(NC)"

logs: ## Show container logs
	docker-compose logs -f
