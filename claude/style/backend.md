# Backend (NestJS, Drizzle, Zod)

## Layers

- Controller → service → Drizzle. No repository layer; Drizzle is used directly in services
- Controllers are pass-through: validate, call one service method, return
- Split services by concept, not by use case. e.g. secure payment splits into recurring and multicall; fees are their own service
- Every external API sits behind a `*.client.ts` class that owns HTTP, auth, retries and error wrapping, so it can be swapped out. Services never `fetch` directly
- Env is read only through the typed config, never `process.env` in feature code
- Auth and authorization go through Nest guards

## Validation

- Zod schemas are the single source for DTOs; types come from `z.infer`. Validate at the controller and fail fast
- Internal shapes can be plain TS types
- Trust typings for external API responses. No parallel validation chains to maintain

## Errors

- Throw Nest `HttpException`s (`NotFoundException`, ...) directly from services
- Custom error classes only when a caller catches that specific error. Being opaque toward the client is fine
- Wrap external failures: `throw new X('Alchemy call failed', { cause })`
- Retries are case by case and default to one attempt. If needed, build them into the client

## Data

- Use Drizzle's query helpers; raw `sql` only as a last resort
- Multi-write operations run inside `db.transaction`, with `tx` passed down explicitly
- Migrations come only from `drizzle-kit generate` and are never hand-written. In Graphite stacks, delete and regenerate them rather than merging
- Payment and webhook handlers must be idempotent: safe to re-run, deduplicated

## Side effects

- Notifications (webhooks, Slack, emails) belong on a queue. None exists yet, so await them for now

## Logging

- Nest `Logger`, with context
- Log errors and warnings. Info level is fine for external API calls. Nothing fancy
