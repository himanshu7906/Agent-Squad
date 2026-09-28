# Squad Memory

The agents have no memory of their own between sessions. The AI model forgets everything when a
chat ends, and a Claude Code sub-agent starts every stage with an empty context. The squad
remembers by writing plain files into the project, which every tool (Claude Code, Codex,
Antigravity) can read.

## Three layers

| Layer | Where | Lifetime | Written by | Holds |
|---|---|---|---|---|
| Working memory | the model's context window | one chat / one sub-agent | the model | everything it is thinking about right now |
| Run memory | `.squad/board.md`, `.squad/handoffs/` | one `/squad` run, then archived | each agent (its own handoff + board row) | plan, status, decisions and outputs of this run |
| Long-term memory | `.squad/memory/` | permanent, committed to git | agents after each task; Leo consolidates | durable facts about this project |

## Long-term memory files

```
.squad/memory/
  team.md      # shared by all agents: stack, run/test/build commands, conventions, key decisions
  priya.md     # each agent's own notebook for its domain
  arjun.md
  sara.md
  ...
```

Example `sara.md`:

```markdown
# Sara -- security notebook
- 2026-09-28: Auth is JWT in httpOnly cookies, 15-min access / 7-day refresh; refresh rotation on.
- 2026-09-28: Accepted risk: /metrics is unauthenticated on the internal network (owner: Omar).
- 2026-10-02: Fixed IDOR in GET /orders/:id (now scoped by user_id); check new /orders routes for it.
```

## Rules

1. **Recall first.** At the start of any task, read `team.md` plus your own notebook. Treat them
   as hints: if a note disagrees with the code, trust the code and correct the note.
2. **Record only what lasts.** Stack facts, commands, conventions, decisions and why they were
   made, known pitfalls, accepted risks. Never a narration of the task ("today I added...").
   Those belong in handoffs.
3. **One dated line per fact:** `- YYYY-MM-DD: <fact>`.
4. **Edit, don't pile up.** Replace a stale line instead of adding a contradicting one. Keep each
   file under 60 lines by merging old entries.
5. **Right file.** A fact only you need goes in your own notebook. A fact every agent needs goes
   in `team.md`.
6. **Never store** secrets, passwords, tokens, keys, connection strings or personal data.
7. **Leo consolidates** after every `/squad` run. He moves shared facts into `team.md`, merges
   duplicates and removes lines the run proved wrong.

## Git

Commit `.squad/memory/` so the whole team, and every AI tool on every machine, starts from the same
knowledge. Ignore the per-run scratch files:

```gitignore
.squad/*
!.squad/memory/
```
