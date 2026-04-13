# Architecture — Task Management System

> Replace this diagram with your own project's architecture.
> Mermaid renders automatically on GitHub — paste into any `.md` file.

## System diagram

```mermaid
graph TB
  subgraph Internet
    Client([Client / API Consumer])
  end

  subgraph Docker Network: app-net
    GW["api-gateway\n:8080\n(JWT validation + routing)"]

    subgraph Services
      US["user-service\n:3001\n(auth, users)"]
      TS["task-service\n:3002\n(tasks, comments)"]
    end

    subgraph Databases
      UDB[("users_db\nPostgreSQL :5432")]
      TDB[("tasks_db\nPostgreSQL :5433")]
    end
  end

  Client -->|HTTPS :8080| GW
  GW -->|HTTP — /users /auth| US
  GW -->|HTTP — /tasks| TS
  US -->|SQL| UDB
  TS -->|SQL| TDB
```

## Request flow — create a task

```mermaid
sequenceDiagram
  participant C as Client
  participant GW as api-gateway :3000
  participant TS as task-service :3002
  participant DB as tasks_db

  C->>GW: POST /api/tasks\nAuthorization: Bearer <JWT>
  GW->>GW: Validate JWT\nExtract userId, role
  GW->>TS: POST /tasks\nX-User-Id: uuid\nX-User-Role: member
  TS->>DB: INSERT INTO tasks ...
  DB-->>TS: task row
  TS-->>GW: 201 { task object }
  GW-->>C: 201 { task object }
```

## Port map

| Service | Internal port | Host port (dev only) |
|---|---|---|
| api-gateway | 8080 | 8080 |
| user-service | 3001 | not exposed |
| task-service | 3002 | not exposed |
| users_db (PostgreSQL) | 5432 | not exposed |
| tasks_db (PostgreSQL) | 5432 | not exposed |

**Rule:** In production, only the gateway is exposed. Services and databases are internal to the Docker network.
