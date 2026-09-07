import * as admin from "firebase-admin";
import * as fs from "node:fs";
import * as path from "node:path";

interface SeedUser {
  email: string;
  password: string;
  displayName?: string;
  isAdmin?: boolean;
  emailVerified?: boolean;
  disabled?: boolean;
  customClaims?: Record<string, unknown>;
}

interface Config {
  credentialsPath: string;
  dryRun: boolean;
  reset: boolean;
  projectId?: string;
}

function printUsage(): void {
  console.log("Firebase Auth user seeder");
  console.log(
    "Usage: npm --prefix functions run seed:users -- [options]"
  );
  console.log("Options:");
  console.log(
    "  --creds=<path>          Path to user credentials JSON file (default: scripts/.user-credentials.json)"
  );
  console.log(
    "  --dry-run               Validate and print summary without touching Firebase"
  );
  console.log(
    "  --reset                 Delete all listed users before recreating them"
  );
  console.log(
    "  --project-id=<id>       Override the default Firebase project id"
  );
  console.log("  --help, -h              Show this message");
}

function parseArgs(argv: string[]): Config {
  let credentialsPath = path.resolve(
    process.cwd(),
    "../scripts/.user-credentials.json"
  );
  let dryRun = false;
  let reset = false;
  let projectId: string | undefined;

  for (const arg of argv) {
    if (arg === "--dry-run") {
      dryRun = true;
      continue;
    }
    if (arg === "--reset") {
      reset = true;
      continue;
    }
    if (arg.startsWith("--creds=")) {
      credentialsPath = path.resolve(arg.substring("--creds=".length));
      continue;
    }
    if (arg.startsWith("--project-id=")) {
      projectId = arg.substring("--project-id=".length).trim();
      continue;
    }
    if (arg === "--help" || arg === "-h") {
      printUsage();
      process.exit(0);
    }
    throw new Error(`Unknown argument: ${arg}`);
  }

  return {credentialsPath, dryRun, reset, projectId};
}

function loadUsers(filePath: string): SeedUser[] {
  if (!fs.existsSync(filePath)) {
    throw new Error(
      `Credentials file not found at ${filePath}. ` +
        "Copy scripts/.user-credentials.example.json to .user-credentials.json and edit it."
    );
  }

  const raw = fs.readFileSync(filePath, "utf8");
  let parsed: unknown;
  try {
    parsed = JSON.parse(raw);
  } catch (err) {
    throw new Error(
      `Failed to parse ${filePath} as JSON: ${(err as Error).message}`
    );
  }

  if (!Array.isArray(parsed)) {
    throw new Error(
      `Expected ${filePath} to contain a JSON array of users, got ${typeof parsed}.`
    );
  }

  const seen = new Set<string>();
  const users: SeedUser[] = [];
  for (const entry of parsed) {
    if (
      typeof entry !== "object" ||
      entry === null ||
      typeof (entry as SeedUser).email !== "string" ||
      typeof (entry as SeedUser).password !== "string"
    ) {
      throw new Error(
        "Each user entry must be an object with at least `email` and `password` strings."
      );
    }
    const user = entry as SeedUser;
    if (user.password.length < 8) {
      throw new Error(
        `User ${user.email}: password must be at least 8 characters (matches the /signup validator).`
      );
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user.email)) {
      throw new Error(`User ${user.email}: invalid email format.`);
    }
    if (seen.has(user.email)) {
      throw new Error(`Duplicate email in credentials file: ${user.email}.`);
    }
    seen.add(user.email);
    users.push(user);
  }

  return users;
}

function summarize(users: SeedUser[]): void {
  console.log(`Found ${users.length} user(s):`);
  for (const user of users) {
    const role = user.isAdmin ? "admin" : "customer";
    const verified = user.emailVerified ? "verified" : "unverified";
    console.log(
      `  - ${user.email}  (${role}, ${verified})  displayName="${
        user.displayName ?? user.email.split("@")[0]
      }"`
    );
  }
}

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));

  if (args.projectId) {
    if (!admin.apps.length) {
      admin.initializeApp({projectId: args.projectId});
    } else {
      admin.app().options.projectId = args.projectId;
    }
  } else if (!admin.apps.length) {
    admin.initializeApp();
  }

  const auth = admin.auth();
  const users = loadUsers(args.credentialsPath);
  summarize(users);

  if (args.dryRun) {
    console.log(
      "\nDry-run mode: no changes made to Firebase. Re-run without --dry-run to apply."
    );
    return;
  }

  let created = 0;
  let updated = 0;
  let skipped = 0;
  let failed = 0;

  if (args.reset) {
    console.log("\n--reset supplied: deleting listed users first...");
    for (const user of users) {
      try {
        const existing = await auth.getUserByEmail(user.email).catch(() => null);
        if (existing) {
          await auth.deleteUser(existing.uid);
          console.log(`  deleted ${user.email} (${existing.uid})`);
        }
      } catch (err) {
        console.warn(
          `  could not reset ${user.email}: ${(err as Error).message}`
        );
        failed += 1;
      }
    }
  }

  for (const user of users) {
    try {
      const existing = await auth.getUserByEmail(user.email).catch(() => null);
      if (existing) {
        await auth.updateUser(existing.uid, {
          password: user.password,
          displayName: user.displayName ?? user.email.split("@")[0],
          emailVerified: user.emailVerified ?? false,
          disabled: user.disabled ?? false,
        });
        if (user.customClaims) {
          await auth.setCustomUserClaims(existing.uid, user.customClaims);
        }
        console.log(`  updated ${user.email} (${existing.uid})`);
        updated += 1;
      } else {
        const createdUser = await auth.createUser({
          email: user.email,
          password: user.password,
          displayName: user.displayName ?? user.email.split("@")[0],
          emailVerified: user.emailVerified ?? false,
          disabled: user.disabled ?? false,
        });
        await auth.setCustomUserClaims(createdUser.uid, {
          isAdmin: user.isAdmin ?? false,
          createdAt: new Date().toISOString(),
          ...(user.customClaims ?? {}),
        });

        await auth.app.firestore().collection("users").doc(createdUser.uid).set(
          {
            email: user.email,
            displayName: user.displayName ?? user.email.split("@")[0],
            isAdmin: user.isAdmin ?? false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );

        console.log(`  created ${user.email} (${createdUser.uid})`);
        created += 1;
      }
    } catch (err) {
      const code = (err as {code?: string}).code;
      if (code === "auth/email-already-exists") {
        console.log(`  skipped ${user.email} (already exists, no --reset)`);
        skipped += 1;
      } else {
        console.error(
          `  failed  ${user.email}: ${(err as Error).message}`
        );
        failed += 1;
      }
    }
  }

  console.log(
    `\nDone. created=${created} updated=${updated} skipped=${skipped} failed=${failed}`
  );
  if (failed > 0) {
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error("seed_users.ts failed:", err);
  process.exit(1);
});