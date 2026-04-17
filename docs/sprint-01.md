# Sprint 1 Backlog — Task Management System

> Replace this file with your group's Sprint 1 plan.
> Keep the structure: Epics → User Stories → Tasks → assigned person → Definition of Done.

---

**Sprint duration:** Day 9 – Day 11 (3 working days)  
**Team:** Person A = chau_tv · Person B = thai_dm  
**Sprint goal:** Working user-service and task-service accessible via api-gateway. A client can register, log in, create a task, and update its status — all via REST with JWT auth.

---

## Epic 1 · User Service

Covers AC-01 and AC-02 from DOP-001. All user registration and authentication logic lives here.

---

### User Story US-01
**As a** team member,  
**I want to** register with my email and password,  
**so that** I have an account and can access the system.

**Acceptance criteria (from DOP AC-01):**
- `POST /users` with valid email + password → 201 with `{ id, email, full_name, role, created_at }`
- Duplicate email → 409 `{ "error": "Email already in use" }`
- Missing field → 400 `{ "error": "<specific message>" }`

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| T-01 | Scaffold user-service: Express app, `/health` endpoint, Dockerfile | A | 2h | [PRO-8](https://linear.app/chautv-proops2026-claude/issue/PRO-8/t-01-scaffold-user-service) |
| T-02 | Write users table migration (SQL file) | B | 1h | [PRO-9](https://linear.app/chautv-proops2026-claude/issue/PRO-9/t-02-users-table-migration) |
| T-03 | `POST /users` endpoint + bcrypt password hash | A | 3h | [PRO-10](https://linear.app/chautv-proops2026-claude/issue/PRO-10/t-03-post-users-registration) |
| T-04 | Integration test: register success, duplicate email 409, missing field 400 | B | 2h | [PRO-11](https://linear.app/chautv-proops2026-claude/issue/PRO-11/t-04-integration-tests-post-users) |

---

### User Story US-02
**As a** registered team member,  
**I want to** log in with my credentials,  
**so that** I receive a JWT token I can use to call other endpoints.

**Acceptance criteria (from DOP AC-02):**
- `POST /auth/login` with correct credentials → 200 with `{ token, user }`
- Wrong password → 401 `{ "error": "Invalid credentials" }`
- JWT payload includes `sub` and `role`, expires in 24h

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| T-05 | `POST /auth/login` endpoint + JWT signing | A | 3h | [PRO-12](https://linear.app/chautv-proops2026-claude/issue/PRO-12/t-05-post-authlogin-jwt-issuance) |
| T-06 | Integration test: login success, wrong password 401 | B | 1h | [PRO-13](https://linear.app/chautv-proops2026-claude/issue/PRO-13/t-06-integration-tests-post-authlogin) |

---

## Epic 2 · Task Service

Covers AC-03, AC-04, AC-06 from DOP-001. All task data lives here.

---

### User Story TS-01
**As a** team member,  
**I want to** create a task with a title and an assignee,  
**so that** the team can see and track it.

**Acceptance criteria (from DOP AC-03):**
- `POST /tasks` with title + assignee_id → 201 with full task object, status `TODO`
- Missing title or assignee_id → 400

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| T-07 | Scaffold task-service: Express app, `/health` endpoint, Dockerfile | B | 2h | [PRO-14](https://linear.app/chautv-proops2026-claude/issue/PRO-14/t-07-scaffold-task-service) |
| T-08 | Write tasks table migration (SQL file) | A | 1h | [PRO-15](https://linear.app/chautv-proops2026-claude/issue/PRO-15/t-08-tasks-comments-table-migration) |
| T-09 | `POST /tasks` endpoint | B | 2h | [PRO-16](https://linear.app/chautv-proops2026-claude/issue/PRO-16/t-09-post-tasks-create-task) |
| T-10 | Integration test: create task success, missing field 400 | A | 1h | [PRO-17](https://linear.app/chautv-proops2026-claude/issue/PRO-17/t-10-integration-tests-post-tasks) |

---

### User Story TS-02
**As a** team member,  
**I want to** update a task's status,  
**so that** the team knows whether the task is in progress or done.

**Acceptance criteria (from DOP AC-04):**
- `PATCH /tasks/:id/status` with valid status → 200 with updated task
- Invalid status value → 400 listing valid values
- Non-existent task → 404

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| T-11 | `PATCH /tasks/:id/status` endpoint + status validation | B | 2h | [PRO-18](https://linear.app/chautv-proops2026-claude/issue/PRO-18/t-11-patch-tasksidstatus-status-transitions) |
| T-12 | Integration test: update success, invalid status 400, 404 | A | 1h | [PRO-19](https://linear.app/chautv-proops2026-claude/issue/PRO-19/t-12-integration-tests-patch-tasksidstatus) |

---

### User Story TS-03
**As a** team member,  
**I want to** list my assigned tasks,  
**so that** I can see everything I am responsible for.

**Acceptance criteria (from DOP AC-05):**
- `GET /tasks?assignee_id=<uuid>` → 200 with array of tasks matching that assignee
- `GET /tasks?status=TODO` → 200 with array filtered by status
- Empty result → 200 with `[]`

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| T-13 | `GET /tasks` endpoint with `?status=` and `?assignee_id=` query filters | B | 2h | [PRO-20](https://linear.app/chautv-proops2026-claude/issue/PRO-20/t-13-get-tasks-list-with-filters-role-based) |
| T-14 | Integration test: list tasks by assignee_id, list by status, empty result | A | 1h | [PRO-21](https://linear.app/chautv-proops2026-claude/issue/PRO-21/t-14-integration-tests-get-tasks) |

---

## Epic 3 · API Gateway

Wire up routing and JWT validation so the client only talks to port 3000.

---

### User Story GW-01
**As a** developer,  
**I want** all client requests to go through the api-gateway,  
**so that** services are not directly exposed and JWT is validated in one place.

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| T-15 | Scaffold api-gateway: Express + http-proxy-middleware, Dockerfile | A | 2h | [PRO-22](https://linear.app/chautv-proops2026-claude/issue/PRO-22/t-15-scaffold-api-gateway) |
| T-16 | JWT validation middleware — attach `X-User-Id` and `X-User-Role` headers | A | 2h | [PRO-23](https://linear.app/chautv-proops2026-claude/issue/PRO-23/t-16-jwt-validation-middleware) |
| T-17 | Route `/users` and `/auth` → user-service, `/tasks` → task-service | B | 1h | [PRO-24](https://linear.app/chautv-proops2026-claude/issue/PRO-24/t-17-gateway-routing-table) |
| T-18 | Write `docker-compose.yml`: all three services + two databases on `app-net` | B | 2h | [PRO-25](https://linear.app/chautv-proops2026-claude/issue/PRO-25/t-18-docker-composeyml-full-stack) ✅ |
| T-19 | End-to-end test: register → login → create task → update status via gateway only | A | 2h | [PRO-26](https://linear.app/chautv-proops2026-claude/issue/PRO-26/t-19-end-to-end-test-via-gateway) |

---

## Sprint 1 — Definition of Done

Sprint 1 is complete when all of the following are true:

1. `docker compose up` starts the full stack (gateway + 2 services + 2 databases) with no errors
2. All endpoints from AC-01 through AC-04 and AC-06 return the correct HTTP status codes and response bodies
3. All integration tests pass (`npm test` in each service)
4. No hardcoded secrets — all config is in `.env` (`.env` is gitignored, `.env.example` is committed)
5. Each service has a working `/health` endpoint
6. `docs/sprint-01.md` updated to mark all tasks complete

---

## Sprint 1 — Integration Protocol

Services are built in parallel. Integration is phased and gated.

### Phase 1 — Service-level (Epic 1 + Epic 2, parallel)

| Service | Gate to push `main` |
|---|---|
| user-service | All T-01 → T-06 tasks done; `npm test` passes |
| task-service | All T-07 → T-14 tasks done; `npm test` passes |

Each service agent works independently. No waiting for the other service.

**task-service identity rule:** In integration tests, inject `X-User-Id` and `X-User-Role` headers directly in each test request. Do NOT call user-service or validate a JWT. That is the gateway's job.

### Phase 2 — Gateway integration (Epic 3, sequential)

The api-gateway work (T-15 → T-19) begins only after **both** user-service and task-service show ✅ below.

| Service | Status | Merged to main |
|---|---|---|
| user-service | ✅ T-01→T-06 done, tests pass | main |
| task-service | ✅ T-07→T-14 done, tests pass | main |
| api-gateway | 🟡 T-15→T-18 done, T-19 pending | — |

Update this table when each service is integration-ready.

### If a dependent service is not ready

- Your own service work continues unblocked
- If another service has a bug that breaks e2e: open a Linear issue in that service's repo; do not patch it from your session
- Gateway agent holds T-19 (e2e test) until both service rows above show ✅

---

## Sprint 1 — Out of scope

Deliberately excluded. Do not implement these in Sprint 1:

- Comments on tasks (AC-05) — Sprint 2
- Team lead "all tasks" view (AC-07) — Sprint 2
- Password reset / email verification — Sprint 3+
- Frontend / UI — Sprint 2 (see `docs/sprint-02.md` and `docs/IRD-004.md`)
