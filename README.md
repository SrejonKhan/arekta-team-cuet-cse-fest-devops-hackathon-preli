## Project Overview

- Gateway (port 5921) is the only exposed entrypoint.
- Backend (port 3847) and MongoDB (port 27017) run on a private Docker network.
- Data persists via named volumes. Dev and prod have separate compose files.
- Multi-stage docker build.

## Architecture

```
                    ┌─────────────────┐
                    │   Client/User   │
                    └────────┬────────┘
                             │
                             │ HTTP (port 5921)
                             │
                    ┌────────▼────────┐
                    │    Gateway      │
                    │  (port 5921)    │
                    │   [Exposed]     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼──────────┐      │
         │   Private Network   │      │
         │  (Docker Network)   │      │
         └──────────┬──────────┘      │
                    │                 │
         ┌──────────┴──────────┐      │
         │                     │      │
    ┌────▼────┐         ┌──────▼──────┐
    │ Backend │         │   MongoDB   │
    │(port    │◄────────┤  (port      │
    │ 3847)   │         │  27017)     │
    │[Not     │         │ [Not        │
    │Exposed] │         │ Exposed]    │
    └─────────┘         └─────────────┘
```

## Makefile Commands

Docker Services

```bash
make up                # optional: MODE=dev|prod, service names, ARGS="--build"
make down              # optional: MODE=dev|prod, ARGS="--volumes"
make build             # optional: MODE=dev|prod, service names
make logs SERVICE=backend   # or SERVICE=gateway
make restart           # optional: service names, MODE=dev|prod
make shell             # optional: SERVICE=backend|gateway, MODE=dev|prod
make ps                # optional: MODE=dev|prod
```

Convenience Aliases (Development)

```bash
make dev-up
make dev-down
make dev-build
make dev-logs
make dev-restart
make dev-shell
make dev-ps
make backend-shell
make gateway-shell
make mongo-shell
```

Convenience Aliases (Production)

```bash
make prod-up
make prod-down
make prod-build
make prod-logs
make prod-restart
make prod-shell
make prod-ps
```

Backend

```bash
make backend-install
make backend-build
make backend-type-check
make backend-dev
```

Database

```bash
make db-backup
make db-reset
```

Cleanup

```bash
make clean
make clean-volumes
make clean-all
```

Utilities

```bash
make status
make health
```

Help

```bash
make help
```

## Environment

1. Copy `.env.example` to `.env` and set values. Required keys:

```env
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=securepassword123
MONGO_URI=mongodb://admin:securepassword123@mongo:27017/
MONGO_DATABASE=ecommerce
BACKEND_PORT=3847
GATEWAY_PORT=5921
NODE_ENV=development
BACKEND_URL=http://backend:3847
```

## API Smoke Tests

```bash
# Health
curl http://localhost:5921/health
curl http://localhost:5921/api/health

# Products
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'
curl http://localhost:5921/api/products

# Security (should fail/blocked)
curl http://localhost:3847/api/health
```
