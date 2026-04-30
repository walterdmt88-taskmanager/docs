# WIP — Task Management System

**Last updated:** 2026-04-30
**Updated by:** Session 5 (chau_tv) — EKS Multi-Node + E2E Full Pass

---

## Sprint Status

### Sprint 1 (T-01→T-19) — ✅ COMPLETE

All 19 tasks done. Tests pass. Full stack runs via `docker compose up`.

### Sprint 2 (F-01→F-09 + D-01→D-05 + F-10→F-11) — ✅ COMPLETE

All frontend tasks done. 3-stage Dockerfiles upgraded. `docker-compose.yml` includes frontend-service. Component tests pass (Vitest + RTL).

### K8s Phase — ✅ COMPLETE (2026-04-26)

minikube cluster running, 33/33 Playwright E2E tests passing, all automation scripts deployed.

### EKS Phase — ✅ COMPLETE (2026-04-30)

AWS EKS cluster (taskmanager-chau-lab, eu-central-1, 2× t3.medium Spot nodes). All 4 Deployments at 2 replicas. 11/11 Playwright E2E pass in headed Chromium demo mode. 11/11 regression tests pass via curl against ELB.

---

## K8s Automation Scripts

| Script | Location | Status |
|--------|----------|--------|
| `deploy.sh` | `k8s/scripts/deploy.sh` | ✅ Done — 10-step single-command bootstrap |
| `teardown.sh` | `k8s/scripts/teardown.sh` | ✅ Done — wipe all K8s resources; `--all` deletes minikube |
| `health-check.sh` | `k8s/scripts/health-check.sh` | ✅ Done — API smoke test: register→login→tasks→frontend |
| `run-demo.sh` | `e2e-tests/run-demo.sh` | ✅ Done — DEMO_MODE=true, headed, 1s slowMo, Chromium |

```bash
# Single-command deploy
./k8s/scripts/deploy.sh

# Visual E2E demo
./e2e-tests/run-demo.sh
```

---

## Known Gaps

| Gap | Description | Status |
|-----|-------------|--------|
| G-02 | `docker-compose.prod.yml` exposed ports 3001/3002 for user-service + task-service | ✅ Fixed 2026-04-24 |
| G-06 | task-service missing GET /tasks/:id, DELETE /tasks/:id, POST /tasks/:id/comments | ✅ Fixed 2026-04-24 — 33/33 tests pass |
| G-07 | user-service missing GET /users/:id implementation + tests for GET /users | ✅ Fixed 2026-04-24 — 16/16 tests pass |
| G-08 | api-gateway CORS Allow-Headers missing `x-user-id` and `x-user-role` (v1 image) | ✅ Fixed 2026-04-30 — rebuilt as api-gateway:v2, deployed to EKS |
| G-09 | EKS Deployments have no podAntiAffinity — both replicas may land on same node | ⚠️ Open — documented, not yet applied to manifests |
| G-10 | EKS api-gateway CORS_ORIGIN is `*` (set for E2E testing) — should be ELB hostname for production | ⚠️ Open — reset before any real user traffic |

---

## Test Coverage (current)

| Service | Tests | Status |
|---------|-------|--------|
| user-service | 16/16 | ✅ All pass |
| task-service | 33/33 | ✅ All pass |
| api-gateway | health + proxy tests | ✅ Pass |
| frontend-service | 7 component test files (Vitest + RTL) | ✅ Pass |
| E2E (Playwright) | 33/33 minikube / 11/11 EKS | ✅ All pass on K8s + EKS (Chromium) |

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

- [x] Run `!hub-sync` — 13 `#new` patterns propagated; ledger CLEAN (2026-04-30)
- [ ] Fix G-09: add `podAntiAffinity` to all 4 Deployment manifests in `eks/manifests/`
- [ ] Fix G-10: reset `CORS_ORIGIN` on EKS api-gateway from `*` to ELB hostname (`kubectl set env deployment/api-gateway CORS_ORIGIN=<elb-hostname>`)
- [ ] Postman collection: update with GET /tasks/:id, DELETE /tasks/:id, POST /:id/comments
- [ ] Commit api-gateway/src/app.ts (CORS fix) and docs changes
- [ ] Push IRD-000.md and IRD-003.md changes to Notion (CORS + E2E timeout rules)
- [ ] Consider ECS/RDS/ALB for production hardening (Phase 2 infra)

---

## Git State (as of 2026-04-30 — end of Session 5)

| Repo | Status | Notes |
|------|--------|-------|
| user-service | ✅ Clean | All previous uncommitted files committed |
| task-service | ✅ Clean | All previous uncommitted files committed |
| api-gateway | ⚠️ 1 uncommitted file | `src/app.ts` — CORS Allow-Headers fix (G-08, api-gateway:v2) |
| frontend-service | ✅ Clean | All previous uncommitted files committed |
| docs | ⚠️ 3 uncommitted files | `WIP.md`, `docs/IRD-000.md`, `docs/IRD-003.md` — Session 5 updates |
| eks/manifests/ | ✅ On disk (workspace root — not a git repo) | ingress.yaml split, all Deployment manifests |
| eks/regression-test.sh | ✅ On disk (workspace root — not a git repo) | 11-step curl smoke test |
| e2e-tests/ | ✅ On disk (workspace root — not a git repo) | complete-workflow.spec.ts timeout fix |

⚠️  `eks/`, `k8s/`, `e2e-tests/` live at workspace root — NOT a git repo.
    Changes are saved to disk. Initialise a root-level repo if these need version control.
