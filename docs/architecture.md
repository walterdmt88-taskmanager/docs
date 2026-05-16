# Architecture — Task Management System

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
      NS["notification-service\n:3003\n(Discord notifications)"]
    end

    subgraph Databases
      UDB[("users_db\nPostgreSQL :5432")]
      TDB[("tasks_db\nPostgreSQL :5432")]
    end

    RD[("Redis :6379\nStream: task:events")]
  end

  DSC([Discord Webhook])

  B -->|"HTTP :3000 — page load"| FE
  B -->|"HTTP :8080 — API calls"| GW
  GW -->|"/users /auth"| US
  GW -->|"/tasks"| TS
  US -->|SQL| UDB
  TS -->|SQL| TDB
  TS -->|"XADD task:events"| RD
  RD -->|"XREADGROUP"| NS
  NS -->|"POST webhook"| DSC
```

**Key design decision:** `notification-service` never receives HTTP calls from `api-gateway`.
It is a pure background consumer — it reads from Redis Stream and pushes to Discord.
The HTTP port (3003) exists only for Kubernetes health checks (`/health`).

---

## Event flow — notification pipeline

```mermaid
sequenceDiagram
  participant C as Client
  participant GW as api-gateway
  participant TS as task-service
  participant RD as Redis Stream
  participant NS as notification-service
  participant DSC as Discord

  C->>GW: POST /tasks (create task)
  GW->>TS: POST /tasks (+ X-User-Id header)
  TS->>TS: INSERT into tasks_db
  TS-->>GW: 201 { task }
  GW-->>C: 201 { task }
  TS-)RD: XADD task:events * event task.created ...
  Note over TS,RD: fire-and-forget — does not block response
  RD-)NS: XREADGROUP (consumer group)
  NS->>DSC: POST webhook { embed: "📋 New Task Created" }
```

Events published to `task:events` stream:

| Event | Trigger |
|---|---|
| `task.created` | `POST /tasks` |
| `task.status_updated` | `PATCH /tasks/:id/status` |
| `comment.created` | `POST /tasks/:id/comments` |

---

## Request flow — login via web UI

```mermaid
sequenceDiagram
  participant B as Browser
  participant FE as frontend-service :3000
  participant GW as api-gateway :8080
  participant US as user-service :3001
  participant DB as users_db

  B->>FE: GET / (first load)
  FE-->>B: index.html + JS bundle
  B->>GW: POST /auth/login { email, password }
  GW->>US: POST /auth/login
  US->>DB: SELECT * FROM users WHERE email=...
  DB-->>US: user row
  US-->>GW: 200 { token, user }
  GW-->>B: 200 { token, user }
  Note over B: stores token in localStorage
```

---

## Request flow — create a task

```mermaid
sequenceDiagram
  participant C as Client
  participant GW as api-gateway :8080
  participant TS as task-service :3002
  participant DB as tasks_db

  C->>GW: POST /tasks\nAuthorization: Bearer <JWT>
  GW->>GW: Validate JWT\nExtract userId, role
  GW->>TS: POST /tasks\nX-User-Id: uuid\nX-User-Role: member
  TS->>DB: INSERT INTO tasks ...
  DB-->>TS: task row
  TS-->>GW: 201 { task }
  GW-->>C: 201 { task }
```

---

## Port map

| Service | Internal port | Host port | Notes |
|---|---|---|---|
| frontend-service (nginx) | 3000 | **3000** | Serves React SPA |
| api-gateway | 8080 | **8080** | Only entry point for API |
| user-service | 3001 | not exposed | Internal only |
| task-service | 3002 | not exposed | Internal only |
| notification-service | 3003 | not exposed | Health check only |
| Redis | 6379 | not exposed | Internal only |
| users_db (PostgreSQL) | 5432 | not exposed | Internal only |
| tasks_db (PostgreSQL) | 5432 | not exposed | Internal only |

**Rule:** Only `frontend-service` and `api-gateway` are exposed to the host.
All other services, databases, and Redis are internal to the Docker/K8s network.

---

## Kubernetes layout (EKS)

```
EKS Cluster (default namespace)
├── Deployments
│   ├── frontend-service      (1 replica)
│   ├── api-gateway           (1 replica)
│   ├── user-service          (1 replica)
│   ├── task-service          (1 replica)
│   └── notification-service  (1 replica)
├── StatefulSets / Helm releases
│   ├── users-db   (PostgreSQL via manifest)
│   ├── tasks-db   (PostgreSQL via manifest)
│   └── redis      (Bitnami Helm chart → redis-master:6379)
├── Services (all ClusterIP)
│   ├── frontend-svc        :3000
│   ├── api-gw-svc          :8080
│   ├── user-svc            :3001
│   ├── task-svc            :3002
│   ├── notification-svc    :3003
│   ├── users-db-svc        :5432
│   ├── tasks-db-svc        :5432
│   └── redis-master        :6379
└── Ingress (AWS ALB)
    ├── /api  → api-gw-svc:8080
    └── /     → frontend-svc:3000
```
