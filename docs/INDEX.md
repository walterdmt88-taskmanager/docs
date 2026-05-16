# Document Index — Task Management System

> This file is the map of your document system.
> Update it every time you add a DOP or IRD.
> Claude Code reads this index to know which document to load for a given task.

---

## How to read this index

```
DOP-001  ←  What we are building (the whole product)
  │
  ├── IRD-001  ←  How user-service is built
  ├── IRD-002  ←  How task-service is built
  └── IRD-003  ←  How the gateway and infrastructure work
```

Before implementing anything, Claude reads:
- `DOP-001.md` — to understand the goal
- The relevant IRD — to understand the exact spec for this service or topic

---

## DOPs — Definition of Product

| # | File | Scope | Status |
|---|---|---|---|
| DOP-001 | [DOP-001.md](DOP-001.md) | Whole product — problem, users, services, acceptance criteria | NEEDS REFRESH (3 gaps — audited 2026-05-15) |

> Add a new DOP row when you start a major new product area (e.g., a second product, a major redesign).
> Area DOPs (DOP-002 to DOP-005) live in the hub repo `chautv-proops2026/program-standards/day-29/`.

---

## IRDs — Implementation Requirements

| # | File | Covers | Linked to | Status |
|---|---|---|---|---|
| IRD-000 | [IRD-000.md](IRD-000.md) | Program standards — CLAUDE.md, daily log, training spec | DOP-000 | Active |
| IRD-001 | [IRD-001.md](IRD-001.md) | user-service — registration, login, JWT issuance, users table | DOP-001 AC-01, AC-02 | Active |
| IRD-002 | [IRD-002.md](IRD-002.md) | task-service — task CRUD, comments, status transitions, data model | DOP-001 AC-03 to AC-07 | Active |
| IRD-003 | [IRD-003.md](IRD-003.md) | api-gateway, Docker Compose, env config, NFRs (applies to all services) | DOP-001 all | NEEDS REFRESH (AC-14 not implemented) |
| IRD-004 | [IRD-004.md](IRD-004.md) | frontend-service — React SPA, nginx, login + dashboard + forms | DOP-001 AC-08 to AC-13 | Active |
| IRD-005 | [IRD-005.md](IRD-005.md) | Kubernetes manifests — Deployments, StatefulSets, Ingress, NetworkPolicies, Helm Redis | DOP-001, DOP-002 | Active (written 2026-05-15) |
| IRD-006 | [IRD-006.md](IRD-006.md) | AWS Infrastructure — EC2 Swarm, EKS, ECS Fargate, Terraform basics, IAM | DOP-002 | Active (written 2026-05-15) |
| IRD-007 | [IRD-007.md](IRD-007.md) | K8s Deployment Standards — resource limits, probes, namespace, ConfigMap/Secret rules (cross-cutting) | DOP-003 | Active (written 2026-05-15) |
| IRD-008 | [IRD-008.md](IRD-008.md) | Helm Chart Conventions — values override file, release name, upgrade/rollback runbook for bitnami/redis (cross-cutting) | DOP-003 | Active (written 2026-05-15) |

> Add a new IRD row when you start a new service or a new technical topic (e.g., CI/CD pipeline, observability, auth deep-dive).
> Each IRD is small and focused. If an IRD grows past ~150 lines, split it.

---

## When to add a new IRD

| Situation | Action |
|---|---|
| You are about to build a new service | Write IRD-N for that service before writing any code |
| You are adding a cross-cutting concern (logging, tracing, rate limiting) | Write a new IRD scoped to that concern |
| An IRD has grown too large and mixes multiple responsibilities | Split it |
| You are changing an existing API contract | Update the relevant IRD first, then implement |

---

## Other documents

| File | Purpose |
|---|---|
| [architecture.md](architecture.md) | Mermaid system diagram — updated whenever services or connections change |
| [sprint-01.md](sprint-01.md) | Sprint 1 backlog — tasks, owners, Definition of Done |
