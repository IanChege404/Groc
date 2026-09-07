# Test Credentials & User Seeding

This document covers how to provision Firebase Authentication users (email +
password) for local development, the staging project, and any one-off
integration testing.

> **Never commit real credentials.** Only the JSON template at
> `scripts/.user-credentials.example.json` is tracked. Real values live in a
> gitignored file.

## Files

| Path | Purpose |
| --- | --- |
| `functions/src/seed_users.ts` | CLI that creates / updates / deletes users via the Firebase Admin SDK. |
| `functions/lib/seed_users.js` | Compiled output produced by `npm --prefix functions run build`. |
| `scripts/.user-credentials.example.json` | Tracked template — copy this to start. |
| `scripts/.user-credentials.json` | **Gitignored.** Your real local values. |
| `scripts/.gitignore` | Ignores `scripts/.user-credentials.json`. |

## One-time setup

1. **Copy the template.**
   ```bash
   cp scripts/.user-credentials.example.json scripts/.user-credentials.json
   ```
   Edit the copy to add the users you need. The schema is:
   ```jsonc
   {
     "email": "[email protected]",          // required
     "password": "DemoPass123",                // required, ≥ 8 chars
     "displayName": "Demo Customer",           // optional
     "isAdmin": false,                         // optional, default false
     "emailVerified": true,                    // optional, default false
     "disabled": false,                        // optional, default false
     "customClaims": { "role": "vip" }         // optional, merged into claims
   }
   ```

2. **Authenticate the Admin SDK.**
   - **Local emulator:** start `firebase emulators:start --only auth,firestore`
     first; the script will auto-discover the emulator endpoints.
   - **Local against staging/dev project:** place a service account JSON at
     `serviceAccountKey.json` (already gitignored) and set
     `GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/serviceAccountKey.json`.
   - **CI / production-like run:** pass `--project-id=<your-project-id>` after
     authenticating with `firebase login` or a workload identity.

3. **(Optional) Type-check before running.**
   ```bash
   npm --prefix functions run build
   ```

## Running the seeder

All commands run from the repo root.

| Intent | Command |
| --- | --- |
| Dry run (validate the JSON only) | `npm --prefix functions run seed:users -- --dry-run` |
| Apply against the current project | `npm --prefix functions run seed:users` |
| Apply against a specific project | `npm --prefix functions run seed:users -- --project-id=my-project` |
| Recreate every listed user | `npm --prefix functions run seed:users -- --reset` |
| Use a non-default credentials file | `npm --prefix functions run seed:users -- --creds=path/to/file.json` |
| Help | `npm --prefix functions run seed:users -- --help` |

Behaviour:

- If a user with the given email already exists, their password, display
  name, disabled flag, email-verified flag and custom claims are updated.
- If `--reset` is supplied, every listed user is deleted first and then
  recreated from scratch. Use it sparingly — it nukes any order history tied
  to those UIDs in Firestore. Use a separate set of emails for staging.
- A corresponding `users/{uid}` Firestore document is written on creation so
  the Flutter app's profile flows have something to read.
- Exit code is non-zero if any user failed to provision.

## Password policy enforced by the seeder

The script mirrors the runtime `/signup` validator in
`functions/src/index.ts:80`:

- ≥ 8 characters
- Email must match `^[^\s@]+@[^\s@]+\.[^\s@]+$`
- No duplicate entries in the same file

## Typical personas

The committed example ships with three roles you can remix:

| Email | Role | Notes |
| --- | --- | --- |
| `[email protected]` | Customer | Verified, normal login. |
| `[email protected]` | Admin | Verified, `isAdmin=true`, custom claim `role=admin` (consumed by `admin/middleware.ts`). |
| `[email protected]` | Disabled | `disabled=true` for testing the "account is disabled" path in `functions/src/index.ts:53`. |

## Security checklist

- [ ] `scripts/.user-credentials.json` is **never** committed (`scripts/.gitignore` already excludes it).
- [ ] Production / staging projects use a service account with the **least privilege** required (`Firebase Authentication Admin` only).
- [ ] Rotate any shared passwords periodically; do not paste them into chat or issue trackers.
- [ ] Treat the seeder as a development convenience — it can mass-disable accounts, so keep it out of any automated deployment pipeline.