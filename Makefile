.PHONY: help up down build logs restart shell ps status health clean clean-all clean-volumes \
        dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps \
        prod-up prod-down prod-build prod-logs prod-restart prod-shell prod-ps \
        backend-shell gateway-shell mongo-shell backend-build backend-install backend-type-check backend-dev \
        db-reset db-backup

# Variables
MODE ?= dev
COMPOSE_FILE_DEV = docker/compose.development.yaml
COMPOSE_FILE_PROD = docker/compose.production.yaml
COMPOSE_FILE = $(if $(filter prod,$(MODE)),$(COMPOSE_FILE_PROD),$(COMPOSE_FILE_DEV))
ENV_FILE = .env
DOCKER_COMPOSE = docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)
SERVICE ?= backend
ARGS ?=

# Colors
COLOR_RESET = \033[0m
COLOR_BOLD = \033[1m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_BLUE = \033[34m

.DEFAULT_GOAL := help

help:
	@echo "$(COLOR_BOLD)Docker Services:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)up$(COLOR_RESET)         - Start services (use: make up [service...] or make up MODE=prod ARGS=\"--build\")"
	@echo "  $(COLOR_GREEN)down$(COLOR_RESET)       - Stop services (use: make down [service...] or make down MODE=prod ARGS=\"--volumes\")"
	@echo "  $(COLOR_GREEN)build$(COLOR_RESET)      - Build containers (use: make build [service...] or make build MODE=prod)"
	@echo "  $(COLOR_GREEN)logs$(COLOR_RESET)       - View logs (use: make logs SERVICE=backend or make logs SERVICE=backend MODE=prod)"
	@echo "  $(COLOR_GREEN)restart$(COLOR_RESET)    - Restart services (use: make restart [service...] or make restart MODE=prod)"
	@echo "  $(COLOR_GREEN)shell$(COLOR_RESET)      - Open shell in container (use: make shell SERVICE=gateway MODE=prod, default: backend)"
	@echo "  $(COLOR_GREEN)ps$(COLOR_RESET)         - Show running containers (use: make ps MODE=prod)"
	@echo ""
	@echo "$(COLOR_BOLD)Development Aliases:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)dev-up$(COLOR_RESET)       - Start development environment"
	@echo "  $(COLOR_GREEN)dev-down$(COLOR_RESET)     - Stop development environment"
	@echo "  $(COLOR_GREEN)dev-build$(COLOR_RESET)    - Build development containers"
	@echo "  $(COLOR_GREEN)dev-logs$(COLOR_RESET)     - View development logs"
	@echo "  $(COLOR_GREEN)dev-restart$(COLOR_RESET)  - Restart development services"
	@echo "  $(COLOR_GREEN)dev-shell$(COLOR_RESET)    - Open shell in backend container"
	@echo "  $(COLOR_GREEN)dev-ps$(COLOR_RESET)       - Show running development containers"
	@echo "  $(COLOR_GREEN)backend-shell$(COLOR_RESET) - Open shell in backend container"
	@echo "  $(COLOR_GREEN)gateway-shell$(COLOR_RESET) - Open shell in gateway container"
	@echo "  $(COLOR_GREEN)mongo-shell$(COLOR_RESET)   - Open MongoDB shell"
	@echo ""
	@echo "$(COLOR_BOLD)Production Aliases:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)prod-up$(COLOR_RESET)      - Start production environment"
	@echo "  $(COLOR_GREEN)prod-down$(COLOR_RESET)    - Stop production environment"
	@echo "  $(COLOR_GREEN)prod-build$(COLOR_RESET)   - Build production containers"
	@echo "  $(COLOR_GREEN)prod-logs$(COLOR_RESET)    - View production logs"
	@echo "  $(COLOR_GREEN)prod-restart$(COLOR_RESET) - Restart production services"
	@echo ""
	@echo "$(COLOR_BOLD)Backend:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)backend-build$(COLOR_RESET)      - Build backend TypeScript"
	@echo "  $(COLOR_GREEN)backend-install$(COLOR_RESET)    - Install backend dependencies"
	@echo "  $(COLOR_GREEN)backend-type-check$(COLOR_RESET) - Type check backend code"
	@echo "  $(COLOR_GREEN)backend-dev$(COLOR_RESET)        - Run backend in development mode (local, not Docker)"
	@echo ""
	@echo "$(COLOR_BOLD)Database:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)db-reset$(COLOR_RESET)   - Reset MongoDB database (WARNING: deletes all data)"
	@echo "  $(COLOR_GREEN)db-backup$(COLOR_RESET)  - Backup MongoDB database"
	@echo ""
	@echo "$(COLOR_BOLD)Cleanup:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)clean$(COLOR_RESET)         - Remove containers and networks (both dev and prod)"
	@echo "  $(COLOR_GREEN)clean-all$(COLOR_RESET)     - Remove containers, networks, volumes, and images"
	@echo "  $(COLOR_GREEN)clean-volumes$(COLOR_RESET) - Remove all volumes"
	@echo ""
	@echo "$(COLOR_BOLD)Utilities:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)status$(COLOR_RESET) - Alias for ps"
	@echo "  $(COLOR_GREEN)health$(COLOR_RESET) - Check service health"
	@echo ""
	@echo "$(COLOR_BOLD)Help:$(COLOR_RESET)"
	@echo "  $(COLOR_GREEN)help$(COLOR_RESET)   - Display this help message"

# Core Docker Commands
up:
	@echo "$(COLOR_BLUE)Starting services in $(MODE) mode...$(COLOR_RESET)"
	$(DOCKER_COMPOSE) up -d $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

down:
	@echo "$(COLOR_BLUE)Stopping services in $(MODE) mode...$(COLOR_RESET)"
	$(DOCKER_COMPOSE) down $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

build:
	@echo "$(COLOR_BLUE)Building containers in $(MODE) mode...$(COLOR_RESET)"
	$(DOCKER_COMPOSE) build $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

logs:
	@echo "$(COLOR_BLUE)Viewing logs for $(SERVICE) in $(MODE) mode...$(COLOR_RESET)"
	$(DOCKER_COMPOSE) logs -f $(ARGS) $(SERVICE)

restart:
	@echo "$(COLOR_BLUE)Restarting services in $(MODE) mode...$(COLOR_RESET)"
	$(DOCKER_COMPOSE) restart $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

shell:
	@echo "$(COLOR_BLUE)Opening shell in $(SERVICE) container ($(MODE) mode)...$(COLOR_RESET)"
	$(DOCKER_COMPOSE) exec $(SERVICE) sh

ps:
	@echo "$(COLOR_BLUE)Container status in $(MODE) mode:$(COLOR_RESET)"
	$(DOCKER_COMPOSE) ps $(ARGS)

status: ps

# Development Aliases
dev-up:
	@$(MAKE) up MODE=dev

dev-down:
	@$(MAKE) down MODE=dev

dev-build:
	@$(MAKE) build MODE=dev

dev-logs:
	@$(MAKE) logs MODE=dev

dev-restart:
	@$(MAKE) restart MODE=dev

dev-shell:
	@$(MAKE) shell MODE=dev SERVICE=backend

dev-ps:
	@$(MAKE) ps MODE=dev

backend-shell:
	@$(MAKE) shell SERVICE=backend

gateway-shell:
	@$(MAKE) shell SERVICE=gateway

mongo-shell:
	@echo "$(COLOR_BLUE)Opening MongoDB shell...$(COLOR_RESET)"
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) exec mongo mongosh -u $${MONGO_INITDB_ROOT_USERNAME} -p $${MONGO_INITDB_ROOT_PASSWORD}

# Production Aliases
prod-up:
	@$(MAKE) up MODE=prod

prod-down:
	@$(MAKE) down MODE=prod

prod-build:
	@$(MAKE) build MODE=prod

prod-logs:
	@$(MAKE) logs MODE=prod

prod-restart:
	@$(MAKE) restart MODE=prod

prod-shell:
	@$(MAKE) shell MODE=prod

prod-ps:
	@$(MAKE) ps MODE=prod

# Backend Local Commands
backend-build:
	@echo "$(COLOR_BLUE)Building backend TypeScript...$(COLOR_RESET)"
	@cd backend && npm run build

backend-install:
	@echo "$(COLOR_BLUE)Installing backend dependencies...$(COLOR_RESET)"
	@cd backend && npm install

backend-type-check:
	@echo "$(COLOR_BLUE)Type checking backend code...$(COLOR_RESET)"
	@cd backend && npm run type-check

backend-dev:
	@echo "$(COLOR_BLUE)Starting backend in development mode (local)...$(COLOR_RESET)"
	@cd backend && npm run dev

# Database Commands
db-reset:
	@echo "$(COLOR_YELLOW)WARNING: This will delete all data in the database!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Press Ctrl+C to cancel, or Enter to continue...$(COLOR_RESET)"
	@read confirm
	@echo "$(COLOR_BLUE)Resetting MongoDB database...$(COLOR_RESET)"
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) exec mongo mongosh -u $${MONGO_INITDB_ROOT_USERNAME} -p $${MONGO_INITDB_ROOT_PASSWORD} --eval "db.getSiblingDB('$${MONGO_DATABASE}').dropDatabase()"
	@echo "$(COLOR_GREEN)Database reset complete.$(COLOR_RESET)"

db-backup:
	@echo "$(COLOR_BLUE)Backing up MongoDB database...$(COLOR_RESET)"
	@mkdir -p backups
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) exec -T mongo mongodump \
		--username=$${MONGO_INITDB_ROOT_USERNAME} \
		--password=$${MONGO_INITDB_ROOT_PASSWORD} \
		--db=$${MONGO_DATABASE} \
		--archive > backups/mongo-backup-$$(date +%Y%m%d-%H%M%S).archive
	@echo "$(COLOR_GREEN)Backup complete. Saved to backups/$(COLOR_RESET)"

# Cleanup Commands
clean:
	@echo "$(COLOR_BLUE)Cleaning up containers and networks...$(COLOR_RESET)"
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) down --remove-orphans 2>/dev/null || true
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_PROD) down --remove-orphans 2>/dev/null || true
	@echo "$(COLOR_GREEN)Cleanup complete.$(COLOR_RESET)"

clean-all:
	@echo "$(COLOR_YELLOW)WARNING: This will remove all containers, networks, volumes, and images!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Press Ctrl+C to cancel, or Enter to continue...$(COLOR_RESET)"
	@read confirm
	@echo "$(COLOR_BLUE)Removing all containers, networks, volumes, and images...$(COLOR_RESET)"
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) down --volumes --rmi all --remove-orphans 2>/dev/null || true
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_PROD) down --volumes --rmi all --remove-orphans 2>/dev/null || true
	@echo "$(COLOR_GREEN)Complete cleanup done.$(COLOR_RESET)"

clean-volumes:
	@echo "$(COLOR_YELLOW)WARNING: This will remove all volumes and delete all data!$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Press Ctrl+C to cancel, or Enter to continue...$(COLOR_RESET)"
	@read confirm
	@echo "$(COLOR_BLUE)Removing all volumes...$(COLOR_RESET)"
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) down --volumes 2>/dev/null || true
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_PROD) down --volumes 2>/dev/null || true
	@echo "$(COLOR_GREEN)Volumes removed.$(COLOR_RESET)"

# Utility Commands
health:
	@echo "$(COLOR_BLUE)Checking service health...$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)Gateway Health:$(COLOR_RESET)"
	@curl -s http://localhost:5921/health && echo "" || echo "$(COLOR_YELLOW)Gateway not responding$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)Backend Health (via Gateway):$(COLOR_RESET)"
	@curl -s http://localhost:5921/api/health && echo "" || echo "$(COLOR_YELLOW)Backend not responding$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)Security Check (Backend direct access should fail):$(COLOR_RESET)"
	@curl -s http://localhost:3847/api/health 2>&1 && echo "$(COLOR_YELLOW)WARNING: Backend is accessible directly!$(COLOR_RESET)" || echo "$(COLOR_GREEN)✓ Backend is properly isolated$(COLOR_RESET)"

# Allow passing service names as arguments
%:
	@:
