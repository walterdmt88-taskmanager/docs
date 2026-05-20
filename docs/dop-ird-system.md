# DOP / IRD System — Task Management System

**Project:** Task Management System (Trello-like)  
**Team:** thai_dm (Walter) + chau_tv  
**Notion workspace:** https://www.notion.so/3478a3d4ee898173b9adf264643940d6  
**GitHub org:** https://github.com/proops2026-taskmanager  
**Last updated:** 2026-05-21 — Thai Doan Minh (Day 21 DOP/IRD Wrap-Up)

---

## DOP Inventory

| DOP | Title | Local path | Status | Last audited | Notes |
|---|---|---|---|---|---|
| DOP-001 | Project | `docs/docs/DOP-001.md` | ACTIVE | 2026-05-21 | Services match repo; Out of Scope and Non-Goals updated |
| DOP-002 | Containerization | `docs/docs/DOP-002.md` | ACTIVE | 2026-05-21 | Written Day 21 — Docker image policy, ECR, tagging |
| DOP-003 | Orchestration | `docs/docs/DOP-003.md` | ACTIVE | 2026-05-21 | Written Day 21 — K8s topology, HPA, Helm, secrets policy |
| DOP-004 | Cloud Infra | `docs/docs/DOP-004.md` | ACTIVE | 2026-05-21 | Written Day 21 — EKS, eu-central-1, spot t3.medium, cost guards |
| DOP-005 | IaC + Automation | — | DEFERRED | — | No Terraform built yet — write Day 26 |

---

## IRD Inventory

| IRD | Implements DOP | Component / Concern | Local path | Status | Last updated |
|---|---|---|---|---|---|
| IRD-000 | — | Program standards | `docs/docs/IRD-000.md` | ACTIVE | Day 8 |
| IRD-001 | DOP-001 | user-service | `docs/docs/IRD-001.md` | NEEDS REFRESH | Day 10 — missing GET /users/:id and GET /users/ endpoints |
| IRD-002 | DOP-001 | task-service | `docs/docs/IRD-002.md` | ACTIVE | Day 10 |
| IRD-003 | DOP-001 | api-gateway + Docker Compose + NFRs | `docs/docs/IRD-003.md` | ACTIVE | Day 10 |
| IRD-004 | DOP-001 | frontend-service | `docs/docs/IRD-004.md` | ACTIVE | Day 12 |
| IRD-005 | DOP-001 | notification-service | `docs/docs/IRD-005.md` | ACTIVE | Day 13 |
| IRD-006 | DOP-004 | AWS Infrastructure | `docs/docs/IRD-006.md` | ACTIVE | Day 16 |
| IRD-007 | DOP-003 | K8s Deployment Standards | `docs/docs/IRD-007.md` | ACTIVE | Day 15 |
| IRD-008 | DOP-003 | Helm Chart Conventions | `docs/docs/IRD-008.md` | ACTIVE | Day 15 |
| IRD-009 | DOP-002 | Docker Image Standards | `docs/docs/IRD-009.md` | ACTIVE | 2026-05-21 — written Day 21 |

### IRD Gaps

| Gap | Fix date |
|---|---|
| IRD-001: missing GET /users/:id and GET /users/ endpoint docs | Day 23 |
| IRD-009: api-gateway and user-service still use custom appuser instead of USER node | Day 26 |
| IRD-009: frontend-service nginx runs as root — fix path is nginx:unprivileged | Day 26 |
| No IRD for DOP-005 (IaC + Automation) | Day 26 |

---

## Discipline Rules — Week 5+

1. **Before first commit on any feature:** update the DOP AC status + create/update the relevant IRD.
2. **Every cross-cutting decision** (image policy, secret policy, IAM rule, K8s pattern): goes in the relevant cross-cutting IRD, not in service IRDs.
3. **Every deployed change:** linked from a Linear issue with DOP AC and IRD section cited.
4. **Every PR description:** must cite the DOP AC and IRD section it implements.
5. **Stale-spec rule:** any DOP or IRD not audited in 30 days = stale. Blocks new work in that area until refreshed.
6. **Agent rule:** Claude reads DOP-001 + relevant IRD + IRD-003 before implementing any feature. If spec is stale, refresh spec before coding.

---

## End-to-End Trace

**File:** `memory/dop-ird-trace.md`  
**Feature traced:** POST /users — user registration  
**Date:** 2026-05-21  

**Gaps found:**
1. user-service pods running `nginx:1.25.0` instead of application image — **Critical, fix Day 22**
2. user-svc Service port mismatch (80 vs 3001) — **Critical, fix Day 22**
3. Full git history not pushed — **High, fix Day 22**
4. Linear issue not linked — **Medium, fix Day 23**
5. IRD-001 missing undocumented endpoints — **Medium, fix Day 23**

---

## Skills Cheat Sheet

| Skill | Trigger | Purpose |
|---|---|---|
| `/write-dop` | New area DOP needed | Creates DOP page in Notion from template |
| `/write-ird` | New service or cross-cutting IRD needed | Creates IRD page in Notion from template |
| `/create-linear-issue` | Starting new feature | Creates Linear issue linked to DOP + IRDs |
| `/implement-linear-issue` | Implementing a Linear issue | Reads DOP + IRDs before coding |

---

## Next Audit

**Date:** End of Week 6 — Day 30  
**Scope:** Full re-audit of all 5 DOPs + all IRDs  
**Owner:** thai_dm + chau_tv
