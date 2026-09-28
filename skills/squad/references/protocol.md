# Squad Protocol -- board and handoff templates

All group-mode state lives in `.squad/` at the project root so any agent (Claude Code, Codex,
Antigravity) can pick up a run where another left off.

```
.squad/
  board.md              # the plan and live status (Squad Lead owns it; agents update only their row)
  handoffs/
    01-priya.md
    02-arjun.md
    04a-ben.md        # "a" suffix = fix-loop rerun
  archive/<timestamp>/  # finished or abandoned runs
  memory/               # long-term memory, kept across runs (see memory.md)
    team.md             # shared facts for every agent
    <agent>.md          # each agent's own notebook
```

## board.md template

```markdown
# Squad Board
Mission: <one-sentence task as the user stated it>
Workflow: <feature | bugfix | audit | ship | design | api | team:<spec>>
Mode: <checkpoints | auto>
Started: <YYYY-MM-DD HH:MM>
Status: in-progress

| # | Agent | Role | Status | Handoff | Note |
|---|-------|------|--------|---------|------|
| 01 | priya | Product Strategist | done | handoffs/01-priya.md | |
| 02 | arjun | Software Architect | active | | |
| 03 | diana | Data Engineer | skipped | | no schema change |
| 04 | ben + fiona | Backend + Frontend | pending | | ben owns /api, fiona owns /web |
| 05 | quinn | QA & Test Engineer | pending | | |

## Checkpoint log
- <time> after 02-arjun: user approved design
```

Status values: `pending`, `active`, `done`, `skipped` (with reason), `blocked` (with reason).

## Handoff template (`handoffs/NN-<agent>.md`)

```markdown
# NN - <Agent> (<Role>)

## Summary
2-5 lines: what this stage did and the outcome.

## Decisions
- Decision -- reason (and alternatives rejected, if relevant).

## Artifacts
- path/to/file.ext -- created | modified | deleted -- purpose
- Verification: command run + result (paste the key output lines)

## Risks & open questions
- Anything uncertain, disagreed with, or deferred.

## Notes for next stage
- What the next agent must know or do first. Name the owner if work is being routed.
```

## Rules for every agent
1. Read the board and all earlier handoffs before starting.
2. Stay inside your stage; disagreements go in *Risks & open questions*, not silent rewrites.
3. Evidence over claims: verification output belongs in Artifacts.
4. Update only your own row on the board.
5. Recall `.squad/memory/` before starting and record durable facts before finishing ([memory.md](memory.md)).
