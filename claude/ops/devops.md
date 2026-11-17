# DevOps Operations Guide

Practical guide for managing database migrations, environment variables, secrets, and deployments for all Request Network services.

## Table of Contents

- [Services Overview](#services-overview)
- [Secrets & Environment Variables](#secrets--environment-variables)
- [Database Migrations](#database-migrations)
- [Deployments & Restarts](#deployments--restarts)
- [Rollbacks](#rollbacks)
- [Monitoring & Debugging](#monitoring--debugging)
- [Quick Reference](#quick-reference)

---

## Services Overview

### Cloud Run Services

| Service | Cloud Run Name | Type | Health Check | Domain |
|---------|---------------|------|-------------|--------|
| Request API | `request-api-{env}` | NestJS backend | `/v2/health` | `api.{stage.}request.network` |
| Auth API (HTTP) | `request-auth-api-{env}` | NestJS backend | `/v1/health` | `auth.{stage.}request.network` |
| Auth API (gRPC) | `request-auth-api-grpc-{env}` | NestJS (HTTP/2) | TCP probe | internal only |
| Dashboard | `request-dashboard-{env}` | Vite SPA + Nginx | `/` | `dashboard.{stage.}request.network` |
| Secure Payment | `request-secure-payment-{env}` | Vite SPA + Nginx | `/` | `pay.stage.request.network` |

> **Note:** `request-secure-payment` is staging-only. Production stays on IPFS.

### Cloud Run Jobs (Migrations)

| Job | Timeout (stage) | Timeout (prod) |
|-----|----------------|----------------|
| `request-api-migrate-{env}` | 300s | 600s |
| `request-auth-api-migrate-{env}` | 300s | 600s |

### Data Stores

| Resource | Type | Used By |
|----------|------|---------|
| `request-api-{env}` | Cloud SQL PostgreSQL 17 | request-api |
| `request-auth-api-{env}` | Cloud SQL PostgreSQL 17 | request-auth-api |
| `request-redis-{env}` | Memorystore Redis 7.0 | request-api, request-auth-api (shared) |

### Resource Allocation

| | Staging | Production |
|--|---------|------------|
| API CPU / Memory | 1 / 512Mi | 2 / 1Gi |
| API Max Instances | 5 | 10 |
| Auth API Max Instances | 5 | 10 |
| Dashboard Max Instances | 3 | 5 |
| Cloud SQL Tier | db-f1-micro | db-custom-2-8192 (HA) |
| Cloud SQL Backups | Disabled | Enabled + PITR (7 days) |
| Redis Tier | BASIC (1GB) | STANDARD_HA (2GB) |

All services run in **us-central1** on project **requestnetwork**.

---

## Secrets & Environment Variables

### Architecture

All services use **GCP Secret Manager** with a consistent 3-layer system. Services only receive `GCP_PROJECT_ID` and `APP_ENV` as Terraform-managed env vars — everything else comes from Secret Manager.

```
Loading priority: local .env > Layer 1 (individual secrets) > Layer 2 (app config JSON) > Layer 3 (feature flags)
```

| Layer | Secret Name Pattern | When to Use |
|-------|-------------------|-------------|
| 1. Secrets | `{service}-{env}-{var-kebab}` | Highly sensitive values (DB URLs, private keys, tokens) |
| 2. App Config | `{service}-{env}-app-config` | Non-secret config (RPC URLs, API endpoints, domains) |
| 3. Feature Flags | `{service}-{env}-feature-flags` | Boolean feature toggles |

### Secret Names Per Service

Replace `{env}` with `preview`, `stage` or `production`.

#### request-api

| Layer 1 Secrets | Secret Name |
|----------------|-------------|
| `DATABASE_URL` | `request-api-{env}-database-url` |
| `REDIS_URL` | `request-api-{env}-redis-url` |
| `ENCRYPTION_KEY_V1` | `request-api-{env}-encryption-key-v1` |
| `HASURA_GRAPHQL_JWT_TOKEN` | `request-api-{env}-hasura-graphql-jwt-token` |
| `LIFI_API_KEY` | `request-api-{env}-lifi-api-key` |
| `ALCHEMY_API_KEY` | `request-api-{env}-alchemy-api-key` |
| `RHINESTONE_API_KEY` | `request-api-{env}-rhinestone-api-key` |
| `AUTH_GRPC_JWT_TOKEN` | `request-api-{env}-auth-grpc-jwt-token` |
| `RELAYER_PRIVATE_KEY` | `request-api-{env}-relayer-private-key` |
| `GAS_WALLET_PRIVATE_KEY` | `request-api-{env}-gas-wallet-private-key` |
| `COINGECKO_API_KEY` | `request-api-{env}-coingecko-api-key` |
| `SENTRY_DSN` | `request-api-{env}-sentry-dsn` |
| `ORCHESTRATOR_ADMIN_CLIENT_ID` | `request-api-{env}-orchestrator-admin-client-id` |
| `SAFE_TRANSACTION_SERVICE_API_KEY` | `request-api-{env}-safe-transaction-service-api-key` |
| `CHEETAH_HYPERNATIVE_CLIENT_ID` | `request-api-{env}-cheetah-hypernative-client-id` |
| `CHEETAH_HYPERNATIVE_CLIENT_SECRET` | `request-api-{env}-cheetah-hypernative-client-secret` |
| `CHEETAH_MERKLESCIENCE_API_KEY` | `request-api-{env}-cheetah-merklescience-api-key` |
| `CATFEE_API_KEY` | `request-api-{env}-catfee-api-key` |
| `CATFEE_API_SECRET` | `request-api-{env}-catfee-api-secret` |
| `CATFEE_TRON_FULL_HOST` | `request-api-{env}-catfee-tron-full-host` |
| `CATFEE_TRON_FULL_HOST_API_KEY` | `request-api-{env}-catfee-tron-full-host-api-key` |
| `TRONENERGYRENT_API_KEY` | `request-api-{env}-tronenergyrent-api-key` |
| `SLACK_TOKEN` | `request-api-{env}-slack-token` |
| `TRONSCAN_API_KEY` | `request-api-{env}-tronscan-api-key` |
| `SECURE_PAYMENT_TOKEN_HMAC_SECRET` | `request-api-{env}-secure-payment-token-hmac-secret` |
| `PAYMENTS_DATABASE_URL` | `request-api-{env}-payments-database-url` |
| `RECURRING_ACCESS_TOKEN_SECRET` | `request-api-{env}-recurring-access-token-secret` (min 32 chars, required at boot) |

App config: `request-api-{env}-app-config` (RPC URLs, fee config, etc.)
Feature flags: `request-api-{env}-feature-flags`

#### request-auth-api

| Layer 1 Secrets | Secret Name |
|----------------|-------------|
| `DATABASE_URL` | `request-auth-api-{env}-database-url` |
| `REDIS_URL` | `request-auth-api-{env}-redis-url` |
| `ENCRYPTION_KEY_V1` | `request-auth-api-{env}-encryption-key-v1` |
| `JWT_SECRET` | `request-auth-api-{env}-jwt-secret` |
| `COOKIE_SECRET` | `request-auth-api-{env}-cookie-secret` |
| `SENTRY_DSN` | `request-auth-api-{env}-sentry-dsn` |

App config: `request-auth-api-{env}-app-config`

#### request-dashboard

| Layer 1 Secrets | Secret Name |
|----------------|-------------|
| `VITE_PROJECT_ID` | `request-dashboard-{env}-vite-project-id` |

App config: `request-dashboard-{env}-app-config`
Feature flags: `request-dashboard-{env}-feature-flags`

> Dashboard and secure-payment use a `docker-entrypoint.sh` script that loads secrets and replaces `__VITE_*__` build-time placeholders at container startup.

#### request-secure-payment

| Layer 1 Secrets | Secret Name |
|----------------|-------------|
| `VITE_WALLETCONNECT_PROJECT_ID` | `request-secure-payment-{env}-vite-walletconnect-project-id` |
| `VITE_PIMLICO_API_KEY` | `request-secure-payment-{env}-vite-pimlico-api-key` |

App config: `request-secure-payment-{env}-app-config`
Feature flags: `request-secure-payment-{env}-feature-flags`

### Naming Convention

Layer 1 secrets use kebab-case derived from the env var name, prefixed with the service name and environment:

```
{service}-{env}-{VAR_NAME in kebab-case}
```

Examples:
- `DATABASE_URL` on request-api staging = `request-api-stage-database-url`
- `JWT_SECRET` on auth-api production = `request-auth-api-production-jwt-secret`

### Viewing Secrets

```bash
# List all secrets for a service
gcloud secrets list --project=requestnetwork \
  --filter="name:request-api" --format="value(name)"

# View a Layer 1 secret
gcloud secrets versions access latest \
  --secret=request-api-stage-database-url \
  --project=requestnetwork

# View Layer 2 app config (formatted)
gcloud secrets versions access latest \
  --secret=request-api-stage-app-config \
  --project=requestnetwork | python3 -m json.tool

# View a specific key from app config
gcloud secrets versions access latest \
  --secret=request-api-stage-app-config \
  --project=requestnetwork | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('TRON_RPC', 'NOT SET'))
"

# View Layer 3 feature flags
gcloud secrets versions access latest \
  --secret=request-api-stage-feature-flags \
  --project=requestnetwork | python3 -m json.tool
```

### Adding a New Environment Variable

#### To Layer 2 (App Config) — most common for non-secret config

```bash
# 1. Read current config, add key, write new version (single pipe — no temp files)
#    Replace {service} and {env} as needed
gcloud secrets versions access latest \
  --secret={service}-{env}-app-config \
  --project=requestnetwork \
  | jq '. + {"MY_NEW_VAR": "my-value"}' \
  | gcloud secrets versions add {service}-{env}-app-config \
      --project=requestnetwork --data-file=-

# 2. Verify
gcloud secrets versions access latest \
  --secret={service}-{env}-app-config \
  --project=requestnetwork | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('MY_NEW_VAR:', d.get('MY_NEW_VAR', 'NOT SET'))
"

# 3. Restart the service (see Deployments & Restarts section)
```

#### To Layer 1 (Individual Secret) — for highly sensitive values

```bash
# 1. Create the secret (first time only)
printf 'secret-value' | gcloud secrets create {service}-{env}-my-new-secret \
  --data-file=- --project=requestnetwork \
  --replication-policy=automatic

# 2. For backend services (request-api, request-auth-api):
#    Add the env var name to loadSecrets() in src/main.ts
#    loadSecrets([..., "MY_NEW_SECRET"])
#
#    For frontend services (dashboard, secure-payment):
#    Add the var name to the LAYER1_SECRETS array in docker-entrypoint.sh

# 3. Deploy the code change (merge to main triggers staging deploy)
```

To update an existing Layer 1 secret:

```bash
printf 'new-value' | gcloud secrets versions add {service}-{env}-my-new-secret \
  --data-file=- --project=requestnetwork
```

#### To Layer 3 (Feature Flags)

```bash
gcloud secrets versions access latest \
  --secret={service}-{env}-feature-flags \
  --project=requestnetwork \
  | jq '. + {"MY_NEW_FLAG": true}' \
  | gcloud secrets versions add {service}-{env}-feature-flags \
      --project=requestnetwork --data-file=-
```

### Removing an Environment Variable

```bash
# From Layer 2 app config — remove a key
gcloud secrets versions access latest \
  --secret={service}-{env}-app-config \
  --project=requestnetwork \
  | jq 'del(.MY_OLD_VAR)' \
  | gcloud secrets versions add {service}-{env}-app-config \
      --project=requestnetwork --data-file=-
```

### Important: Config is Loaded Once at Boot

**Backend services** (request-api, request-auth-api): All three layers are loaded during `bootstrap()` in `src/main.ts` and cached in `process.env`. There is no hot-reload. The feature flags layer has a periodic refresh mechanism via `FeatureFlagService`, but Layer 1 and Layer 2 values are read once and cached.

**Frontend services** (dashboard, secure-payment): Secrets are loaded and placeholders replaced in `docker-entrypoint.sh` at container startup. Nginx then serves the static files with the injected values.

After changing any secret or config value, you must **restart the service** for it to take effect.

### Gotcha: Module-Level Reads (Backend Services)

Some env vars are read at module import time (before Secret Manager loads). These use lazy getters to avoid race conditions:

| Variable | Lazy Getter | Service |
|----------|------------|---------|
| `ENCRYPTION_KEY_V1` | `getEncryptionKeys()` | request-api |
| `SESSION_COOKIE_NAME` | `getSessionCookieName()` | request-api |
| `CRYPTO_TO_FIAT_PAYEE_ADDRESS` | `getCryptoToFiatPayeeAddress()` | request-api |

If adding a new env var that is read at module scope, use a lazy getter pattern — never a module-level constant.

---

## Database Migrations

### Overview

Both **request-api** and **request-auth-api** use **Drizzle ORM** with PostgreSQL. Each has its own Cloud SQL instance and a dedicated Cloud Run Job for running migrations. The CI/CD pipeline automatically detects changes in the `drizzle/` directory and runs migrations before deploying the new revision.

**request-dashboard** and **request-secure-payment** have no database.

### Creating a Migration

```bash
# In the respective service repo (request-api or request-auth-api):

# 1. Modify the schema in src/drizzle/schema.ts

# 2. Generate migration files
pnpm db:generate

# 3. Review the generated SQL in drizzle/ directory

# 4. Test locally
pnpm db:migrate

# 5. Commit the migration files along with your schema changes
```

### Running Migrations Manually

```bash
# request-api
gcloud run jobs execute request-api-migrate-{env} \
  --region us-central1 --project requestnetwork --wait

# request-auth-api
gcloud run jobs execute request-auth-api-migrate-{env} \
  --region us-central1 --project requestnetwork --wait
```

### How CI/CD Handles Migrations

The deploy workflow for both backend services automatically:

1. Compares the deployed image SHA against the new commit
2. Checks if any files in `drizzle/` changed
3. If yes: mirrors the migrate image to Artifact Registry, updates the Cloud Run Job image, and executes it
4. If no: skips the migration job (~2.5 min saved)
5. Falls back to running migrations if detection fails (fail-safe)

### Running Ad-Hoc SQL

> **Note:** All Cloud SQL instances are **private-IP only** — they cannot be reached directly from your local machine via `cloud-sql-proxy` or `psql`. Options A and B require a host inside the GCP VPC. Use **Option C** (ephemeral VM via IAP) to connect from your local machine.

#### Option A: IAM-authenticated read-only access (recommended)

Team members listed in `db_iam_users` can connect using their GCP identity — no shared passwords:

```bash
# Authenticate with GCP (one-time)
gcloud auth login
gcloud auth application-default login

# Start the proxy with IAM auth
cloud-sql-proxy requestnetwork:us-central1:request-api-{env} \
  --port=5432 --auto-iam-authn

# Connect (no password needed — your GCP identity is used)
psql -h 127.0.0.1 -p 5432 -U your-email@requestnetwork.com -d request-api
```

IAM users have **read-only** access (SELECT only). To add a new user:

1. Add their email to `db_iam_users` in the environment's tfvars and run `terraform apply`
2. Run the one-time grant script:
   ```bash
   PGPASSWORD='...' ./scripts/grant-iam-user-readonly.sh user@requestnetwork.com request-api 5432
   ```

#### Option B: Admin access via DATABASE_URL

For writes, migrations, or admin operations, connect with the admin credentials:

```bash
# request-api database
cloud-sql-proxy requestnetwork:us-central1:request-api-{env} --port=5432

# request-auth-api database (use a different local port)
cloud-sql-proxy requestnetwork:us-central1:request-auth-api-{env} --port=5433
```

Then connect with psql using the `DATABASE_URL` from Secret Manager.

#### Option C: Ephemeral VM via IAP tunnel (no VPN required)

Creates a short-lived Compute Engine VM inside the target VPC, tunnels port-forwarding through GCP's Identity-Aware Proxy, runs the query locally, then deletes the VM. IAP SSH firewall rules (`allow-iap-ssh-{env}`) are already in place for both environments.

**Prerequisites:** `gcloud` CLI authenticated (`gcloud auth login && gcloud auth application-default login`). No local `psql` needed — it runs on the VM.

```bash
# ── Configure ──────────────────────────────────────────────────────────────────
SERVICE=request-auth-api   # request-api | request-auth-api
ENV=stage                  # stage | production

# ── 1. Fetch credentials ───────────────────────────────────────────────────────
DB_URL=$(gcloud secrets versions access latest \
  --secret=${SERVICE}-${ENV}-database-url --project=requestnetwork)

DB_HOST=$(echo "$DB_URL" | python3 -c "import sys; from urllib.parse import urlparse; u=urlparse(sys.stdin.read().strip()); print(u.hostname)")
DB_USER=$(echo "$DB_URL" | python3 -c "import sys; from urllib.parse import urlparse; u=urlparse(sys.stdin.read().strip()); print(u.username)")
DB_PASS=$(echo "$DB_URL" | python3 -c "import sys; from urllib.parse import urlparse; u=urlparse(sys.stdin.read().strip()); print(u.password)")
DB_NAME=$(echo "$DB_URL" | python3 -c "import sys; from urllib.parse import urlparse; u=urlparse(sys.stdin.read().strip()); print(u.path.lstrip('/'))")

# ── 2. Create ephemeral VM (no external IP; IAP handles SSH access) ────────────
gcloud compute instances create sql-patch-vm \
  --project=requestnetwork \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --network=request-${ENV} \
  --subnet=request-${ENV}-subnet \
  --no-address \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-size=10GB

# ── 3. Pipe your SQL through SSH — psql runs on the VM, output comes back locally
echo "SELECT id, has_secure_payment_page_access FROM client_id WHERE client_id = 'cli_xxx';" \
  | gcloud compute ssh sql-patch-vm \
      --project=requestnetwork \
      --zone=us-central1-a \
      --tunnel-through-iap \
      --command="sudo apt-get install -y -qq postgresql-client 2>/dev/null; \
                 PGPASSWORD='${DB_PASS}' psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME}"

# For writes, verify with SELECT first, then pipe the UPDATE:
echo "UPDATE client_id SET has_secure_payment_page_access = true WHERE client_id = 'cli_xxx' RETURNING *;" \
  | gcloud compute ssh sql-patch-vm \
      --project=requestnetwork \
      --zone=us-central1-a \
      --tunnel-through-iap \
      --command="sudo apt-get install -y -qq postgresql-client 2>/dev/null; \
                 PGPASSWORD='${DB_PASS}' psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME}"

# ── 4. Tear down — always clean up the VM when finished ───────────────────────
gcloud compute instances delete sql-patch-vm \
  --project=requestnetwork --zone=us-central1-a --quiet
```

> **Production:** Wrap writes in a transaction — pipe `BEGIN; ... ROLLBACK;` first to dry-run, then re-run with `COMMIT;`:
> ```bash
> printf "BEGIN;\nUPDATE ...;\nROLLBACK;\n" \
>   | gcloud compute ssh sql-patch-vm ... --command="PGPASSWORD=... psql ..."
> ```

### Data Migrations (Seeds)

Both services have a generic seed runner that runs alongside schema migrations. It tracks executed scripts in a `__seed_journal` table — similar to how Drizzle tracks schema migrations — so each script runs exactly once per database.

#### How It Works

1. After `drizzle-kit migrate` completes, the migrate container runs `scripts/db-seed.ts`
2. The runner reads all `*.ts` files in `scripts/db/` sorted by filename
3. Files already recorded in `__seed_journal` are skipped
4. New files are executed in order, each wrapped in a transaction
5. On success the filename is recorded in the journal; on failure the transaction is rolled back and the job exits non-zero

#### Adding a Data Migration

```bash
# In the respective service repo (request-api or request-auth-api):

# 1. Create a new file in scripts/db/ with a numeric prefix for ordering
touch scripts/db/0002_my_data_change.ts
```

Each seed file must export a `run` function that receives a `PoolClient`:

```typescript
import type { PoolClient } from "pg";

export async function run(client: PoolClient): Promise<void> {
  await client.query(
    "UPDATE my_table SET my_column = $1 WHERE condition = $2",
    ["value", "condition"],
  );
}
```

The `client` is already inside a transaction — do not `BEGIN`/`COMMIT` manually. Any thrown error rolls back the transaction and prevents the script from being recorded in the journal.

> **Naming convention:** Use a zero-padded numeric prefix (`0001_`, `0002_`, …) so scripts run in a deterministic order. Never rename a file after it has been merged — the journal tracks by filename.

#### Accessing Other Secrets at Seed Time

The migrate container has `GCP_PROJECT_ID` and `APP_ENV` in its environment and its service account has `roles/secretmanager.secretAccessor` project-wide. Seeds can fetch any GCP secret via the metadata server:

```typescript
import type { PoolClient } from "pg";

async function getSecret(secretName: string): Promise<string> {
  const tokenRes = await fetch(
    "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token",
    { headers: { "Metadata-Flavor": "Google" } },
  );
  const { access_token } = await tokenRes.json();
  const secretRes = await fetch(
    `https://secretmanager.googleapis.com/v1/projects/${process.env.GCP_PROJECT_ID}/secrets/${secretName}-${process.env.APP_ENV}-app-config/versions/latest:access`,
    { headers: { Authorization: `Bearer ${access_token}` } },
  );
  const { payload: { data } } = await secretRes.json();
  return Buffer.from(data, "base64").toString();
}

export async function run(client: PoolClient): Promise<void> {
  const raw = await getSecret("request-some-service");
  const config = JSON.parse(raw);
  await client.query("UPDATE ...", [config.SOME_VALUE]);
}
```

#### Running Seeds Manually

```bash
# Trigger the migrate job (runs schema migrations + seeds)
gcloud run jobs execute request-auth-api-migrate-{env} \
  --region us-central1 --project requestnetwork --wait

# Or run seeds only locally (with DATABASE_URL in .env)
pnpm db:seed
```

#### Re-Running a Seed

Seeds are recorded by filename. To re-run one (e.g. after fixing a bug in it):

```bash
# Connect to the database (see "Running Ad-Hoc SQL" below)
DELETE FROM __seed_journal WHERE name = '0001_my_seed.ts';
# Then re-run the migrate job or pnpm db:seed
```

### Migration Best Practices

- Always generate migrations via `pnpm db:generate` — never write migration SQL by hand
- Test migrations locally before pushing
- Migrations should be backwards-compatible: the old code must still work with the new schema during the rolling deploy window
- Never drop columns or tables in the same PR that removes the code using them — do it in a follow-up after the code change is deployed
- Migration jobs have a 300s timeout (staging) / 600s timeout (production) — keep migrations fast

---

## Deployments & Restarts

### Automatic Deployment (Standard Flow)

All services follow the same pattern:

```
merge to main → Docker build (GHCR) → Deploy to Staging (automatic)
```

Production deployments are triggered by:
- Creating a GitHub Release
- Manual workflow dispatch

### GitHub Repos

| Service | Repository | Staging Workflow | Production Workflow |
|---------|-----------|-----------------|-------------------|
| request-api | `RequestNetwork/request-api` | `deploy-to-staging.yml` | `deploy-to-production.yml` |
| request-auth-api | `RequestNetwork/request-auth-api` | `deploy-to-staging.yml` | `deploy-to-production.yml` |
| request-dashboard | `RequestNetwork/request-dashboard` | `deploy-to-staging.yml` | `deploy-to-production.yml` |
| request-secure-payment | `RequestNetwork/request-secure-payment` | `deploy-to-staging.yml` | N/A (staging only) |

### Restarting a Service (Without Code Changes)

Use this after updating secrets or app config in Secret Manager:

```bash
# Generic pattern
gcloud run services update {cloud-run-service-name} \
  --region=us-central1 --project=requestnetwork \
  --update-env-vars="RESTART_TRIGGER=$(date +%s)"
```

Examples:

```bash
# request-api (staging)
gcloud run services update request-api-stage \
  --region=us-central1 --project=requestnetwork \
  --update-env-vars="RESTART_TRIGGER=$(date +%s)"

# request-auth-api (staging) — restart BOTH HTTP and gRPC services
gcloud run services update request-auth-api-stage \
  --region=us-central1 --project=requestnetwork \
  --update-env-vars="RESTART_TRIGGER=$(date +%s)"

gcloud run services update request-auth-api-grpc-stage \
  --region=us-central1 --project=requestnetwork \
  --update-env-vars="RESTART_TRIGGER=$(date +%s)"

# request-dashboard (staging)
gcloud run services update request-dashboard-stage \
  --region=us-central1 --project=requestnetwork \
  --update-env-vars="RESTART_TRIGGER=$(date +%s)"

# request-secure-payment (staging only)
gcloud run services update request-secure-payment-stage \
  --region=us-central1 --project=requestnetwork \
  --update-env-vars="RESTART_TRIGGER=$(date +%s)"
```

This creates a new revision with the same image, forcing Cloud Run to restart all instances and reload secrets.

> **Important:** The auth-api runs as two Cloud Run services (HTTP + gRPC) from the same image, differentiated by `START_MODE`. When restarting after a config change, restart **both** services.

### Manual Deploy (Trigger Workflow)

```bash
# request-api
gh workflow run deploy-to-staging.yml -R RequestNetwork/request-api
gh workflow run deploy-to-production.yml -R RequestNetwork/request-api

# request-auth-api
gh workflow run deploy-to-staging.yml -R RequestNetwork/request-auth-api
gh workflow run deploy-to-production.yml -R RequestNetwork/request-auth-api

# request-dashboard
gh workflow run deploy-to-staging.yml -R RequestNetwork/request-dashboard
gh workflow run deploy-to-production.yml -R RequestNetwork/request-dashboard

# request-secure-payment (staging only)
gh workflow run deploy-to-staging.yml -R RequestNetwork/request-secure-payment
```

### Deployment Process (What CI/CD Does)

**Backend services (request-api, request-auth-api):**

1. Mirror Docker image from GHCR to Artifact Registry
2. Run database migration job (if `drizzle/` changed)
3. Export current service YAML
4. Pin traffic to current revision
5. Deploy new revision at 0% traffic
6. Tag new revision as `candidate`
7. Health check the candidate URL (5 retries, 10s apart)
8. Shift 100% traffic to the new revision
9. Clean up `candidate` tag
10. *(auth-api only)* Deploy gRPC service with same flow

**Frontend services (dashboard, secure-payment):**

Same canary flow (steps 1, 3-9) but without migration steps.

If the health check fails, traffic stays on the previous revision (automatic rollback).

---

## Rollbacks

### Automatic Rollback

Production deploys automatically roll back if the health check fails — traffic remains on the previous revision.

### Manual Rollback

```bash
# 1. List recent revisions
gcloud run revisions list --service {cloud-run-service-name} \
  --region us-central1 --project requestnetwork --limit 5

# 2. Route traffic to a known-good revision
gcloud run services update-traffic {cloud-run-service-name} \
  --region us-central1 --project requestnetwork \
  --to-revisions=<revision-name>=100
```

> **Auth API:** Remember to roll back both the HTTP and gRPC services if needed.

### Rolling Back a Migration

Drizzle does not support automatic rollback. If a migration needs to be reverted:

1. Write a new migration that undoes the changes
2. Or manually run the reversal SQL via `psql`
3. Deploy the code that is compatible with the reverted schema

---

## Monitoring & Debugging

### Health Checks

```bash
# request-api
curl -sf https://api.stage.request.network/v2/health

# request-auth-api
curl -sf https://auth.stage.request.network/v1/health

# request-dashboard
curl -sf https://dashboard.stage.request.network/

# request-secure-payment
curl -sf https://pay.stage.request.network/
```

### View Logs

```bash
# Service logs (replace service_name as needed)
gcloud logging read 'resource.type="cloud_run_revision"
  AND resource.labels.service_name="{cloud-run-service-name}"' \
  --project=requestnetwork --limit=50 --format=json

# Errors only
gcloud logging read 'resource.type="cloud_run_revision"
  AND resource.labels.service_name="{cloud-run-service-name}"
  AND severity>=ERROR' \
  --project=requestnetwork --limit=20

# Migration job logs
gcloud logging read 'resource.type="cloud_run_job"
  AND resource.labels.job_name="{job-name}"' \
  --project=requestnetwork --limit=20 --format=json
```

Cloud Run service names:
- `request-api-stage` / `request-api-production`
- `request-auth-api-stage` / `request-auth-api-production`
- `request-auth-api-grpc-stage` / `request-auth-api-grpc-production`
- `request-dashboard-stage` / `request-dashboard-production`
- `request-secure-payment-stage`

### Check Service Status

```bash
gcloud run services describe {cloud-run-service-name} \
  --region us-central1 --project requestnetwork \
  --format='yaml(status.conditions)'
```

### Check Current Scaling

```bash
gcloud run services describe {cloud-run-service-name} \
  --region us-central1 --project requestnetwork \
  --format='value(spec.template.metadata.annotations["autoscaling.knative.dev/minScale"],spec.template.metadata.annotations["autoscaling.knative.dev/maxScale"])'
```

---

## Quick Reference

### Common Operations Cheat Sheet

In all commands below, replace `{service}` with `request-api`, `request-auth-api`, `request-dashboard`, or `request-secure-payment` and `{env}` with `stage` or `production`.

| Task | Command |
|------|---------|
| List secrets | `gcloud secrets list --project=requestnetwork --filter="name:{service}" --format="value(name)"` |
| View app config | `gcloud secrets versions access latest --secret={service}-{env}-app-config --project=requestnetwork \| python3 -m json.tool` |
| Add key to app config | `gcloud secrets versions access latest --secret={service}-{env}-app-config --project=requestnetwork \| jq '. + {"KEY": "value"}' \| gcloud secrets versions add {service}-{env}-app-config --project=requestnetwork --data-file=-` |
| Remove key from app config | `gcloud secrets versions access latest --secret={service}-{env}-app-config --project=requestnetwork \| jq 'del(.KEY)' \| gcloud secrets versions add {service}-{env}-app-config --project=requestnetwork --data-file=-` |
| Toggle feature flag | `gcloud secrets versions access latest --secret={service}-{env}-feature-flags --project=requestnetwork \| jq '.FLAG = true' \| gcloud secrets versions add {service}-{env}-feature-flags --project=requestnetwork --data-file=-` |
| Restart service | `gcloud run services update {service}-{env} --region=us-central1 --project=requestnetwork --update-env-vars="RESTART_TRIGGER=$(date +%s)"` |
| Run migration | `gcloud run jobs execute {service}-migrate-{env} --region us-central1 --project requestnetwork --wait` |
| Generate migration | `pnpm db:generate` (in the service repo) |
| Manual deploy | `gh workflow run deploy-to-staging.yml -R RequestNetwork/{service}` |
| View logs | `gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="{service}-{env}"' --project=requestnetwork --limit=50` |
| Rollback | `gcloud run services update-traffic {service}-{env} --region us-central1 --project requestnetwork --to-revisions=<revision>=100` |
