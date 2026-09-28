# Squad Workflows

`>` = next stage (sequential). `+` = same stage (parallel where the host supports sub-agents).

## feature -- build a new capability end to end
`priya > arjun > diana > ben + fiona > quinn > sara > will`
- Checkpoints after priya (scope) and arjun (design).
- Skip diana if no schema/data change; skip fiona for backend-only, ben for frontend-only.
- Parallel stage: Arjun's build plan decides file ownership between ben and fiona.

## bugfix -- diagnose and fix a defect
`rohan > <owner> > quinn`
- Rohan names the owner (ben, fiona, diana or omar); default ben.
- Owner applies the fix and the regression test Rohan specified; Quinn widens coverage and runs
  the full suite.

## audit -- review-only health check (no code changes)
`sara + quinn + arjun`
- Sara: security findings. Quinn: test gaps and risky untested code. Arjun: structural issues,
  coupling, tech debt.
- Squad Lead merges the three into one ranked report (severity, file:line, fix, owner).

## ship -- release readiness
`quinn > sara > omar > will`
- Quinn: full suite green. Sara: PASS verdict on the release diff. Omar: pipeline, build,
  deploy plan and rollback (no deploy without explicit approval). Will: changelog + release notes.

## design -- plan only, no code
`priya > arjun`
- Output: requirements brief + architecture doc/ADR. Good precursor to `feature --auto`.

## api -- new or changed API surface
`arjun > diana > ben > quinn > will`
- Arjun defines the contract first; Will publishes the reference (OpenAPI if the project uses it).

## team -- custom
`/squad team arjun>ben+fiona>quinn <task>`
- Any roster names, any order. Unknown names are rejected with the list of valid agents.

## Choosing a workflow when none is named
| Signal in the request | Workflow |
|---|---|
| "add", "build", "implement", new feature | feature (or api if purely endpoints) |
| error, crash, "broken", failing test | bugfix |
| "review", "audit", "check", "health" | audit |
| "release", "deploy", "ship", "go live" | ship |
| "plan", "design", "how should we" | design |
Always show the chosen plan and confirm before starting when the workflow was inferred.
