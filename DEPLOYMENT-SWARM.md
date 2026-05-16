# Docker Swarm Deployment Guide

Quick reference for deploying Task Manager on AWS Docker Swarm (1 Manager + 2 Workers).

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| 3 EC2 instances | 1 Manager, 2 Workers |
| Docker installed | `sudo apt install docker.io` |
| Images on Docker Hub | `chaudevops/taskmanager-*:v1.0.0` |

---

## Architecture

```
                    ┌──────────────────┐
                    │   Route 53 DNS   │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   :3000 :8080    │
                    │  (any worker)    │
                    └────────┬─────────┘
                             │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼──────┐   ┌───────▼──────┐   ┌───────▼──────┐
│  Frontend    │   │  API Gateway │   │    DBs       │
│  (replica 2)│   │ (replica 2) │   │ (manager)   │
└─────────────┘   └──────────────┘   └─────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                          │
                 ┌────────▼────────┐
                 │  Services      │
                 │  user-task     │
                 │  (replica 2)  │
                 └────────────────┘
```

---

## Step 1: Initialize Swarm (Manager)

```bash
# SSH to manager EC2
ssh -i ~/.ssh/chautv-public-ec2-kp.pem ubuntu@<MANAGER_IP>

# Initialize swarm (replace with your manager IP)
docker swarm init --advertise-addr <MANAGER_IP>

# Expected output:
# Swarm initialized: current node is now a manager.
# To add a worker to this swarm, run the following command:
#     docker swarm join --token <TOKEN> <MANAGER_IP>:2377
```

---

## Step 2: Join Workers

```bash
# On Manager - get worker join token
docker swarm join-token worker

# SSH to each Worker and run the join command:
ssh -i ~/.ssh/chautv-public-ec2-kp.pem ubuntu@<WORKER_IP>
docker swarm join --token <WORKER_TOKEN> <MANAGER_IP>:2377

# Verify on Manager:
docker node ls
```

---

## Step 3: Deploy Stack

```bash
# SSH to manager first
ssh -i ~/.ssh/chautv-public-ec2-kp.pem ubuntu@<MANAGER_IP>

# Copy compose file (if not already there)
scp docker-compose.yml ubuntu@<MANAGER_IP>:/home/ubuntu/docker-compose.yml

# Or clone the repo
git clone https://github.com/proops2026-taskmanager.git
cd proops2026-taskmanager

# Deploy with production images
REGISTRY=chaudevops TAG=v1.0.0 docker stack deploy -c docker-compose.yml taskmanager

# Or use default (builds locally):
docker stack deploy -c docker-compose.yml taskmanager
```

---

## Step 4: Verify Deployment

```bash
# List services
docker stack services taskmanager

# Check specific service
docker service ps taskmanager_api-gateway

# View logs
docker service logs taskmanager_api-gateway
```

---

## Step 5: Access Application

| Service | URL |
|---------|-----|
| Frontend | http://`<ANY_WORKER_IP>`:3000 |
| API | http://`<ANY_WORKER_IP>`:8080 |

> Note: With routing mesh, any worker IP works for port 3000/8080

---

## Common Commands

| Command | Description |
|---------|-----------|
| `docker stack ls` | List stacks |
| `docker stack ps taskmanager` | Stack tasks |
| `docker stack services taskmanager` | Stack services |
| `docker service logs <service>` | View logs |
| `docker service scale taskmanager_frontend=3` | Scale service |
| `docker stack rm taskmanager` | Remove stack |

---

## Troubleshooting

```bash
# Check service status
docker service inspect taskmanager_api-gateway

# View container logs
docker logs <container_id>

# Check node status
docker node ls

# Restart a service
docker service update --force taskmanager_api-gateway
```

---

## Quick Reference (Copy-Paste)

```bash
# === PREREQUISITE: Push images to Docker Hub first ===
# On local machine:
docker compose build
docker tag taskmanager-api-gateway:latest chaudevops/taskmanager-api-gateway:v1.0.0
docker push chaudevops/taskmanager-*:v1.0.0

# === MANAGER NODE ===
ssh -i ~/.ssh/chautv-public-ec2-kp.pem ubuntu@18.159.224.179

# Initialize swarm
docker swarm init --advertise-addr 18.159.224.179

# Clone project (has docker-compose.yml)
git clone https://github.com/proops2026-taskmanager.git
cd proops2026-taskmanager

# Deploy
REGISTRY=chaudevops TAG=v1.0.0 docker stack deploy -c docker-compose.yml taskmanager

# Verify
docker stack services taskmanager

# === WORKER NODES ===
# Run join command from manager token output
docker swarm join --token SWMTKN-xxxxx 18.159.224.179:2377
```

---

*Last updated: 2026-04-22*
*Project: proops2026-taskmanager*

# Local development
docker compose up --build -d

# Single server
REGISTRY=chaudevops TAG=v1.0.0 docker compose up -d

# Docker Swarm (auto-picks up deploy: configs)
docker stack deploy -c docker-compose.yml taskmanager
