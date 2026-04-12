# Mock Project Starter — ProOps2026

This repository is the **starting point for your group mock project** (Day 8 onward).

The example files use a **Task Management System**. Read them carefully — then replace every section with your own project. Do not delete the structure, only replace the content.

## This repo lives in your GitHub Organization

```
github.com/proops2026-[your-project]/
├── docs              ← THIS REPO — documents, architecture, sprint backlog
├── user-service      ← service 1 (code pushed Day 9)
├── task-service      ← service 2 (code pushed Day 9)
└── api-gateway       ← gateway   (code pushed Day 9)
```

Each service is its own repository. One organization owns everything. Trainer accounts are org Owners.

## Repository structure (this repo)

```
docs/
  INDEX.md            ← Document map — read this first
  DOP-001.md          ← Definition of Product  (whole product, one DOP)
  IRD-001.md          ← user-service spec       (one IRD per service)
  IRD-002.md          ← task-service spec
  IRD-003.md          ← gateway + infrastructure + NFRs
  architecture.md     ← Mermaid system diagram
  sprint-01.md        ← Sprint 1 backlog (manual; Linear takes over Day 10)
CLAUDE.md             ← Context document: Claude reads this before every task
```

## How to use this repo

1. **Day 8** — Replace example content with your project. Push to `docs` repo in your org. Include org URL in your end-of-day report.
2. **Day 9** — Claude Code reads `CLAUDE.md` + `docs/DOP-001.md` + the relevant IRD before every task
3. **Day 10–11** — Your sprint-01.md tasks become Linear issues via `/create-linear-issue`
4. **Day 9–40** — Add new IRDs when you start new services or technical topics

## The rule

> Claude Code reads DOP + IRD before implementing. If a requirement is not written in the document, Claude will guess. Every time Claude guesses wrong, add the missing requirement to the document.

## Group members

| Role | Name |
|---|---|
| Person A | _(your name)_ |
| Person B | _(partner name)_ |
