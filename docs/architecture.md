# Architecture — Task Management System

> Replace this diagram with your own project's architecture.
> Mermaid renders automatically on GitHub — paste into any `.md` file.

## System diagram

```mermaid
graph TB
  subgraph Browser
    B([Browser])
  end

  subgraph "Docker Network: app-net"
    FE["frontend-service\n:3000 (host)\nnginx — serves React SPA"]
    GW["api-gateway\n:8080 (host)\nJWT validation + routing + CORS"]

    subgraph Services
      US["user-service\n:3001\n(auth, users)"]
      TS["task-service\n:3002\n(tasks, comments)"]
    end

    subgraph Databases
      UDB[("users_db\nPostgreSQL :5432")]
      TDB[("tasks_db\nPostgreSQL :5433")]
    end
  end

  B -->|"HTTP :3000 — page load (HTML/JS/CSS)"| FE
  B -->|"HTTP :8080 — API calls (XHR/fetch)"| GW
  GW -->|"HTTP — /users /auth"| US
  GW -->|"HTTP — /tasks"| TS
  US -->|SQL| UDB
  TS -->|SQL| TDB
```

> The browser makes **two kinds of requests**: static asset requests to the nginx container on port 3000, and API requests directly to api-gateway on port 8080. The frontend container does not proxy API calls — the browser JS calls the gateway directly.

## Request flow — login via web UI

```mermaid
sequenceDiagram
  participant B as Browser (React app)
  participant FE as frontend-service :3000
  participant GW as api-gateway :8080
  participant US as user-service :3001
  participant DB as users_db

  B->>FE: GET / (first load)
  FE-->>B: index.html + JS bundle
  B->>GW: POST /auth/login { email, password }
  GW->>US: POST /auth/login (no JWT required)
  US->>DB: SELECT * FROM users WHERE email=...
  DB-->>US: user row
  US-->>GW: 200 { token, user }
  GW-->>B: 200 { token, user }
  Note over B: stores token in localStorage
```

## Request flow — create a task via API (curl / Postman)

```mermaid
sequenceDiagram
  participant C as Client (curl)
  participant GW as api-gateway :8080
  participant TS as task-service :3002
  participant DB as tasks_db

  C->>GW: POST /tasks\nAuthorization: Bearer <JWT>
  GW->>GW: Validate JWT\nExtract userId, role
  GW->>TS: POST /tasks\nX-User-Id: uuid\nX-User-Role: member
  TS->>DB: INSERT INTO tasks ...
  DB-->>TS: task row
  TS-->>GW: 201 { task object }
  GW-->>C: 201 { task object }
```

## Port map

| Service | Internal port | Host port |
|---|---|---|
| frontend-service (nginx) | 80 | **3000** |
| api-gateway | 8080 | **8080** |
| user-service | 3001 | not exposed |
| task-service | 3002 | not exposed |
| users_db (PostgreSQL) | 5432 | not exposed |
| tasks_db (PostgreSQL) | 5432 | not exposed |

**Rule:** Only `frontend-service` (port 3000) and `api-gateway` (port 8080) are exposed to the host. All other services and databases are internal to the Docker network.
