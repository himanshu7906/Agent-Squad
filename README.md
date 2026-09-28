# Agent Squad

**A team of 10 AI software experts, with human names, that you install as slash commands in Claude
Code, OpenAI Codex and Google Antigravity.**

Call one expert when you need one (`/sara review my login code`), or have the whole team build a
feature from requirements to docs (`/squad feature add password reset`). The squad writes what it
learns about your project into files, so it remembers between sessions, and you can switch AI
tools partway through a task.

![Claude Code](https://img.shields.io/badge/Claude%20Code-supported-d97757)
![Codex](https://img.shields.io/badge/Codex-supported-10a37f)
![Antigravity](https://img.shields.io/badge/Antigravity-supported-4285f4)
![PowerShell](https://img.shields.io/badge/install-PowerShell-5391fe)
![Version](https://img.shields.io/badge/version-1.1.0-informational)

---

## Contents

- [Meet the squad](#meet-the-squad)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Solo mode](#solo-mode)
- [Group mode](#group-mode)
- [A full example](#a-full-example)
- [Memory](#memory)
- [Installer options](#installer-options)
- [How it works](#how-it-works)
- [Customizing](#customizing)
- [Troubleshooting](#troubleshooting)
- [Project structure](#project-structure)
- [Contributing](#contributing)

---

## Meet the squad

Each name starts with the same letter as the agent's job, so they are easy to remember.

| Command | Name | Role | Expertise |
|---|---|---|---|
| `/priya` | **P**riya | **P**roduct Strategist | requirements, user stories, scope, acceptance criteria |
| `/arjun` | **A**rjun | Software **A**rchitect | system design, trade-offs, service boundaries, ADRs |
| `/ben` | **B**en | **B**ackend Engineer | APIs, services, business logic, auth, integrations |
| `/fiona` | **F**iona | **F**rontend Engineer | UI components, state, accessibility, responsive design |
| `/diana` | **D**iana | **D**ata Engineer | schemas, SQL, migrations, query performance, pipelines |
| `/omar` | **O**mar | DevOps / Cloud **O**ps | CI/CD, containers, IaC, deployment, observability |
| `/sara` | **S**ara | **S**ecurity Engineer | threat modeling, OWASP, secrets, auth flaws, dependencies |
| `/quinn` | **Q**uinn | **Q**A & Test Engineer | test strategy, unit/integration/e2e tests, edge cases |
| `/rohan` | **R**ohan | Debugging (**R**oot cause) | root-cause analysis, reproductions, incident triage |
| `/will` | **W**ill | Technical **W**riter | READMEs, API docs, guides, changelogs |
| `/squad` | **L**eo | Squad **L**ead | runs the agents together as a group workflow |

## Features

- **Works in three AI tools.** One install gives you the same commands in Claude Code, Codex and
  Antigravity.
- **Solo or group.** Every agent works on its own. `/squad` runs a team through a ready-made
  workflow or a team you pick.
- **Runs in parallel in Claude Code.** Each stage runs as its own sub-agent, and stages marked
  `+` (for example, backend and frontend) run at the same time.
- **Remembers your project.** Each agent keeps a notebook in your repo and gets better at your
  codebase over time.
- **Switch tools partway through.** Start a run in Claude Code, hit a usage limit, and continue in
  Codex with `/squad resume`.
- **Checks built in.** Quinn (tests) and Sara (security) must pass before work is called done. If
  they fail, the work goes back to the agent who owns it.
- **You stay in control.** The squad stops for your approval after planning, and always asks
  before deploys, migrations on shared databases, or deleting files.
- **Safe installer.** It is re-runnable and supports a dry run. It never overwrites or deletes
  files it didn't create.
- **Plain Markdown.** No servers, API keys or runtime. Every agent is a readable `SKILL.md` you
  can edit.

## Requirements

- **Windows** with Windows PowerShell 5.1 or PowerShell 7+.
- At least one of: [Claude Code](https://claude.com/claude-code),
  [OpenAI Codex CLI](https://github.com/openai/codex), or
  [Google Antigravity](https://antigravity.google/).

> macOS and Linux: the installer is written to be cross-platform and should run under PowerShell
> 7 (`pwsh`), but it has only been tested on Windows so far.

## Installation

### Option 1: Git clone (recommended)

```powershell
git clone https://github.com/himanshu7906/Agent-Squad.git
cd Agent-Squad
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Option 2: No git

```powershell
$zip = "$env:TEMP\agent-squad.zip"
Invoke-WebRequest https://github.com/himanshu7906/Agent-Squad/archive/refs/heads/main.zip -OutFile $zip
Expand-Archive $zip "$env:TEMP\agent-squad" -Force
powershell -ExecutionPolicy Bypass -File "$env:TEMP\agent-squad\Agent-Squad-main\install.ps1"
```

### Option 3: Double-click

Download the repo and double-click **`install.cmd`**.

The installer finds which AI tools are on your machine and installs into all of them:

```text
== Agent Squad v1.1.0 :: Install (User scope) ==
detected -> Claude:True  Codex:True  Antigravity:True
[Claude]       skills -> ~/.claude/skills ; sub-agents -> ~/.claude/agents
[Codex]        skills -> ~/.codex/skills ; prompts -> ~/.codex/prompts
[Antigravity]  skills -> ~/.gemini/config/skills ; native skill slash commands
Installed 11 skills into: Claude, Codex, Antigravity
```

> **Restart your AI tool afterwards.** Commands only load when a new session starts.

## Quick start

Open any project in your AI tool and try:

```text
/arjun design a URL shortener that handles 10k requests per second
```

```text
/squad feature add a "forgot password" flow by email
```

## Solo mode

Type an agent's command followed by your task. The agent reads your code first, follows its own
expert procedure, checks its work, and reports back.

```text
/priya turn "users want to share carts" into user stories and acceptance criteria
/arjun should we split the monolith's billing module into a service?
/ben add pagination and filtering to GET /orders
/fiona make the checkout form accessible and mobile-friendly
/diana add an index plan for the slow orders-by-customer query
/omar set up a GitHub Actions pipeline with tests and a Docker build
/sara review src/auth for security issues
/quinn write edge-case tests for src/cart/pricing.ts
/rohan POST /login returns 500 since yesterday's deploy
/will write a getting-started guide for new contributors
```

## Group mode

Leo, the squad lead, plans the work, briefs each agent, keeps a shared board, runs the checks,
and gives you a final report.

```text
/squad <workflow> [--auto] <task>
```

### Built-in workflows

`>` means the next stage runs after the previous one. `+` means both agents work in the same
stage, and run in parallel in Claude Code.

| Workflow | Use it for | Stages |
|---|---|---|
| `feature` | building a new capability end to end | priya > arjun > diana > ben + fiona > quinn > sara > will |
| `bugfix` | diagnosing and fixing a bug | rohan > owner of the fix > quinn |
| `audit` | a review of code health, with no edits | sara + quinn + arjun |
| `ship` | checking a release is ready | quinn > sara > omar > will |
| `design` | planning only, no code | priya > arjun |
| `api` | a new or changed API | arjun > diana > ben > quinn > will |

Stages that don't apply are skipped automatically. For example, Diana is skipped when there are
no data changes.

### More commands

| Command | What it does |
|---|---|
| `/squad team arjun>ben+fiona>quinn <task>` | Choose your own team and order |
| `/squad <task>` | Leo picks the workflow and asks you to confirm |
| `/squad --auto feature <task>` | Skip the approval stops after planning (safety stops still apply) |
| `/squad status` | Show the current board |
| `/squad resume` | Continue an unfinished run, in any AI tool |

## A full example

```text
/squad feature add forgot-password by email
```

1. **Leo** shows the plan and writes it to `.squad/board.md`.
2. **Priya** writes the requirements, for example "reset link expires in 30 minutes; unknown
   emails get the same response". **Leo stops for your approval.**
3. **Arjun** designs the solution: a random single-use token stored hashed, two endpoints, and
   the flow between them. **Leo stops for your approval.**
4. **Diana** adds a `password_resets` table with a migration that can be rolled back.
5. **Ben** builds the API while **Fiona** builds the pages. In Claude Code they work at the same
   time.
6. **Quinn** runs the tests and finds that an expired token is still accepted. The work goes back
   to Ben, Ben fixes it, and the tests pass on the rerun.
7. **Sara** reviews for security and gives a PASS verdict.
8. **Will** updates the README and the changelog.
9. **Leo** reports the result:

```text
7 stages done · 9 files changed · 24 tests passing · Security: PASS
Open risk: email sending has no retry. Suggest a background job later.
```

Every stage leaves a readable record behind:

```text
.squad/
  board.md
  handoffs/01-priya.md  02-arjun.md  03-diana.md  04-ben.md  04-fiona.md
           05-quinn.md  05a-ben.md (fix)  06-sara.md  07-will.md
```

If you hit a usage limit halfway through, open the same folder in another tool and run
`/squad resume`.

## Memory

The AI forgets everything when a chat ends. The squad remembers by writing plain files into your
project, which every tool can read.

| Layer | Where | Lasts | Holds |
|---|---|---|---|
| Working memory | the AI's context window | one chat | the current task |
| Run memory | `.squad/board.md`, `.squad/handoffs/` | one `/squad` run, then archived | the plan, status, decisions and outputs |
| Long-term memory | `.squad/memory/` | permanent | lasting facts about your project |

```text
.squad/memory/
  team.md    # read by every agent: stack, test/build commands, conventions, key decisions
  sara.md    # Sara's notebook: auth model, accepted risks, vulnerabilities fixed
  quinn.md   # Quinn's notebook: test commands, flaky tests, coverage gaps
  ...        # one notebook per agent
```

- **Recall.** Before every task, an agent reads `team.md` and its own notebook.
- **Verify.** Notes are hints, not truth. If a note disagrees with the code, the agent trusts the
  code and corrects the note.
- **Record.** Before finishing, an agent writes down lasting facts it learned, one dated line
  each. It never writes secrets.
- **Consolidate.** After each run, Leo merges duplicates, moves facts everyone needs into
  `team.md`, and keeps each file short.

To share what the squad has learned with your team, commit the memory and ignore the per-run
files:

```gitignore
.squad/*
!.squad/memory/
```

## Installer options

```powershell
.\install.ps1 [-Claude] [-Codex] [-Antigravity] [-All] [-Agents <names>]
              [-Scope User|Project] [-ProjectDir <path>]
              [-List] [-DryRun] [-Uninstall] [-Force]
```

| Option | Effect |
|---|---|
| *(none)* | Install every agent into every AI tool found on this machine |
| `-Claude` `-Codex` `-Antigravity` | Install only into these tools |
| `-All` | Install into all three tools, even ones not detected |
| `-Agents arjun,sara` | Install only these agents (`squad` is always included) |
| `-Scope Project -ProjectDir <path>` | Install into a repo so your whole team gets the commands |
| `-List` | Show the agents and workflows |
| `-DryRun` | Show what would change without writing anything |
| `-Uninstall` | Remove everything the installer created |
| `-Force` | Overwrite a skill of yours that has the same name |

**Update:** run `git pull`, then `.\install.ps1` again.
**Uninstall:** `.\install.ps1 -Uninstall`.

### Where files go

| Tool | User scope (default) | Project scope |
|---|---|---|
| Claude Code | `~/.claude/skills/<name>/` + `~/.claude/agents/squad-<name>.md` | `.claude/skills/`, `.claude/agents/` |
| Codex | `~/.codex/skills/<name>/` + `~/.codex/prompts/<name>.md` | `.agents/skills/` |
| Antigravity | `~/.gemini/config/skills/<name>/` | `.agents/skills/` |

The installer tags everything it writes (a `.agent-squad` marker file in each folder, a managed
comment in each generated file). It skips, and never deletes, anything without that tag, so a
skill you wrote yourself that happens to share a name is safe.

## How it works

There is no program running behind the agents. Each agent is a Markdown file (`SKILL.md`) that
gives the AI a role, a step-by-step procedure, a quality checklist and handoff rules. When you
type `/sara`, your AI tool loads Sara's instructions and follows them. All three tools use the
same skill format, which is why one set of files works everywhere.

In group mode, agents talk to each other only through files in `.squad/`. That works the same in
every tool:

```text
          /squad feature X
                 |
        +--------v---------+
        |  Leo (squad lead) |  plans, sequences, runs the checks
        +--------+---------+
                 | reads / writes
        +--------v---------+
        | .squad/ board +  |  shared state that works in every AI tool
        | handoffs + memory|
        +--------^---------+
                 | each agent reads earlier handoffs and writes its own
 priya > arjun > diana > ben + fiona > quinn > sara > will
```

- **Claude Code:** each stage runs as a real sub-agent with a fresh context, and stages marked
  `+` run in parallel.
- **Codex and Antigravity:** Leo runs one agent at a time in the same chat. He loads each agent's
  instructions, does that stage as that agent, writes its handoff, then moves to the next.

## Customizing

**Edit an agent.** Change its `skills/<name>/SKILL.md`, then run `.\install.ps1` again.

**Add an agent:**
1. Copy `skills/ben/` to `skills/<newname>/`. Set `name:` in the frontmatter to match the folder
   name, and rewrite the role, procedure and quality bar. Keep the **Memory** and **Group mode**
   sections.
2. Add the agent to `agents` in `squad.json`.
3. To use it in workflows, add it to `squad.json` → `workflows`, `skills/squad/SKILL.md`, and
   `skills/squad/references/workflows.md`.
4. Run `.\install.ps1`.

**Add a workflow.** Add it to the same three places as in step 3.

## Troubleshooting

| Problem | Fix |
|---|---|
| Commands don't appear | Start a **new** session. Run `.\install.ps1 -List` and check the "detected" line. |
| "running scripts is disabled" | Use `powershell -ExecutionPolicy Bypass -File .\install.ps1` or `install.cmd` (this doesn't change your system policy) |
| Codex shows `/prompts:sara` instead of `/sara` | That's how newer Codex versions name prompts. Both work, or just ask "use the sara skill". |
| A tool wasn't detected | Install into it anyway, for example `.\install.ps1 -Antigravity` |
| "skip ... not installed by Agent Squad" | You already have a skill with that name. Rename yours or use `-Force`. |
| Want to see changes first | `.\install.ps1 -DryRun` |

## Project structure

```text
Agent-Squad/
├── install.ps1          # installer / uninstaller for Claude Code, Codex, Antigravity
├── install.cmd          # double-click wrapper
├── squad.json           # the agents and workflows
└── skills/
    ├── priya/  arjun/  ben/  fiona/  diana/
    ├── omar/   sara/   quinn/ rohan/ will/   # one SKILL.md per agent
    └── squad/
        ├── SKILL.md                         # Leo, the orchestrator
        └── references/
            ├── workflows.md                 # workflow recipes
            ├── protocol.md                  # board and handoff templates
            └── memory.md                    # memory rules
```

## Contributing

Issues and pull requests are welcome, especially new agents, new workflows, and test reports from
macOS and Linux.

1. Fork the repo and create a branch.
2. Keep agent files plain ASCII Markdown with `name` and `description` frontmatter.
3. Test the installer against a throwaway folder:
   `.\install.ps1 -All -HomeDir $env:TEMP\squad-test`, then `-Uninstall` with the same folder.
4. Open a pull request describing the change.

---

Made by [Himanshu](https://github.com/himanshu7906). If Agent Squad helps you, a star helps others
find it.
