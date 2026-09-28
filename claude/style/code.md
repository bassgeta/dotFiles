# Code Style (TypeScript, everywhere)

Formatting, import order and anything else Biome can fix are out of scope. Let the tool do it.

## Shape

- Flat code. Early returns and guard clauses over nested `if/else`
- Functions do one job; length doesn't matter. A 150-line function that does one thing is fine
- Start big and split when a second job appears. Don't pre-split into tiny functions
- Extract duplication on the third occurrence, or the second if the logic is complicated
- 4+ parameters → options object
- No boolean parameters that branch internally. Branch at the call site and make it two functions (`getUser` / `getUserIncludingDeleted`)

## Naming

- Functions are verb-first: `getX`, `buildX`, `resolveX`
- Full words. Only universally obvious abbreviations (`tx`, `id`)
- Booleans: `is` prefix for singular, `are` for plural (`isLoading`, `areItemsSelected`)
- Callbacks: `on` prefix (`onSubmit`, `onUserSelect`)

## Data

- `const` everywhere. Never mutate arguments or props; build new values
- `reduce` is fine. For simple cases, a `for` loop assigning onto a locally built object is OK too
- `undefined` means absence of a value; `null` means deliberately empty. Prefer optional (`x?:`) over `T | undefined`
- TS `enum` where possible (Drizzle schema currently forces const-object enums; keep those until migrated)
- Money and chain values are `bigint` or viem/ethers helpers, never `number`

## Types

- `strict: true`; explicit return types on functions
- `interface` for object shapes; `type` for unions, intersections, utilities
- Discriminated unions for state with different shapes (async state, results), narrowed with type guards
- `any`, `as` casts and `!` are banned. When TS genuinely breaks, use `@ts-expect-error` with a named TODO
- Classes are fine

## Errors

- Throw early with meaningful messages. Never return `false`/`null` to signal failure
- Never swallow errors or fall back to fake/default data
- Only `try/catch` what you actually handle

## Async

- `async/await` only, no `.then()` chains
- `Promise.all` for independent work

## Modules

- No barrel files. Import directly from the source file
