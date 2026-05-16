# Task Management System — Agent Context

> This file is loaded automatically by Claude Code at the start of every session in this repo.
> Do not delete or rename it.

---

## What We Are Building

A task tracker with a REST API backend and a React web UI — like a stripped-down Jira. Teams create, assign, and track tasks without losing them in Slack/Discord. Sprint 1–2 covers the API; Sprint 2 adds the web UI.

**Team:** chau_tv (Person A) + thai_dm (Person B)
**Program:** ProOps2026 — Mock Project, Sprint 1 starts Day 10
**GitHub org:** https://github.com/proops2026-taskmanager

---

## Architecture (locked)

```
Browser
    ├──HTTP :3000──→  frontend-service  :3000   React SPA (nginx)
    └──HTTP :8080──→  api-gateway       :8080   JWT validation + routing + CORS
                          ├──────────────────→  user-service  :3001   register, login, JWT
                          └──────────────────→  task-service  :3002   task CRUD, status, comments

Each service has its own PostgreSQL 15 database.
Network: app-net (Docker bridge)
frontend-service (:3000) and api-gateway (:8080) are exposed to the host.
All other services and databases are internal only.
```

---

## Document System

Read these before implementing anything:

| Document | Local path | Notion | Governs |
|----------|------------|--------|---------|
| DOP-001 | `docs/DOP-001.md` | https://www.notion.so/3478a3d4ee8981c689ebe016e399dab1 | What we're building — ACs that define done |
| IRD-001 | `docs/IRD-001.md` | https://www.notion.so/3478a3d4ee8981a7887cc7f0293d5981 | user-service: API contract, data model, auth rules |
| IRD-002 | `docs/IRD-002.md` | https://www.notion.so/3478a3d4ee898160a396f3e9204cfbf8 | task-service: API contract, status transitions, comments |
| IRD-003 | `docs/IRD-003.md` | https://www.notion.so/3478a3d4ee898192af36dfc8ddae429e | api-gateway routing, JWT middleware, Docker Compose, NFRs |
| IRD-004 | `docs/IRD-004.md` | https://www.notion.so/3478a3d4ee898108a8fdcedd57c0d5cd | frontend-service: React SPA, pages, auth flow, Docker/nginx |
| Architecture | `docs/architecture.md` | — | System diagram + request flow |
| Sprint 1 | `docs/sprint-01.md` | — | All tasks + assignments for Sprint 1 |
| Sprint 2 | `docs/sprint-02.md` | — | Frontend UI tasks + assignments for Sprint 2 |

**Rule:** Before implementing any feature, read DOP-001 + the IRD for the service + IRD-003 (NFRs apply to every service).

---

## Standards — Non-Negotiable

These decisions are locked. Do not invent alternatives.

| Rule | Value |
|------|-------|
| Error format | `{ "error": "string" }` — all services, all endpoints |
| JWT algorithm | HS256, 24h expiry, payload `{ sub: userId, role }` |
| JWT enforcement | api-gateway only — task-service and user-service never validate JWT |
| Header injection | api-gateway injects `X-User-Id` + `X-User-Role` after JWT validation |
| Authorization header | api-gateway strips it before forwarding — never reaches downstream |
| Cross-service references | Plain UUID only — no foreign keys across service boundaries |
| Password hashing | bcrypt, salt rounds: 12 |
| Status transitions | TODO→IN_PROGRESS→DONE (terminal), any→CANCELLED (terminal), no backward |
| Health endpoint | `GET /health → 200 { "status": "ok" }` — every service |
| Secrets | `.env` (git-ignored) + `.env.example` (committed, no values) |
| PostgreSQL version | 15 |
| Node.js version | 20 LTS |
| Frontend build | Vite 5 + React 18 + TypeScript 5 |
| Frontend server | nginx alpine — serves compiled static files |
| CORS | api-gateway enables CORS for `CORS_ORIGIN` env var (default `http://localhost:3000`) |
| Frontend auth | JWT stored in `localStorage` under key `auth_token` |

---

## Team — Task Assignments

### Sprint 1 — chau_tv owns:
| Task | Description |
|------|-------------|
| T-01 | Scaffold user-service (npm init, TS config, Express, /health, Dockerfile, .env.example) |
| T-03 | POST /users — registration with bcrypt + validation |
| T-05 | GET /users/:id — internal endpoint |
| T-06 | user-service integration tests (jest + supertest) |
| T-08 | POST /tasks — create task |
| T-09 | GET /tasks — list tasks (role-based: lead sees all, member sees own) |
| T-15 | api-gateway scaffold + JWT middleware |
| T-16 | api-gateway routing table |
| T-19 | Docker Compose full stack |

### Sprint 1 — thai_dm owns:
| Task | Description |
|------|-------------|
| T-02 | user-service DB schema (users table, migrations) |
| T-04 | POST /auth/login — verify + JWT issuance |
| T-07 | Scaffold task-service |
| T-10 | GET /tasks/:id — task detail + comments |
| T-11 | PATCH /tasks/:id/status — status transition enforcement |
| T-12 | DELETE /tasks/:id |
| T-13 | POST /tasks/:id/comments — add comment |
| T-14 | task-service integration tests |
| T-17 | api-gateway error handling + logging |
| T-18 | api-gateway integration tests |

### Sprint 2 — chau_tv owns:
| Task | Description |
|------|-------------|
| F-01 | Scaffold frontend-service (Vite + React + TS, Dockerfile, nginx.conf, .env.example) |
| F-03 | `TaskListPage` + `TaskCard` + `TaskFilterBar` |
| F-04 | `CreateTaskPage` + `CreateTaskForm` with client-side validation |
| F-09 | Frontend component tests (Vitest + React Testing Library) |

### Sprint 2 — thai_dm owns:
| Task | Description |
|------|-------------|
| F-02 | `LoginPage` + Axios interceptor + `AuthGuard` + `localStorage` helpers |
| F-05 | `TaskDetailPage` — renders task + comments |
| F-06 | `StatusSelector` component — `PATCH /tasks/:id/status` |
| F-07 | `CommentForm` + `CommentList` — `POST /tasks/:id/comments` |
| F-08 | docker-compose.yml frontend addition + CORS middleware on api-gateway |

---

## Sprint State

**Sprint 1 scope (Day 9–11):** user-service + task-service CRUD + api-gateway + Docker Compose
**Sprint 2 scope (Day 12–14):** frontend-service React SPA (web UI)

Current status as of Day 10:
- DOP-001, IRD-001, IRD-002, IRD-003 — written, pushed to Notion ✅
- IRD-004 — written locally (docs/IRD-004.md), pushed to Notion ✅
- architecture.md, sprint-01.md, sprint-02.md, project-overview.md — committed ✅
- user-service, task-service, api-gateway repos — empty, not scaffolded yet
- frontend-service repo — not scaffolded yet (Sprint 2)

---

## IRD Gaps — Fix Before Implementing

These 3 gaps must be resolved in Notion before Day 10 implementation starts:

1. **IRD-002 (Notion):** Role-based GET /tasks logic — lead sees ALL tasks, member sees only their own. Currently unspecified. Fix: add role-based access rule to IRD-002 in Notion.
2. **IRD-001 + IRD-002 (Notion):** Test requirements section missing. Fix: add jest + supertest requirement + test list per endpoint to both IRDs.
3. **IRD-003 (Notion):** `.env.example` pattern not documented. Fix: add .env.example section to IRD-003 in Notion.

---

## Session Startup Routine

When starting a new session to implement something, do this before any code:

```
1. Read docs/DOP-001.md           → know what AC you're delivering
2. Read docs/IRD-00X.md           → know the exact API contract + rules
3. Read docs/IRD-003.md           → apply NFRs (error format, health, .env)
4. Read docs/sprint-01.md or docs/sprint-02.md → confirm which task you're on
5. Check GitHub repo state        → is the scaffold already there?
6. Then implement
```

If you are in a SERVICE repo (user-service, task-service, api-gateway):
- That repo's CLAUDE.md tells you exactly which tasks are yours and which IRD governs the service.
- Read the IRD, then implement.

---

## Rules for Implementation

1. Read DOP-001 + relevant IRD + IRD-003 before writing any code
2. Follow the API contract in the IRD exactly — do not invent endpoints or change field names
3. Never validate JWT in user-service or task-service — only api-gateway does this
4. Cross-service references are plain UUIDs only — no joins across service databases
5. Every endpoint needs at least one integration test (jest + supertest)
6. Error format is `{ "error": "..." }` — not `message`, not `msg`, not anything else
7. No hardcoded secrets — `.env` + `.env.example` pattern on every service
8. Status transitions are enforced in task-service — return 400 on invalid transition
