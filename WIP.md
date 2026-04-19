# Work In Progress — Task Manager Project Dashboard

> **Last updated:** 2026-04-19 (Session 2)
> **Session:** !system-audit — Spoke ↔ Hub alignment reconciliation
> **Overall status:** Sprint 1 ✅ Complete · Sprint 2 ✅ Complete · EC2 Deployment ⏳ Pending

---

## Sprint Progress

### Sprint 1 — Backend (All 19 tasks: ✅ Done)

| Task | Description | Owner | Status |
|------|-------------|-------|--------|
| T-01 | Scaffold user-service | chau_tv | ✅ |
| T-02 | Scaffold task-service | thai_dm | ✅ |
| T-03 | POST /api/users (register) | chau_tv | ✅ |
| T-04 | POST /api/tasks (create) | thai_dm | ✅ |
| T-05 | POST /api/auth/login + JWT | chau_tv | ✅ |
| T-06 | GET /api/users/:id (profile) | chau_tv | ✅ |
| T-07 | GET /api/tasks (list, role-based) | thai_dm | ✅ |
| T-08 | user-service tests | chau_tv | ✅ |
| T-09 | user-service Dockerfile (3-stage) | chau_tv | ✅ |
| T-10 | PATCH /api/tasks/:id/status | thai_dm | ✅ |
| T-11 | Status transition enforcement | thai_dm | ✅ |
| T-12 | task-service tests | thai_dm | ✅ |
| T-13 | task-service Dockerfile (3-stage) | thai_dm | ✅ |
| T-14 | tasks_db migration (tasks + comments tables) | thai_dm | ✅ |
| T-15 | Scaffold api-gateway | chau_tv | ✅ |
| T-16 | JWT validation middleware (7-step) | chau_tv | ✅ |
| T-17 | Proxy routing (user-service + task-service) | thai_dm | ✅ |
| T-18 | api-gateway tests | thai_dm | ✅ |
| T-19 | api-gateway Dockerfile (3-stage) | chau_tv | ✅ |

---

### Sprint 2 — Frontend + Integration (9/9 tasks: ✅ Done)

| Task | Description | Owner | Status |
|------|-------------|-------|--------|
| F-01 | Scaffold frontend-service (Vite + React + TS) | chau_tv | ✅ |
| F-02 | LoginPage component + auth flow | thai_dm | ✅ |
| F-03 | TaskListPage + TaskCard + TaskFilterBar | chau_tv | ✅ |
| F-04 | CreateTaskPage + form | chau_tv | ✅ |
| F-05 | GET /api/tasks/:id endpoint (task detail) | thai_dm | ✅ |
| F-06 | DELETE /api/tasks/:id endpoint | thai_dm | ✅ |
| F-07 | POST /api/tasks/:id/comments endpoint | thai_dm | ✅ |
| F-08 | Add frontend-service to docker-compose + CORS wiring | thai_dm | ✅ |
| F-09 | TaskDetailPage + CommentForm + CommentList | chau_tv | ✅ |

---

## Client-Ready Features

These endpoints and UI flows are fully built, tested, and Dockerized — ready to demo or hand off.

### API (via api-gateway :8080)

| Feature | Method + Path | Auth | Notes |
|---------|--------------|------|-------|
| Register user | `POST /api/users` | None | bcrypt 12 rounds, UUID user ID |
| Login + get JWT | `POST /api/auth/login` | None | HS256, 24h expiry |
| Create task | `POST /api/tasks` | Bearer JWT | Assigns to user, sets TODO |
| List tasks | `GET /api/tasks` | Bearer JWT | Role-based: lead=all, member=own |
| Get task detail | `GET /api/tasks/:id` | Bearer JWT | Includes comments array |
| Transition status | `PATCH /api/tasks/:id/status` | Bearer JWT | TODO→IN_PROGRESS→DONE, any→CANCELLED |
| Delete task | `DELETE /api/tasks/:id` | Bearer JWT | Lead only |
| Add comment | `POST /api/tasks/:id/comments` | Bearer JWT | Stored with authorId |
| Gateway health | `GET /health` | None | `{ "status": "ok" }` |

### React SPA (frontend-service :3000)

| Page | Route | What It Does |
|------|-------|-------------|
| Login | `/login` | Email + password → JWT stored in localStorage |
| Task List | `/tasks` | Paginated list, filter by status/assignee, role-aware |
| Create Task | `/tasks/new` | Form → POST /api/tasks |
| Task Detail | `/tasks/:id` | Full task info + comment thread + status selector |

### Infrastructure

| Artifact | Status | Notes |
|---------|--------|-------|
| docker-compose.yml (full stack) | ✅ Ready | all 4 services + 2 PG DBs, health-gated startup chain, VITE_API_BASE_URL baked |
| docker-compose.prod.yml | ✅ Ready | Pre-built images from chaudevops Docker Hub |
| Postman collection | ✅ Ready | `collections/Task-Manager-API.postman_collection.json` |
| Postman environment | ✅ Ready | `collections/Task-Manager-Local.postman_environment.json` |

**To run the full backend stack:**
```bash
docker compose up --build
# Gateway available at http://localhost:8080
```

**To demo with Postman:**
Import both files from `collections/` → run the "E2E Flow" folder top-to-bottom.

---

## Known Gaps (Blocking or Notable)

| # | Gap | Impact | Owner | Next Action |
|---|-----|--------|-------|-------------|
| G-02 | `docker-compose.prod.yml` services 3001/3002 exposed | user-service and task-service directly reachable in prod — violates EC2 Port Binding skill: internal services must NOT bind to host | — | Remove `ports:` block for user-service + task-service in prod compose |
| G-03 | No `.env.prod` files | EC2 deploy needs real DATABASE_URL, JWT_SECRET, service URLs — `.env` files are gitignored | chau_tv | Create `.env.prod` per service with real values before EC2 deploy |
| G-04 | AWS infrastructure not provisioned | Cannot deploy to cloud | chau_tv | Phase 2: ECR repos + ECS Fargate + RDS + ALB (see PROJECT-MEMORY.md) |
| ~~G-05~~ | ~~Hub skills-ledger has `#new` tag~~ | **RESOLVED** — `!system-audit` confirmed no `#new` tags exist in skills-ledger. WIP/memory were stale. | — | ~~Run `!hub-sync`~~ — already clean |
| G-06 | task-service test coverage gaps | `GET /tasks/:id`, `DELETE /tasks/:id`, `POST /tasks/:id/comments` implemented (F-05/F-06/F-07 ✅) but have **zero test cases** — Broken Promise | thai_dm | Add 3 describe blocks to `task-service/src/__tests__/tasks.test.ts` |
| G-07 | user-service test coverage gaps | `GET /users/:id` (T-05) and `GET /users` (list-users, added last session) both untested — endpoints are live with no test | chau_tv | Add test cases to `user-service/src/__tests__/users.test.ts` |

---

## Session Log

### Session 1 — 2026-04-19 (Sprint 1+2 implementation + EC2 readiness)

Fixed the following issues:

| # | Fix | Description |
|---|-----|-------------|
| — | GET /users endpoint | Added `GET /users` route to user-service for listing all users (needed for task assignment dropdown) |
| — | GET /users route in gateway | Added `GET /users` proxy route to api-gateway |
| — | Frontend in docker-compose | Added `frontend-service` to docker-compose.yml with nginx + CORS |
| — | User dropdown in CreateTaskPage | Added assignee dropdown that fetches user list from `GET /users` |
| — | RegisterPage | Added registration page for new user signup |
| — | UI styling | Added CSS styles for better visual appearance |
| — | Error logging fix | Fixed error logging in user-service |
| — | API path fixes | Fixed frontend API path routing (POST /users, GET /users, /tasks endpoints) |
| — | Container rebuild | Rebuilt all containers with `docker compose up --build -d` |

### Session 2 — 2026-04-19 (!system-audit)

| # | Finding | Action |
|---|---------|--------|
| Audit | Ran `!system-audit` — full Spoke ↔ Hub reconciliation | Gaps G-06, G-07 opened; G-05 closed |
| G-05 | Confirmed stale — no `#new` tag in actual skills-ledger | Struck from gaps table |
| G-06 | task-service: 3 endpoints untested (GET/:id, DELETE, comments) | Added to gaps |
| G-07 | user-service: 2 endpoints untested (GET/:id, GET /users) | Added to gaps |
| G-02 | Confirmed active in docker-compose.prod.yml | Still open |

## Next Session Checklist

- [ ] Fix G-02 (🔴 CRITICAL before EC2): Remove `ports:` for user-service + task-service in `docker-compose.prod.yml`
- [ ] Fix G-06 (🔴 Broken Promise): Add tests for `GET /tasks/:id`, `DELETE /tasks/:id`, `POST /tasks/:id/comments` in task-service
- [ ] Fix G-07 (🟡 Warning): Add tests for `GET /users/:id` and `GET /users` in user-service
- [ ] Fix G-03: Create `.env.prod` files for all 4 services with real EC2 values
- [ ] Commit all uncommitted changes (user-service, api-gateway, frontend-service, docs)
- [ ] EC2 deploy (single-instance): copy repo to EC2, set SG rules (22, 8080, 3000), `docker compose up --build`
- [ ] Verify port bindings on EC2: `docker ps --format "table {{.Names}}\t{{.Ports}}"` — ensure 0.0.0.0 not 127.0.0.1
- [ ] Phase 2: ECR push + Terraform for ECS + RDS + ALB (see PROJECT-MEMORY.md §AWS Deployment Plan)
