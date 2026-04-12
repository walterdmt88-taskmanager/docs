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
| DOP-001 | [DOP-001.md](DOP-001.md) | Whole product — problem, users, services, acceptance criteria | Active |

> Add a new DOP row when you start a major new product area (e.g., a second product, a major redesign).
> For most groups, DOP-001 covers the full program.

---

## IRDs — Implementation Requirements

| # | File | Covers | Linked to |
|---|---|---|---|
| IRD-001 | [IRD-001.md](IRD-001.md) | user-service — registration, login, JWT issuance, users table | DOP-001 AC-01, AC-02 |
| IRD-002 | [IRD-002.md](IRD-002.md) | task-service — task CRUD, comments, status transitions, data model | DOP-001 AC-03 to AC-07 |
| IRD-003 | [IRD-003.md](IRD-003.md) | api-gateway, Docker Compose, env config, NFRs (applies to all services) | DOP-001 all |

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
