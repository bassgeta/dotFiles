# Testing (Vitest)

## Levels

- **Unit** (`x.unit.test.ts`): pure logic and branching. Mock Drizzle and external services. Don't mock internal helpers; let them run
- **Integration** (`x.integration.test.ts`): behavior against a real DB, externals mocked
- **E2E** (`x.e2e.test.ts`): full app over HTTP, critical flows
- No frontend component tests (team decision)

Default split: a few concise unit tests for logic, integration tests for behavior. Avoid piles of trivial tests.

## What to test

- Every new branch in business logic gets a test
- Test through the public surface. Don't export internals just to test them
- Money paths: cover the edge cases that apply (0, dust, max values, decimals mismatch, rounding direction)
- Don't re-cover the same logic in many tests. If several tests keep exercising one computation, extract it into a helper and test that once

## Style

- `describe` per unit under test; `it('throws when …')` in behavior phrasing; arrange, act, assert
- Several asserts per test are fine when that's cheaper than splitting
- Assert outcomes, not call parameters. `toHaveBeenCalledWith` goes brittle over time
- `vi.mock` is fine
- Fixtures are factory functions: a default fixture plus overrides via spread (`buildPayment({ amount })`). Start them in the test file; move shared ones to the repo's top-level test folder (`src/test/`). No new `__tests__/` folders
- No snapshots

## Location

- Colocate: `thing.ts` → `thing.unit.test.ts`

## Broken tests

- If we broke it, fix it
- If it was already broken or flaky, skip it with a named TODO and flag it
