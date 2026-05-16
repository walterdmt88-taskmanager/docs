# WIP — Task Management System

**Last updated:** 2026-05-10 (Session 12)
**Session history:** `logs/daily/` — one file per session date

---

## Sprint Phase Status

| Phase | Status | Notes |
|-------|--------|-------|
| Sprint 1 (T-01→T-19) | ✅ Complete | 19/19 tasks done; tests pass |
| Sprint 2 (F-01→F-09) | ✅ Complete | Frontend + component tests (Vitest + RTL) |
| K8s / minikube | ✅ Complete (2026-04-26) | 33/33 E2E pass; automation scripts live |
| EKS | ✅ Complete (2026-04-30) | 11/11 E2E pass; cluster torn down (cost) |
| Bash Automation Labs | ✅ Complete (2026-05-06) | 4 scripts pushed — commit `01722d5` |
| Helm Labs (7.17, 7.19, 8.1) | ✅ Complete (2026-05-09) | `charts/taskmanager/` 13-file chart |
| Week 7 Mon–Wed (Networking + Monitoring) | ✅ Complete (2026-05-07) | DNS, NetworkPolicies, Prometheus, Grafana |
| Week 8 Mon (Namespaces + Quota + HPA) | ✅ Complete (2026-05-10) | `taskmanager-prod` ns, LimitRange, ResourceQuota, HPA |
| Week 8 — Load Testing (Lab 8.7) | ✅ Complete (2026-05-10) | hey pod, 3-service load, 16 peak pods, full scale-up + scale-down cycle |
| deploy-eks.sh Refactor | ✅ Complete (2026-05-10) | 537-line monolith → 65-line orchestrator + 4 lib files |
| Week 7 Thu (prom-client + ServiceMonitor) | ☐ Next | Add /metrics, ServiceMonitor, Grafana Panel 5 |
| Week 7 Fri (Loki + Promtail) | ☐ Pending | loki-stack Helm; LogQL |
| Week 7 Weekend (PrometheusRules + alerts) | ☐ Pending | Alert rules + dashboard export |

---

## Known Gaps (Open)

| Gap | Description | Priority |
|-----|-------------|----------|
| G-09 | EKS Deployments have no `podAntiAffinity` — both replicas may land on same node | Low (lab env) |
| G-10 | EKS api-gateway `CORS_ORIGIN=*` — reset to ELB hostname before real traffic | Low (lab env) |
| G-11 | `frontend-service/Dockerfile` HEALTHCHECK uses `localhost` — fails in Alpine (IPv6) | Medium — commit fix |

---

## Next Session Checklist

- [ ] **Week 7 Thursday** — prom-client: add `/metrics` to user-service + task-service; create ServiceMonitor; wire Grafana Panel 5
- [ ] **Week 7 Friday** — Loki + Promtail: `loki-stack` Helm chart; Loki datasource in Grafana; LogQL queries
- [ ] **Week 7 Weekend** — PrometheusRules: alert rules + comprehensive dashboard export JSON
- [ ] Fix G-11: commit `frontend-service/Dockerfile` localhost→127.0.0.1 fix
- [ ] Push IRD-000.md + IRD-003.md changes to Notion (CORS + E2E timeout rules)
- [ ] Postman collection: add GET /tasks/:id, DELETE /tasks/:id, POST /:id/comments
- [ ] Commit `scripts/deploy-eks.sh` refactor + `scripts/lib/` (4 new files)
- [ ] K6 performance test scripts: build `perf-tests/k6/task-journey.js` (register→login→create task→status update with JWT extraction + SLO thresholds)

---

## Git State (as of 2026-05-10)

| Repo | Status |
|------|--------|
| user-service | ✅ clean |
| task-service | ✅ clean |
| api-gateway | ✅ clean |
| frontend-service | ⚠️ 1 uncommitted — `Dockerfile` localhost→127.0.0.1 (G-11) |
| docs | ⚠️ uncommitted — WIP.md, IRD-000.md, grafana-dashboard-taskmanager.json, labs/ |
| scripts | ⚠️ uncommitted — `deploy-eks.sh` (rewritten) + `lib/` (4 new files: eks-data, eks-app, eks-infra, eks-common) |
| eks/, k8s/, charts/, e2e-tests/ | On disk at workspace root — not a git repo |

---

## API Surface

```
PUBLIC:
  POST /api/users           → user-service → register
  GET  /api/users           → user-service → list all users (lead only)
  POST /api/auth/login      → user-service → login, returns JWT

PROTECTED (Bearer token):
  POST   /api/tasks              → task-service → create task
  GET    /api/tasks              → task-service → list (lead=all, member=own)
  GET    /api/tasks/:id          → task-service → task detail + comments array
  PATCH  /api/tasks/:id/status   → task-service → state machine enforced
  DELETE /api/tasks/:id          → task-service → lead only, 204
  POST   /api/tasks/:id/comments → task-service → add comment, 201
  GET    /api/users/:id          → user-service → user profile (no password_hash)

HEALTH:
  GET /health → api-gateway → { "status": "ok", "service": "api-gateway" }
```
