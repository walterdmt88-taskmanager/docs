# WIP — Task Management System

**Last updated:** 2026-04-24
**Updated by:** Session 3 (chau_tv)

---

## Sprint Status

### Sprint 1 (T-01→T-19) — ✅ COMPLETE

All 19 tasks done. Tests pass. Full stack runs via `docker compose up`.

### Sprint 2 (F-01→F-09 + D-01→D-05 + F-10→F-11) — ✅ COMPLETE

All frontend tasks done. 3-stage Dockerfiles upgraded. `docker-compose.yml` includes frontend-service. Component tests pass (Vitest + RTL).

---

## Known Gaps — Resolved This Session

| Gap | Description | Status |
|-----|-------------|--------|
| G-02 | `docker-compose.prod.yml` exposed ports 3001/3002 for user-service + task-service | ✅ Fixed 2026-04-24 |
| G-06 | task-service missing GET /tasks/:id, DELETE /tasks/:id, POST /tasks/:id/comments | ✅ Fixed 2026-04-24 — 33/33 tests pass |
| G-07 | user-service missing GET /users/:id implementation + tests for GET /users | ✅ Fixed 2026-04-24 — 16/16 tests pass |

---

## Test Coverage (current)

| Service | Tests | Status |
|---------|-------|--------|
| user-service | 16/16 | ✅ All pass |
| task-service | 33/33 | ✅ All pass |
| api-gateway | health + proxy tests | ✅ Pass |
| frontend-service | 7 component test files (Vitest + RTL) | ✅ Pass |

---

## API Surface (complete — all endpoints implemented)

```
PUBLIC:
  POST /api/users              → user-service → register
  GET  /api/users              → user-service → list all users (lead only)
  POST /api/auth/login         → user-service → login, returns JWT

PROTECTED (Bearer token required):
  POST   /api/tasks                 → task-service → create task
  GET    /api/tasks                 → task-service → list (lead=all, member=own)
  GET    /api/tasks/:id             → task-service → task detail + comments array
  PATCH  /api/tasks/:id/status      → task-service → state machine enforced
  DELETE /api/tasks/:id             → task-service → lead only, 204
  POST   /api/tasks/:id/comments    → task-service → add comment, 201
  GET    /api/users/:id             → user-service → user profile (no password_hash)

HEALTH:
  GET /health  → api-gateway → { "status": "ok", "service": "api-gateway" }
```

---

## EC2 Deploy Readiness

### Single-Node (docker-compose.prod.yml)
- [x] G-02 fixed — user-service + task-service ports removed from prod compose
- [x] `.env.prod.example` created for user-service, task-service, api-gateway
- [x] Pre-deploy checklist added to `docs/docs/DEPLOYMENT.md`
- [ ] Generate real JWT_SECRET (`openssl rand -hex 32`) and populate `.env` files on EC2
- [ ] Set CORS_ORIGIN to actual EC2 IP in api-gateway/.env
- [ ] Rebuild frontend image with actual EC2 IP as `VITE_API_BASE_URL`
- [ ] Verify `docker ps` shows `0.0.0.0:8080` and `0.0.0.0:3000` — not 127.0.0.1

### 3-Node Swarm (docker-compose.stack.yml) — see DEPLOYMENT.md for cluster IPs
- [ ] Start EC2 instances — get new public IPs
- [ ] Update CORS_ORIGIN in api-gateway/.env on manager
- [ ] Rebuild + push frontend image with new manager IP
- [ ] Run `docker stack deploy`

---

## Next Session Checklist

- [ ] Perform actual EC2 deploy (single-node first)
  1. Start EC2 instance, note public IP
  2. Generate JWT_SECRET, populate `.env` files from `.env.prod.example`
  3. Rebuild frontend image with real IP
  4. `scp` env files to EC2, `docker compose -f docker-compose.prod.yml up -d`
  5. Run verification: `curl http://<IP>:8080/health`
- [ ] Consider ECS/RDS/ALB for production hardening (Phase 2 infra)
- [ ] Notion sync: IRD-000.md updated (§11 Dockerfile standard) — run `/report`
- [ ] Postman collection: update with GET /tasks/:id, DELETE /tasks/:id, POST /:id/comments

---

## Git State (as of 2026-04-24 — end of Session 3)

| Repo | Status | Last commit |
|------|--------|-------------|
| user-service | ✅ Clean | feat: implement GET /users/:id + tests (G-07) |
| task-service | ✅ Clean | feat: implement GET /tasks/:id, DELETE, POST comments + tests (G-06) |
| api-gateway | ✅ Clean | chore: add .env.prod.example for EC2 deploy prep |
| frontend-service | ✅ Clean | feat: Sprint 2 frontend — task detail, comments, register, filter bar, styles |
| docs | ✅ Clean | docs: WIP.md, EC2 pre-deploy checklist, sprint-01 integration complete |

⚠️  `docker-compose.prod.yml` (G-02 fix) lives at workspace root — NOT a git repo.
    Change is saved to disk. Track manually or initialise a root-level repo if needed.
