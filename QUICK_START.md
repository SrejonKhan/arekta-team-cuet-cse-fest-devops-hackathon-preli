# Quick Start Guide

## Prerequisites

- Docker and Docker Compose installed
- `.env` file configured (see `.env.example`)

## For Windows Users (PowerShell)

Since `make` is not available by default on Windows, use Docker Compose commands directly:

### Development

```powershell
# Start services
docker compose --env-file .env -f docker/compose.development.yaml up -d

# View logs
docker compose --env-file .env -f docker/compose.development.yaml logs -f

# View specific service logs
docker compose --env-file .env -f docker/compose.development.yaml logs -f backend

# Stop services
docker compose --env-file .env -f docker/compose.development.yaml down

# Stop and remove volumes (clean database)
docker compose --env-file .env -f docker/compose.development.yaml down -v

# Rebuild and start
docker compose --env-file .env -f docker/compose.development.yaml up -d --build
```

### Production

```powershell
# Build production images
docker compose --env-file .env -f docker/compose.production.yaml build

# Start services
docker compose --env-file .env -f docker/compose.production.yaml up -d

# View logs
docker compose --env-file .env -f docker/compose.production.yaml logs -f

# Stop services
docker compose --env-file .env -f docker/compose.production.yaml down
```

### Testing

```powershell
# Gateway health
Invoke-WebRequest -Uri http://localhost:5921/health -UseBasicParsing | Select-Object -ExpandProperty Content

# Backend health (via gateway)
Invoke-WebRequest -Uri http://localhost:5921/api/health -UseBasicParsing | Select-Object -ExpandProperty Content

# Create product
Invoke-WebRequest -Uri http://localhost:5921/api/products -Method POST -ContentType "application/json" -Body '{"name":"Test Product","price":99.99}' -UseBasicParsing | Select-Object -ExpandProperty Content

# Get products
Invoke-WebRequest -Uri http://localhost:5921/api/products -UseBasicParsing | Select-Object -ExpandProperty Content

# Security test (should fail)
Invoke-WebRequest -Uri http://localhost:3847/api/health -UseBasicParsing -TimeoutSec 5
```

## For Linux/macOS Users

### Using Make (Recommended)

```bash
# Development
make dev-up          # Start development
make dev-logs        # View logs
make dev-down        # Stop development

# Production
make prod-build      # Build production images
make prod-up         # Start production
make prod-logs       # View logs
make prod-down       # Stop production

# Database
make mongo-shell     # Open MongoDB shell
make db-backup       # Backup database

# Utilities
make health          # Check all services
make help            # Show all commands
```

### Using Docker Compose

Same as Windows commands above, but you can use `curl` directly:

```bash
# Testing
curl http://localhost:5921/health
curl http://localhost:5921/api/health
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'
curl http://localhost:5921/api/products
```

## Common Tasks

### Check Service Status

```bash
# Development
docker compose --env-file .env -f docker/compose.development.yaml ps

# Production
docker compose --env-file .env -f docker/compose.production.yaml ps
```

### Access Container Shell

```bash
# Backend shell (development)
docker compose --env-file .env -f docker/compose.development.yaml exec backend sh

# Gateway shell (development)
docker compose --env-file .env -f docker/compose.development.yaml exec gateway sh

# MongoDB shell (development)
docker compose --env-file .env -f docker/compose.development.yaml exec mongo mongosh -u admin -p securepassword123
```

### View Real-time Logs

```bash
# All services
docker compose --env-file .env -f docker/compose.development.yaml logs -f

# Specific service
docker compose --env-file .env -f docker/compose.development.yaml logs -f backend
```

### Rebuild After Code Changes

```bash
# Development (auto-reload via volumes, no rebuild needed)
# Just save your files and changes appear automatically!

# Production (rebuild required)
docker compose --env-file .env -f docker/compose.production.yaml build
docker compose --env-file .env -f docker/compose.production.yaml up -d
```

## Troubleshooting

### Containers won't start

1. Check if .env file exists and has values
2. Check Docker logs: `docker compose ... logs`
3. Try removing volumes: `docker compose ... down -v`
4. Rebuild images: `docker compose ... build --no-cache`

### Port already in use

```bash
# Check what's using port 5921
netstat -ano | findstr :5921  # Windows
lsof -i :5921                 # Linux/macOS

# Stop all Docker containers
docker stop $(docker ps -aq)
```

### Database authentication failed

```bash
# Remove volumes and restart (WARNING: deletes data)
docker compose --env-file .env -f docker/compose.development.yaml down -v
docker compose --env-file .env -f docker/compose.development.yaml up -d
```

### Changes not reflecting

- **Development**: Changes should auto-reload via volumes
- **Production**: You must rebuild: `docker compose ... build && docker compose ... up -d`

## Environment Variables

Copy `.env.example` to `.env` and update values:

```bash
# Copy example (Linux/macOS)
cp .env.example .env

# Copy example (Windows)
copy .env.example .env
```

Required variables:
- `MONGO_INITDB_ROOT_USERNAME` - MongoDB admin username
- `MONGO_INITDB_ROOT_PASSWORD` - MongoDB admin password
- `MONGO_URI` - MongoDB connection string
- `MONGO_DATABASE` - Database name
- `BACKEND_PORT=3847` - Backend port (don't change)
- `GATEWAY_PORT=5921` - Gateway port (don't change)
- `NODE_ENV` - Environment (development/production)

## What's Running?

- **Gateway**: http://localhost:5921 (only public service)
- **Backend**: Internal only (not accessible from host)
- **MongoDB**: Internal only (not accessible from host)

## Next Steps

1. Start development environment
2. Test health endpoints
3. Create some products
4. Try stopping and restarting to verify persistence
5. Test security by trying to access backend directly (should fail)
6. Build and test production environment

## Need Help?

- Check `IMPLEMENTATION_SUMMARY.md` for detailed info
- Check `README.md` for project overview
- Check `Problem Statement.md` for requirements
- Run `make help` to see all available commands (Linux/macOS)

