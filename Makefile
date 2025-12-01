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

.DEFAULT_GOAL := help

help:
	@echo "Docker Services:"
	@echo "  up         - Start services (use: make up [service...] or make up MODE=prod ARGS=\"--build\")"
	@echo "  down       - Stop services (use: make down [service...] or make down MODE=prod ARGS=\"--volumes\")"
	@echo "  build      - Build containers (use: make build [service...] or make build MODE=prod)"
	@echo "  logs       - View logs (use: make logs SERVICE=backend or make logs SERVICE=backend MODE=prod)"
	@echo "  restart    - Restart services (use: make restart [service...] or make restart MODE=prod)"
	@echo "  shell      - Open shell in container (use: make shell SERVICE=gateway MODE=prod, default: backend)"
	@echo "  ps         - Show running containers (use: make ps MODE=prod)"
	@echo ""
	@echo "Development Aliases:"
	@echo "  dev-up       - Start development environment"
	@echo "  dev-down     - Stop development environment"
	@echo "  dev-build    - Build development containers"
	@echo "  dev-logs     - View development logs"
	@echo "  dev-restart  - Restart development services"
	@echo "  dev-shell    - Open shell in backend container"
	@echo "  dev-ps       - Show running development containers"
	@echo "  backend-shell - Open shell in backend container"
	@echo "  gateway-shell - Open shell in gateway container"
	@echo "  mongo-shell   - Open MongoDB shell"
	@echo ""
	@echo "Production Aliases:"
	@echo "  prod-up      - Start production environment"
	@echo "  prod-down    - Stop production environment"
	@echo "  prod-build   - Build production containers"
	@echo "  prod-logs    - View production logs"
	@echo "  prod-restart - Restart production services"
	@echo ""
	@echo "Backend:"
	@echo "  backend-build      - Build backend TypeScript"
	@echo "  backend-install    - Install backend dependencies"
	@echo "  backend-type-check - Type check backend code"
	@echo "  backend-dev        - Run backend in development mode (local, not Docker)"
	@echo ""
	@echo "Database:"
	@echo "  db-reset   - Reset MongoDB database (WARNING: deletes all data)"
	@echo "  db-backup  - Backup MongoDB database"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean         - Remove containers and networks (both dev and prod)"
	@echo "  clean-all     - Remove containers, networks, volumes, and images"
	@echo "  clean-volumes - Remove all volumes"
	@echo ""
	@echo "Utilities:"
	@echo "  status - Alias for ps"
	@echo "  health - Check service health"
	@echo ""
	@echo "Help:"
	@echo "  help   - Display this help message"

# Core Docker Commands
up:
	@echo "Starting services in $(MODE) mode..."
	$(DOCKER_COMPOSE) up -d $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

down:
	@echo "Stopping services in $(MODE) mode..."
	$(DOCKER_COMPOSE) down $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

build:
	@echo "Building containers in $(MODE) mode..."
	$(DOCKER_COMPOSE) build $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

logs:
	@echo "Viewing logs for $(SERVICE) in $(MODE) mode..."
	$(DOCKER_COMPOSE) logs -f $(ARGS) $(SERVICE)

restart:
	@echo "Restarting services in $(MODE) mode..."
	$(DOCKER_COMPOSE) restart $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

shell:
	@echo "Opening shell in $(SERVICE) container ($(MODE) mode)..."
	$(DOCKER_COMPOSE) exec $(SERVICE) sh

ps:
	@echo "Container status in $(MODE) mode:"
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
	@echo "Opening MongoDB shell..."
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) exec mongo sh -c 'mongosh -u $$MONGO_INITDB_ROOT_USERNAME -p $$MONGO_INITDB_ROOT_PASSWORD'

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
	@echo "Building backend TypeScript..."
	@cd backend && npm run build

backend-install:
	@echo "Installing backend dependencies..."
	@cd backend && npm install

backend-type-check:
	@echo "Type checking backend code..."
	@cd backend && npm run type-check

backend-dev:
	@echo "Starting backend in development mode (local)..."
	@cd backend && npm run dev

# Database Commands
db-reset:
	@echo "WARNING: This will delete all data in the database!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo "Resetting MongoDB database..."
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) exec mongo sh -c 'mongosh -u $$MONGO_INITDB_ROOT_USERNAME -p $$MONGO_INITDB_ROOT_PASSWORD --eval "db.getSiblingDB(\"$$MONGO_DATABASE\").dropDatabase()"'
	@echo "Database reset complete."

db-backup:
	@echo "Backing up MongoDB database..."
	@mkdir -p backups
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) exec -T mongo sh -c 'mongodump \
		--username=$$MONGO_INITDB_ROOT_USERNAME \
		--password=$$MONGO_INITDB_ROOT_PASSWORD \
		--authenticationDatabase=admin \
		--db=$$MONGO_DATABASE \
		--archive' > backups/mongo-backup-$$(date +%Y%m%d-%H%M%S).archive
	@echo "Backup complete. Saved to backups/"

# Cleanup Commands
clean:
	@echo "Cleaning up containers and networks..."
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) down --remove-orphans 2>/dev/null || true
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_PROD) down --remove-orphans 2>/dev/null || true
	@echo "Cleanup complete."

clean-all:
	@echo "WARNING: This will remove all containers, networks, volumes, and images!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo "Removing all containers, networks, volumes, and images..."
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) down --volumes --rmi all --remove-orphans 2>/dev/null || true
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_PROD) down --volumes --rmi all --remove-orphans 2>/dev/null || true
	@echo "Complete cleanup done."

clean-volumes:
	@echo "WARNING: This will remove all volumes and delete all data!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	@echo "Removing all volumes..."
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_DEV) down --volumes 2>/dev/null || true
	@docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE_PROD) down --volumes 2>/dev/null || true
	@echo "Volumes removed."

# Utility Commands
health:
	@echo "Checking service health..."
	@echo ""
	@echo "Gateway Health:"
	@curl -s http://localhost:5921/health && echo "" || echo "Gateway not responding"
	@echo ""
	@echo "Backend Health (via Gateway):"
	@curl -s http://localhost:5921/api/health && echo "" || echo "Backend not responding"
	@echo ""
	@echo "Security Check (Backend direct access should fail):"
	@curl -s http://localhost:3847/api/health 2>&1 && echo "WARNING: Backend is accessible directly!" || echo "✓ Backend is properly isolated"

# Allow passing service names as arguments
%:
	@:
