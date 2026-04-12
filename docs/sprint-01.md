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
- `POST /users` with valid email + password → 201 with `{ id, email, created_at }`
- Duplicate email → 409 `{ message: "email already in use" }`
- Missing field → 400

| # | Task | Owner | Est. |
|---|---|---|---|
| T-01 | Scaffold user-service: Express app, `/health` endpoint, Dockerfile | A | 2h |
| T-02 | Write users table migration (SQL file) | B | 1h |
| T-03 | `POST /users` endpoint + bcrypt password hash | A | 3h |
| T-04 | Integration test: register success, duplicate email 409, missing field 400 | B | 2h |

---

### User Story US-02
**As a** registered team member,  
**I want to** log in with my credentials,  
**so that** I receive a JWT token I can use to call other endpoints.

**Acceptance criteria (from DOP AC-02):**
- `POST /auth/login` with correct credentials → 200 with `{ token, user }`
- Wrong password → 401 `{ message: "invalid email or password" }`
- JWT payload includes `userId` and `role`, expires in 24h

| # | Task | Owner | Est. |
|---|---|---|---|
| T-05 | `POST /auth/login` endpoint + JWT signing | A | 3h |
| T-06 | Integration test: login success, wrong password 401 | B | 1h |

---

## Epic 2 · Task Service

Covers AC-03, AC-04, AC-06 from DOP-001. All task data lives here.

---

### User Story TS-01
**As a** team member,  
**I want to** create a task with a title and an assignee,  
**so that** the team can see and track it.

**Acceptance criteria (from DOP AC-03):**
- `POST /tasks` with title + assignee_id → 201 with full task object, status `todo`
- Missing title or assignee_id → 400

| # | Task | Owner | Est. |
|---|---|---|---|
| T-07 | Scaffold task-service: Express app, `/health` endpoint, Dockerfile | B | 2h |
| T-08 | Write tasks table migration (SQL file) | A | 1h |
| T-09 | `POST /tasks` endpoint | B | 2h |
| T-10 | Integration test: create task success, missing field 400 | A | 1h |

---

### User Story TS-02
**As a** team member,  
**I want to** update a task's status,  
**so that** the team knows whether the task is in progress or done.

**Acceptance criteria (from DOP AC-04):**
- `PATCH /tasks/:id/status` with valid status → 200 with updated task
- Invalid status value → 400 listing valid values
- Non-existent task → 404

| # | Task | Owner | Est. |
|---|---|---|---|
| T-11 | `PATCH /tasks/:id/status` endpoint + status validation | B | 2h |
| T-12 | Integration test: update success, invalid status 400, 404 | A | 1h |

---

### User Story TS-03
**As a** team member,  
**I want to** list my assigned tasks,  
**so that** I can see everything I am responsible for.

**Acceptance criteria (from DOP AC-06):**
- `GET /tasks?assignee=me` → 200 with array of tasks ordered by `created_at` desc
- Empty result → 200 with `{ tasks: [], total: 0 }`

| # | Task | Owner | Est. |
|---|---|---|---|
| T-13 | `GET /tasks` endpoint with `?assignee=me` filter | B | 2h |
| T-14 | Integration test: list tasks, empty result | A | 1h |

---

## Epic 3 · API Gateway

Wire up routing and JWT validation so the client only talks to port 3000.

---

### User Story GW-01
**As a** developer,  
**I want** all client requests to go through the api-gateway,  
**so that** services are not directly exposed and JWT is validated in one place.

| # | Task | Owner | Est. |
|---|---|---|---|
| T-15 | Scaffold api-gateway: Express + http-proxy-middleware, Dockerfile | A | 2h |
| T-16 | JWT validation middleware — attach `X-User-Id` and `X-User-Role` headers | A | 2h |
| T-17 | Route `/users` and `/auth` → user-service, `/tasks` → task-service | B | 1h |
| T-18 | Write `docker-compose.yml`: all three services + two databases on `app-net` | B | 2h |
| T-19 | End-to-end test: register → login → create task → update status via gateway only | A | 2h |

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

## Sprint 1 — Out of scope

Deliberately excluded. Do not implement these in Sprint 1:

- Comments on tasks (AC-05) — Sprint 2
- Team lead "all tasks" view (AC-07) — Sprint 2
- Password reset / email verification — Sprint 3+
- Frontend / UI — not part of this program
