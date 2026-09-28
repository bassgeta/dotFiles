# Development Preferences

This guide beats the surrounding code. The codebases are messy; don't copy a bad local pattern because it's nearby. Exceptions are called out where they apply.

@~/.claude/style/code.md
@~/.claude/style/backend.md
@~/.claude/style/frontend.md
@~/.claude/style/testing.md

## Philosophy

- Simplicity over cleverness. KISS, SOLID, composition over inheritance
- Fail early, fail loud
- Do it properly, or flag that it needs discussion. Never quietly hack it together

## How we work

### Planning and iterations

- Always plan first, never wing it. Assess blast radius and complexity before touching code
- One plan, many short iterations. A CRUD service is four iterations: C, R, U, D. Each one is small enough to review fully, so the user stays on top of what is being built
- Refactor first, feature second. Land the enabling refactor as its own unit (separate PR, or separate commit if small), then build the feature on it
- Source first, tests second, in the same iteration but presented separately. Test churn buries the real diff. When estimating blast radius, give source and test file counts separately

### Scope and blast radius

- Adjacent mess: fix it if it blocks the work, or if it's small and in code we're already touching
- If a proper fix would sprawl (~10+ non-test files) and isn't required for the task, leave a named TODO and open a Linear issue straight away
- If a change is required, do it fully. A necessary signature change touching 40 files is fine; fix every caller
- Break cleanly by default. Only keep an old path alive when an API version must keep serving it
- Public contracts (API shapes, DB schema, env vars, event/webhook payloads): check before changing, and always call them out in the PR description and reports, since they need deployment attention
- Cross-repo impact: flag it, don't go fix the other repo
- Delete dead code found in the working tree. Don't go hunting for it
- No speculative building: no new file, hook, abstraction or state field until you've checked that an existing one, or a few inline lines, doesn't already cover it
- When porting old behavior, verify it does something observable before carrying it over

### Decisions

- Ask only when the answer changes the outcome. Naming, file placement and style are covered here, so don't ask about them
- Do check in on **state choices**: where state lives, what owns it, what's derived vs stored. Save the answer as a memory; settled patterns get promoted into this guide later
- Two valid approaches: present both with a recommendation
- Disagreement: push back until it's resolved. The user has the bigger picture, Claude has the code detail; neither should just cave
- New dependencies need approval
- Needing a hack: ask first. Default to the least painful bandage plus a named TODO. If the proper fix is big, it becomes a Linear tech-debt issue

### Money paths

- Extra care anywhere amounts, decimals, units, signing or keys are involved
- Amounts are `bigint` (or viem/ethers helpers), never `number`. Watch unit conversions and rounding direction
- No need to pre-explain money changes; get them right

### Done means

- `biome check --write` run, typecheck passes, relevant tests pass
- Report plainly what changed, including anything skipped or broken

### Source material

- Linear issues are often AI-generated and unreviewed. Mine them for facts (addresses, measurements, dependencies), not prescriptions. Code beats issue prose
- Refuse infrastructure with no caller and wrappers that only forward to a single SDK function

## Comments and TODOs

- No comments. Code explains itself through naming and structure
- Only exception: something the code can't convey, such as a workaround for an external bug or a counter-intuitive constraint. One or two lines max; longer reasoning belongs in the PR or the issue
- JSDoc/docblocks likewise, unless a public API genuinely needs them
- TODOs are always named: `TODO(missing-identity-param)`, never a bare `TODO`

## Git

- Never commit or stage, even when following an approved multi-commit plan. The user reviews the working-tree diff and commits themselves. Branching, `gt restack` and conflict resolution are fine
- Graphite stacks: do the work on the branch that owns it; the diff/review base is `gt parent`, not `main`
- Commit message format, for when one is asked for: `type: description` in past-tense active voice
  - Types: `feat`, `fix`, `refactor`, `build`, `ci`, `docs`, `test`, `chore`
  - `feat: implemented user authentication flow`

## Communication

- Terse and technical: conclusion first, then bullets, tables and `file.ts:120` refs. No prose paragraphs, no restating the question
- Copy-paste deliverables (PR descriptions, issue bodies, commit messages, docs snippets) go out as raw markdown in a fenced code block
- Never hard-wrap copy-paste markdown: one line per paragraph or bullet, however long. Structural newlines (headings, bullets, blank lines, fences) stay
