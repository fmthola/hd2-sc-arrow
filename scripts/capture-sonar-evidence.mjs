// Capture screenshots of the SonarQube web UI as evidence.
//
// SonarQube is a web app, so a browser driver (Playwright) is the right tool
// here. This is separate from the app E2E, which uses tauri-driver.
//
// Requirements:
//   - A reachable SonarQube server.
//   - Playwright + a chromium build available to Node.
//
// The server URL and admin password are injected from the local credential
// store by scripts/sonar-evidence.sh (the preferred entry point). They are
// never hardcoded here.
//
// Env (all supplied by scripts/sonar-evidence.sh):
//   SONAR_HOST_URL        required
//   SONAR_ADMIN_PASSWORD  required
//   SONAR_PROJECT_KEY     default helldivers2modmanager-linux
//   SONAR_ADMIN_USER      default admin
//   PLAYWRIGHT_REQUIRE_BASE  dir to resolve the 'playwright' module from
//
// Run: scripts/sonar-evidence.sh

import { createRequire } from "node:module";
import { mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

// Resolve the 'playwright' module. Try, in order: an explicit base, the project,
// then the shared runner cache.
function loadChromium() {
  const bases = [
    process.env.PLAYWRIGHT_REQUIRE_BASE,
    process.cwd(),
    process.env.HOME ? `${process.env.HOME}/.cache/playwright-runner` : null,
  ].filter(Boolean);
  for (const b of bases) {
    try {
      return createRequire(resolve(b) + "/")("playwright").chromium;
    } catch { /* try next */ }
  }
  throw new Error("playwright not found; set PLAYWRIGHT_REQUIRE_BASE to its install dir");
}
const chromium = loadChromium();

const HOST = process.env.SONAR_HOST_URL;
const KEY = process.env.SONAR_PROJECT_KEY || "helldivers2modmanager-linux";
const USER = process.env.SONAR_ADMIN_USER || "admin";
const PASS = process.env.SONAR_ADMIN_PASSWORD;

// URL and password are injected from the credential store by scripts/sonar-evidence.sh.
if (!HOST) {
  console.error("SONAR_HOST_URL is required (use scripts/sonar-evidence.sh)");
  process.exit(2);
}
if (!PASS) {
  console.error("SONAR_ADMIN_PASSWORD is required (use scripts/sonar-evidence.sh)");
  process.exit(2);
}

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const out = resolve(root, "docs/evidence");
mkdirSync(out, { recursive: true });

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1440, height: 1600 } });

async function shot(path, name) {
  await page.goto(`${HOST}${path}`, { waitUntil: "networkidle" });
  await page.waitForTimeout(2500);
  await page.screenshot({ path: `${out}/${name}`, fullPage: true });
  console.log(`captured: ${name}`);
}

try {
  await page.goto(`${HOST}/sessions/new`, { waitUntil: "networkidle" });
  await page.fill('input[name="login"]', USER);
  await page.fill('input[name="password"]', PASS);
  await Promise.all([
    page.waitForResponse((r) => r.url().includes("/api/authentication/login"), { timeout: 15000 }),
    page.click('button[type="submit"]'),
  ]);
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1500);
  console.log("logged in");

  await shot(`/dashboard?id=${KEY}`, "sonar-dashboard.png");
  await shot(`/project/issues?id=${KEY}&resolved=false&s=SEVERITY&asc=false`, "sonar-issues.png");
  await shot(`/component_measures?id=${KEY}`, "sonar-measures.png");
} finally {
  await browser.close();
}
