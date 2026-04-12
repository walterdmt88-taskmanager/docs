# Project Context — [Your Project Name]

> Replace every line in this file with your project's details before Day 9.
> Claude Code reads this file before every implementation task.

## What this system is

**Project name:** Task Management System  
**Group:** chau_tv + thai_dm  
**Program day start:** Day 9

A REST API that lets teams create, assign, and track tasks. Teams currently track tasks in chat tools (Slack, Discord) — tasks get buried in messages and there is no way to see who is responsible for what. This system solves that.

## Document system

See `docs/INDEX.md` for the full document map.

| Document | Location | Purpose |
|---|---|---|
| DOP-001 | `docs/DOP-001.md` | What we are building and why — read before any feature work |
| IRD-001 | `docs/IRD-001.md` | user-service spec — API contract, data model, auth rules |
| IRD-002 | `docs/IRD-002.md` | task-service spec — API contract, data model, status rules |
| IRD-003 | `docs/IRD-003.md` | Gateway, Docker Compose, NFRs (applies to ALL services) |
| Architecture | `docs/architecture.md` | System diagram — service layout and connections |
| Sprint backlog | `docs/sprint-01.md` | Current sprint tasks and assignments |

**Rule:** Before implementing any feature, read DOP-001 + the IRD for the service you are working on + IRD-003 (NFRs apply everywhere).

## Services

| Service | Port | Responsibility |
|---|---|---|
| api-gateway | 3000 | Routes requests to services, handles JWT auth middleware |
| user-service | 3001 | User registration, login, JWT issuance |
| task-service | 3002 | Task CRUD, assignment, status transitions |

## Technology stack

- **Language:** Node.js 20 (TypeScript)
- **Framework:** Express 4
- **Database:** PostgreSQL 16
- **Auth:** JWT (jsonwebtoken, bcryptjs)
- **Container:** Docker + Docker Compose
- **Testing:** Jest + Supertest

## Rules for Claude Code

1. Read `docs/DOP-001.md` and `docs/IRD-001.md` before implementing any feature
2. Every service must have a `/health` endpoint returning `{ status: "ok" }`
3. No hardcoded secrets — all config via environment variables in `.env`
4. Every new endpoint must have at least one integration test
5. Follow the API contract in IRD-001 exactly — do not invent new endpoints
6. Cross-service references store only the foreign ID — no shared database tables

## Current sprint

See `docs/sprint-01.md` for the current sprint backlog and task assignments.
