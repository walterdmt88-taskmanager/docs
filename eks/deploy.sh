#!/usr/bin/env bash
set -e

MANIFESTS="/Users/mac/Desktop/proops2026-taskmanager/eks/manifests"
DB_PASS="taskmanager_pass_2026"
JWT_SECRET="taskmanager_jwt_secret_2026"

echo "=== Step 1: Create Secrets ==="
kubectl create secret generic api-gw-secret \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic db-task-secret \
  --from-literal=POSTGRES_PASSWORD="$DB_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic db-user-secret \
  --from-literal=POSTGRES_PASSWORD="$DB_PASS" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic task-svc-secret \
  --from-literal=DATABASE_URL="postgresql://app_user:${DB_PASS}@db-task:5432/tasks_db" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic user-svc-secret \
  --from-literal=DATABASE_URL="postgresql://app_user:${DB_PASS}@db-user:5432/users_db" \
  --from-literal=JWT_SECRET="$JWT_SECRET" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "=== Step 2: Apply ConfigMaps ==="
kubectl apply -f "$MANIFESTS/api-gw-cm.yaml"
kubectl apply -f "$MANIFESTS/task-svc-cm.yaml"
kubectl apply -f "$MANIFESTS/user-svc-cm.yaml"
kubectl apply -f "$MANIFESTS/db-task-cm.yaml"
kubectl apply -f "$MANIFESTS/db-user-cm.yaml"

echo "=== Step 3: Apply StatefulSets (DBs) ==="
kubectl apply -f "$MANIFESTS/db-task-statefulset.yaml"
kubectl apply -f "$MANIFESTS/db-user-statefulset.yaml"

echo "=== Step 4: Apply App Deployments ==="
kubectl apply -f "$MANIFESTS/task-svc-deployment.yaml"
kubectl apply -f "$MANIFESTS/user-svc-deployment.yaml"
kubectl apply -f "$MANIFESTS/api-gw-deployment.yaml"
kubectl apply -f "$MANIFESTS/frontend-deployment.yaml"

echo "=== Step 5: Install Helm Redis ==="
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo update
helm upgrade --install my-redis bitnami/redis \
  -f "$MANIFESTS/my-redis-values.yaml" \
  --wait --timeout=5m

echo ""
echo "=== All resources applied. Checking status... ==="
kubectl get pods
kubectl get svc
