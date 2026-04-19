# Deployment Guide — Task Management System

## Local Development

```bash
docker compose up --build
# UI:  http://localhost:3000
# API: http://localhost:8080
```

All services hot-reload. Databases start with migrations auto-applied via initdb mount.

---

## Single-Node EC2 (docker-compose.prod.yml)

Uses pre-built hub images. No build on server. `.env` files delivered via `scp`.

```bash
# From local machine
scp -i ~/.ssh/chautv-public-ec2-kp.pem \
  api-gateway/.env user-service/.env task-service/.env \
  ec2-user@<EC2_IP>:~/taskmanager/

# On EC2
docker compose -f docker-compose.prod.yml up -d
```

**Security Group minimum:** SSH (22 from my IP), 8080 (API), 3000 (UI).

**Port binding rule:** Verify `docker ps` shows `0.0.0.0:PORT` not `127.0.0.1:PORT`.
If `127.0.0.1` appears, external traffic is silently dropped even with SG open.

---

## 3-Node Docker Swarm (docker-compose.stack.yml)

### Cluster

| Node | Instance ID | Private IP | Public IP | Role |
|------|------------|------------|-----------|------|
| Manager | i-0d8cbb95c2fc63602 | 172.31.7.79 | 18.159.224.179 | Swarm brain + DBs |
| Worker 1 | i-0e7c184e1f7d7aac8 | 172.31.44.26 | 63.180.233.122 | Compute |
| Worker 2 | i-0ae39149d4015d64a | 172.31.36.206 | 18.193.130.216 | Compute |

### Security Group: chautv-swarm-sg (sg-0204f311d3f0d98d8)

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | My IP | SSH admin |
| 2377 | TCP | 172.31.0.0/16 | Swarm cluster management |
| 7946 | TCP+UDP | 172.31.0.0/16 | Node-to-node discovery |
| 4789 | UDP | 172.31.0.0/16 | VXLAN overlay traffic |
| 8080 | TCP | 0.0.0.0/0 | API Gateway (public) |
| 3000 | TCP | 0.0.0.0/0 | Frontend UI (public) |

### Service Placement

| Service | Replicas | Runs On | Why |
|---------|----------|---------|-----|
| frontend-service | 2 | workers | stateless nginx |
| api-gateway | 2 | workers | stateless |
| user-service | 2 | workers | stateless |
| task-service | 2 | workers | stateless |
| db-user | 1 | manager (pinned) | named volume = node-local data |
| db-task | 1 | manager (pinned) | named volume = node-local data |

### Deploy

```bash
# 1. Transfer files to manager
scp -i ~/.ssh/chautv-public-ec2-kp.pem \
  docker-compose.stack.yml \
  api-gateway/.env user-service/.env task-service/.env \
  ec2-user@18.159.224.179:~/taskmanager/

# 2. On manager — deploy stack
docker stack deploy -c docker-compose.stack.yml --with-registry-auth taskmanager

# 3. Watch rollout
watch docker stack services taskmanager

# 4. Verify (any node IP works — routing mesh)
curl http://18.159.224.179:8080/health
curl http://18.159.224.179:3000/health
```

### Redeploy after changes

```bash
# Service image updated — redeploy (only changed services restart)
docker stack deploy -c docker-compose.stack.yml --with-registry-auth taskmanager

# Remove stack entirely
docker stack rm taskmanager
```

### ⚠️ Frontend Image Build — CRITICAL

`VITE_API_BASE_URL` is baked into the React bundle at Vite build time.
**The image must be rebuilt whenever the manager's public IP changes.**

```bash
cd frontend-service
docker buildx build \
  --platform linux/amd64 \
  --build-arg VITE_API_BASE_URL="http://<MANAGER_PUBLIC_IP>:8080" \
  -t chaudevops/taskmanager-frontend-service:v1.0.0 \
  --push .
```

Production fix: assign an Elastic IP to the manager so the URL never changes.

### CORS configuration

`CORS_ORIGIN` in `api-gateway/.env` must match the public URL users access the frontend from:

```
CORS_ORIGIN=http://18.159.224.179:3000
```

Update and redeploy api-gateway if the manager IP changes.

---

## Verification Checklist

```bash
MANAGER=18.159.224.179

# All services healthy
docker stack services taskmanager   # all REPLICAS show X/X

# API reachable
curl http://$MANAGER:8080/health    # {"status":"ok","service":"api-gateway"}

# Frontend reachable
curl -s -o /dev/null -w "%{http_code}" http://$MANAGER:3000/health   # 200

# Routing mesh — worker IPs also work
curl -s -o /dev/null -w "%{http_code}" http://63.180.233.122:3000/health    # 200
curl -s -o /dev/null -w "%{http_code}" http://18.193.130.216:3000/health    # 200

# Full flow
TOKEN=$(curl -s -X POST http://$MANAGER:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"email":"verify@test.com","password":"Test1234!","name":"Verify"}' | jq -r '.token')
curl -s http://$MANAGER:8080/api/tasks \
  -H "Authorization: Bearer $TOKEN" | jq .total
```

---

## Known Constraints

| Constraint | Detail |
|------------|--------|
| IP-baked frontend | Image tied to one public IP — needs rebuild on IP change |
| t3.micro RAM | 1 GB per node — do not add more services to manager |
| Named volumes node-local | DB data stays on manager; if manager replaced, data lost |
| No Elastic IP | Public IPs change on stop/start — stop instances, don't terminate |

---

## Instance Management

```bash
# Stop (preserves data volumes, same instance ID)
aws ec2 stop-instances --instance-ids \
  i-0d8cbb95c2fc63602 i-0e7c184e1f7d7aac8 i-0ae39149d4015d64a

# Start
aws ec2 start-instances --instance-ids \
  i-0d8cbb95c2fc63602 i-0e7c184e1f7d7aac8 i-0ae39149d4015d64a

# Get new public IPs after start
aws ec2 describe-instances \
  --instance-ids i-0d8cbb95c2fc63602 i-0e7c184e1f7d7aac8 i-0ae39149d4015d64a \
  --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress]' \
  --output table
```
