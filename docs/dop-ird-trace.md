# Feature Trace: User Registration

**Date:** 2026-05-21  
**Feature:** POST /users — register a new user  
**Traced by:** Thai Doan Minh (Day 21 DOP/IRD Wrap-Up)

---

## Layer 1: DOP-001 (AC-01)

**Source:** `docs/docs/DOP-001.md`  
**AC:** AC-01 — New user provides valid email, password, full_name → POST /users → 201, response has id/email/full_name/role/created_at, no password_hash. Pass signal: Status 201, no password_hash in body.

---

## Layer 2: IRD-001 — user-service spec

**Source:** `docs/docs/IRD-001.md`  
**Spec:** POST /users  
- Input: `{ email: string, password: string (min 8 chars), full_name: string, role?: "member"|"lead" }`  
- Output: `201 { id: uuid, email, full_name, role, created_at }` — no password_hash  
- Errors: 400 on missing/invalid fields, 409 on duplicate email  

---

## Layer 3: Linear issue

**Status:** Not traceable — Linear issue history not available in this session.  
**Gap:** Linear issue for user registration implementation not linked from DOP-001 or IRD-001.

---

## Layer 4: Git commits

**Status:** Only one commit exists in the repo history:  
`bbcff7d Day 11 — update compose to use registry images + restart policy`  

**Gap:** Full commit history was not pushed to the repo. Individual feature commits (scaffold, registration endpoint, tests) are not traceable via `git log`.

---

## Layer 5: Running evidence

```
$ kubectl get pods -n default | grep user-service
user-service-fbfc7bf89-2mvqr   1/1   Running   0   20d
user-service-fbfc7bf89-n9dsm   1/1   Running   0   20d
```

Pods show Running / Ready. However:

```
$ kubectl get pod user-service-fbfc7bf89-2mvqr -o jsonpath='{.spec.containers[0].image}'
nginx:1.25.0
```

**Gap:** The user-service pods are running `nginx:1.25.0` — a plain nginx image, NOT the user-service application image. The pods pass health checks (nginx returns 200 on `/`) but serve no application code.

---

## Layer 6: End-to-end test

```
$ curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":"d21-trace@test.com","password":"test1234","full_name":"Day 21 Trace"}'
```

**Result:** Request hung — api-gateway proxied to `http://user-svc:3001` but `user-svc` Service exposes port 80 only, and the pod behind it runs nginx (not user-service). Registration endpoint is unreachable.

---

## Gaps Found

| # | Gap | Severity | Fix date |
|---|---|---|---|
| 1 | `user-service` pods run `nginx:1.25.0` instead of the user-service application image | Critical | Day 22 |
| 2 | `user-svc` K8s Service exposes port 80, but api-gateway config points to port 3001 | Critical | Day 22 |
| 3 | Full git commit history not pushed — only 1 commit in repo, feature commits untraceable | High | Day 22 |
| 4 | Linear issue for user registration not linked from DOP-001 or IRD-001 | Medium | Day 23 |
| 5 | IRD-001 does not document `GET /users/:id` and `GET /users/` endpoints that exist in code | Medium | Day 23 |
