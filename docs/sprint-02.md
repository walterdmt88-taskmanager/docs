# Sprint 2 Backlog — Frontend UI

---

**Sprint duration:** Day 12 – Day 14 (3 working days)  
**Team:** Person A = chau_tv · Person B = thai_dm  
**Sprint goal:** A working web UI where users can log in, view tasks, create tasks, update status, and add comments — all wired through api-gateway with JWT auth.

**Prerequisite:** Sprint 1 complete (user-service + task-service + api-gateway running via `docker compose up`).

---

## Epic 4 · Frontend Service

Covers AC-08 through AC-13 from DOP-001. All UI logic lives in a single React SPA served by nginx. No server-side logic.

---

### User Story FE-01
**As a** team member,  
**I want to** log in via a web page,  
**so that** I can access the task dashboard without writing API calls.

**Acceptance criteria (from DOP AC-08):**
- `/login` page has email + password fields and a submit button
- Submit calls `POST /auth/login`; on 200, stores JWT in `localStorage` and redirects to `/`
- On 401, shows an inline error message
- Unauthenticated access to any protected route redirects to `/login`

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| F-01 | Scaffold frontend-service: Vite + React 18 + TS, Dockerfile, nginx.conf, .env.example | A | 2h | [PRO-27](https://linear.app/chautv-proops2026-claude/issue/PRO-27/f-01-scaffold-frontend-service) |
| F-02 | `LoginPage` + `LoginForm` + Axios interceptor + `AuthGuard` HOC + `localStorage` helpers | B | 3h | [PRO-28](https://linear.app/chautv-proops2026-claude/issue/PRO-28/f-02-loginpage-authguard-axios-interceptor) |

---

### User Story FE-02
**As a** team member,  
**I want to** see my assigned tasks in the browser,  
**so that** I know what I need to work on without calling the API manually.

**Acceptance criteria (from DOP AC-09):**
- `/` renders a list of tasks with title, status badge, and assignee
- Member sees own tasks; team lead sees all tasks
- Empty state shows "No tasks yet"

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| F-03 | `TaskListPage` + `TaskCard` + `TaskFilterBar` (status + assignee_id filters) | A | 3h | [PRO-29](https://linear.app/chautv-proops2026-claude/issue/PRO-29/f-03-tasklistpage-taskcard-taskfilterbar) |

---

### User Story FE-03
**As a** team member,  
**I want to** create a task using a web form,  
**so that** I can add work items without using Postman.

**Acceptance criteria (from DOP AC-10):**
- `/tasks/new` has fields for title, description, assignee_id
- Submit calls `POST /tasks`; on 201, redirects to `/` and new task appears at top
- Missing required field → form-level validation error, no API call made

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| F-04 | `CreateTaskPage` + `CreateTaskForm` with client-side validation | A | 2h | [PRO-30](https://linear.app/chautv-proops2026-claude/issue/PRO-30/f-04-createtaskpage-createtaskform) |

---

### User Story FE-04
**As a** team member,  
**I want to** update a task's status in the browser,  
**so that** the team can see my progress without me calling the API.

**Acceptance criteria (from DOP AC-11):**
- Task detail page shows a status selector (dropdown / button group)
- Selecting a new valid status calls `PATCH /tasks/:id/status`; UI updates on success
- On 400 (invalid transition), shows an inline error

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| F-05 | `TaskDetailPage` — `GET /tasks/:id`, renders task fields + `CommentList` | B | 2h | [PRO-31](https://linear.app/chautv-proops2026-claude/issue/PRO-31/f-05-taskdetailpage-task-fields-comments-display) |
| F-06 | `StatusSelector` component — `PATCH /tasks/:id/status`, inline error on 400 | B | 2h | [PRO-32](https://linear.app/chautv-proops2026-claude/issue/PRO-32/f-06-statusselector-patch-tasksidstatus) |

---

### User Story FE-05
**As a** team member,  
**I want to** add a comment to a task in the browser,  
**so that** I can leave notes without using curl.

**Acceptance criteria (from DOP AC-12):**
- Task detail page has a comment input and submit button
- Submit calls `POST /tasks/:id/comments`; new comment appears in the list immediately
- Empty body → disabled submit button

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| F-07 | `CommentForm` + `CommentList` — `POST /tasks/:id/comments`, optimistic or refetch on success | B | 2h | [PRO-33](https://linear.app/chautv-proops2026-claude/issue/PRO-33/f-07-commentform-post-tasksidcomments) |

---

### User Story FE-06
**As a** team lead,  
**I want to** see all tasks and filter by assignee or status,  
**so that** I can monitor the team's workload at a glance.

**Acceptance criteria (from DOP AC-13):**
- `TaskFilterBar` allows selecting status and assignee_id
- Changing a filter re-fetches `GET /tasks?status=&assignee_id=` and updates the list
- Active filters are reflected in the URL query string

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| F-03 | (covered — `TaskFilterBar` is part of F-03 above) | A | — | [PRO-29](https://linear.app/chautv-proops2026-claude/issue/PRO-29/f-03-tasklistpage-taskcard-taskfilterbar) |

---

### User Story FE-07
**As a** developer,  
**I want** the frontend running in Docker Compose alongside the backend,  
**so that** `docker compose up` starts the complete stack including the web UI.

| # | Task | Owner | Est. | Linear |
|---|---|---|---|---|
| F-08 | Add `frontend-service` to `docker-compose.yml` + CORS middleware to api-gateway (`CORS_ORIGIN` env var) | B | 2h | [PRO-34](https://linear.app/chautv-proops2026-claude/issue/PRO-34/f-08-docker-compose-frontend-gateway-cors) |
| F-09 | Frontend component tests: `LoginPage`, `AuthGuard`, `TaskListPage`, `CreateTaskForm`, `TaskDetailPage`, `StatusSelector`, `CommentForm` (Vitest + RTL) | A | 3h | [PRO-35](https://linear.app/chautv-proops2026-claude/issue/PRO-35/f-09-frontend-component-tests-vitest-rtl) |

---

### User Story FE-08
**As a** DevOps engineer,  
**I want** the frontend containerized for multi-node Swarm deployment,  
**so that** the full stack (including UI) can be deployed across a 3-node EC2 cluster.

**Context:** Added 2026-04-19 after `!system-audit` identified that the Swarm architecture
(designed in Day 11 lab) included `frontend-service` but no sprint task existed for it.
`RegisterPage` was also added organically during Session 1 — included here.

| # | Task | Owner | Est. | Status |
|---|---|---|---|---|
| F-10 | Build frontend image for linux/amd64 with `VITE_API_BASE_URL` baked; push to `chaudevops/taskmanager-frontend-service:v1.0.0`; add to `docker-compose.stack.yml` | chau_tv | 1.5h | ✅ Done (2026-04-19) |
| F-11 | RegisterPage — registration form wired to `POST /api/users`; redirect to `/login` on success | chau_tv | 1h | ✅ Done (2026-04-19, organic addition to F-02 scope) |

---

## Sprint 2 — Task Assignment Summary

### chau_tv (A) owns:
| Task | Description |
|---|---|
| F-01 | Scaffold frontend-service (Vite + React + TS, Dockerfile, nginx.conf, .env.example) |
| F-03 | `TaskListPage` + `TaskCard` + `TaskFilterBar` |
| F-04 | `CreateTaskPage` + `CreateTaskForm` |
| F-09 | Frontend component tests (Vitest + React Testing Library) |

### thai_dm (B) owns:
| Task | Description |
|---|---|
| F-02 | `LoginPage` + Axios interceptor + `AuthGuard` + `localStorage` helpers |
| F-05 | `TaskDetailPage` + comments display |
| F-06 | `StatusSelector` component |
| F-07 | `CommentForm` + `CommentList` |
| F-08 | docker-compose.yml frontend addition + CORS on api-gateway |

---

## Sprint 2 — Definition of Done

Sprint 2 is complete when all of the following are true:

1. `docker compose up` starts the full stack including `frontend-service` with no errors
2. A user can register, log in via the web UI, see their tasks, create a task, update its status, and add a comment — all without touching curl or Postman
3. A team lead visiting `/` sees all tasks and can filter by status and assignee
4. All frontend component tests pass (`npm test` in `frontend-service`)
5. nginx serves `index.html` for all SPA routes (no 404 on browser refresh)
6. `VITE_API_BASE_URL` comes from the environment — not hardcoded
7. `docs/sprint-02.md` updated to mark all tasks complete

---

---

## Epic 5 · Docker Hardening

Upgrades all Node.js service Dockerfiles from the 2-stage pattern to the 3-stage pattern (deps → builder → runner) acquired in the Docker module. Fixes the `start_period` gap on PostgreSQL healthchecks. Runs in parallel with Epic 4 — no dependencies between them.

**Why now:** Sprint 1 Dockerfiles run correctly but re-download production `node_modules` at build time (`npm ci --omit=dev` in the production stage). The 3-stage pattern pre-builds deps in a dedicated stage and copies the pre-built `node_modules` into the runner — no network call in the final layer, faster CI, deterministic builds. This is now the locked standard in IRD-000 §11.

| # | Task | Owner | Est. | Status |
|---|---|---|---|---|
| D-01 | Upgrade `user-service/Dockerfile` to 3-stage (deps → builder → runner, appuser) | chau_tv | 1h | ✅ Done |
| D-02 | Upgrade `task-service/Dockerfile` to 3-stage | thai_dm | 1h | ✅ Done |
| D-03 | Upgrade `api-gateway/Dockerfile` to 3-stage | chau_tv | 1h | ✅ Done |
| D-04 | Add `start_period: 10s` to `db-user` + `db-task` healthchecks in `docker-compose.yml` | chau_tv | 30m | ✅ Done |
| D-05 | Update `IRD-000 §11` Dockerfile standard to 3-stage pattern + add frontend exception note | chau_tv | 30m | ✅ Done |

**Estimate:** 4h. **Net Sprint 2 delta:** +4h (no tasks removed).

**Definition of done for this epic:**
- `docker compose build` completes without error for all 3 services
- `docker compose up` — all services reach `healthy` state and `GET /health` returns 200
- IRD-000 §11 in Notion updated (run `/report` to push)

⚠️ **Notion sync needed:** `docs/IRD-000.md` was updated — run `/report` to push §11 changes to https://www.notion.so/344dde5fafa981c196b4e57212bc28cf

---

## Sprint 2 — Out of scope

- Real-time updates (WebSocket / Server-Sent Events)
- File attachments on tasks
- Password reset / email verification flow
- Admin user management UI
- Pagination (list endpoints return all matching records)
