<!-- banner -->
```
██╗  ██╗ ██████╗ ███╗   ██╗  ██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗
██║ ██╔╝██╔═████╗████╗  ██║  ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
█████╔╝ ██║██╔██║██╔██╗ ██║  ███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
██╔═██╗ ████╔╝██║██║╚██╗██║  ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
██║  ██╗╚██████╔╝██║ ╚████║  ██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
        authorized VDP / bug-bounty framework · defensive only · v1.0
```

# k0n hunter

An autonomous, multi-agent **bug-bounty / VDP framework** for [Claude Code](https://claude.com/claude-code). One orchestrator delegates to **15 specialist agents**, hunts end-to-end from recon to a structured deliverable, and reports back in a clean triage summary. Bilingual: **English by default, French on request**.

![License](https://img.shields.io/badge/license-MIT-green) ![Runs on](https://img.shields.io/badge/runs%20on-Claude%20Code-blue) ![Languages](https://img.shields.io/badge/lang-EN%20%C2%B7%20FR-lightgrey)

---

## ⚠️ Legal & Ethical — read first

k0n hunter is for **authorized, defensive security research only** — bug-bounty and Vulnerability Disclosure Programs covered by Safe Harbor, or systems you own or have **written permission** to test.

It enforces hard limits (in `_scope-guard.md`): in-scope only, **no DoS**, no real-user-data exfiltration, no destructive actions, no social engineering, test accounts only. Testing anything you are not authorized to test may be **illegal** — you alone are responsible for how you use it. See [`SECURITY.md`](SECURITY.md) and [`LICENSE`](LICENSE).

---

## What it is

- **Orchestrator + 15 specialists.** A feature-first hunt that routes each attack surface to the agent that owns it, coordinates handoffs, chains findings, and validates before reporting.
- **Autonomous middle.** After the initial "go" it never stalls: anything it can't do (missing creds, a tool that needs Burp, a destructive step) is skipped, logged, and surfaced at the end — the run always reaches a deliverable.
- **Structured output.** Every finding is a **finding card** (`ID · Title · Severity · Endpoint · Evidence · Status · Preconditions · Chains-with`), routed into a **6-tier deliverable** (`findings/FINDINGS.md`), plus a scannable chat summary.

## How it works

```
Init (banner + language + scope)
        │
        ▼
   Recon phase ──► in-scope filtering ──► optional automated scan
        │
        ▼
   Delegate to specialists  ──►  finding cards
        │
        ├─► exploit-chainer   (combine low-sev into chains)
        ├─► poc-validator     (confirm / reject, minimize PoC)
        │
        ▼
   6-tier deliverable  +  chat triage summary
```

## The 15 specialist agents

| Agent | Phase | Specialty |
|-------|-------|-----------|
| `subdomain-takeover` | recon | Dangling DNS, cloud takeover, default creds |
| `web-hunter` | web | XSS, injections, IDOR, access-control bypass, upload, cache poisoning, smuggling, Host header |
| `api-security` | api | BOLA, BFLA, mass assignment, OAuth, rate-limit abuse |
| `graphql-hunter` | api | Schema/introspection, batching, complexity abuse, CSRF |
| `bizlogic-hunter` | web | Business-logic flaws, workflow bypass, race conditions, price manipulation |
| `ssrf-hunter` | web | SSRF sinks, filter bypass, cloud metadata |
| `jwt-cracker` | web | JWT/session attacks, account-takeover chains |
| `exploit-chainer` | exploit | Combine findings into chains, score, prioritize |
| `poc-validator` | exploit | Confirm/reject, minimize PoC, kill false positives |
| `cloud-security` | cloud | Post-SSRF metadata exploitation, IAM enumeration |
| `mobile-pentester` | mobile | Android/iOS decompile, cert-pinning bypass, API extraction |
| `llm-redteam` | exploit | Prompt injection, tool abuse, RAG poisoning |
| `secrets-hunter` | recon | Exposed secrets, leaked keys, `.git`/`.env` exposure, open cloud buckets, dorking |
| `auth-hunter` | web | OAuth/OIDC, SAML, SSO, MFA/2FA bypass, reset/registration flows, session fixation |
| `cve-hunter` | scan | Known-CVE / n-day: fingerprint → CVE map → non-destructive validation |

Routing, ownership of overlapping domains, and conditional activation live in [`AGENTS.md`](AGENTS.md).

## Requirements

- **[Claude Code](https://claude.com/claude-code)** (primary — everything works out of the box), or another AI coding agent (Cursor, Codex, Zed, … — see [Using with other agents](#using-with-other-agents)).
- A **Unix-like shell**: Linux, macOS, or **WSL / Git-Bash on Windows** (the tool scripts are bash).
- **Base runtimes** (a prerequisite the installer can't bootstrap): `go`, `python3` / `pip3`, `git`, and `npm` (for a couple of tools).

## Install

```bash
git clone https://github.com/<your-username>/k0n-hunter.git
cd k0n-hunter

# 1) see what's present / missing (installs nothing)
./tools/check_env.sh

# 2) install the missing tooling (idempotent — skips what's already there)
./tools/install_tools.sh
```

On a fresh machine the agent checks the environment first, tells you exactly what base runtime to install if one is missing, and asks before installing anything. Missing a tool never kills a run — that lane is skipped and logged, the rest keeps going.

## Usage

1. Open the repo folder in Claude Code.
2. It shows the banner and asks the **language** (`EN` default / `FR`).
3. Point it at your **engagement folder** (holding your `scope.md` — copy [`scope.example.md`](scope.example.md) to start; add `credentials.json` from [`credentials.example.json`](credentials.example.json) for authenticated testing).
4. Confirm, and it runs the autonomous hunt, then hands you the deliverable + a chat summary.

Your `scope.md`, `credentials.json`, `journal.md`, and `findings/` are **gitignored** — engagement data never gets committed.

## Using with other agents

k0n hunter is **built for Claude Code** — that's where the banner, language init, auto-loaded context, and 12-subagent delegation work with zero setup. But the whole thing is plain Markdown + bash, so it's portable:

| Tool | How it picks it up |
|------|--------------------|
| **Claude Code** | Loads `CLAUDE.md` automatically — nothing to do. |
| **Cursor** | Reads `.cursorrules` (bootstraps to `CLAUDE.md` + `plan.md`). |
| **Codex · Zed · Gemini CLI · other `AGENTS.md`-aware tools** | Read `AGENTS.md` — its top block bootstraps the run. |
| **Any other agent** | Tell it once: *"read `plan.md` and `_scope-guard.md` first, then follow them."* |

On tools without subagent spawning you don't get automatic delegation — the agent works the methodology in a single context instead. The hard limits in `_scope-guard.md` apply everywhere, on every tool.

## What the output looks like

The full deliverable is written to `findings/FINDINGS.md` (6 tiers, one card per finding). In chat you get the conclusion at a glance:

```
🎯 acme-corp.com — run complete. Full detail in findings/FINDINGS.md

🔴 2 confirmed   🟠 2 to dig   🟢 2 eliminated   ⚪ 3 not tested

CONFIRMED
🔴 [HIGH] F001 · IDOR on /api/v2/orders/{id} — read any customer's order (cross-account)
🔴 [MED]  F002 · Stored XSS in profile display name — JS runs on any visitor

TO DIG
🟠 F003 · Blind SSRF on /webhooks — needs an OOB hit to confirm (chains with F001 → big)

BOTTOM LINE
Auth layer is the story: F001 + F003 chained = full customer data + internal pivot.
→ Next move: confirm F003 via interactsh, then sweep sibling /api/v2/{object}/{id} endpoints.
```

- 🔴 confirmed & reportable · 🟠 needs digging / manual step · 🟢 tested & clean · ⚪ not tested

## Project layout

```
CLAUDE.md            always-loaded security context + entry point
plan.md              methodology (source of truth): init, recon, delegation, deliverable
_scope-guard.md      shared hard limits, OPSEC tagging, autonomy, language rule
AGENTS.md            machine-readable agent catalog + routing
*.md                 the 15 specialist agents
templates/           AGENT_TEMPLATE.md · FINDING_CARD.md
tools/               banner.sh · banner.txt · check_env.sh · install_tools.sh
*.example.*          scope / credentials / env templates
```

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Keep the scope-guard contract intact; PoCs stay minimal and non-weaponized.

## License

[MIT](LICENSE) © 2026 k0n.

---

<sub>Based on and forked from [matty69v/Bug-Bounty-Agents](https://github.com/matty69v/Bug-Bounty-Agents) (MIT). Extended and restructured by k0n — bilingual init, banner, cold-start tooling, chat triage summary, and repo hardening.</sub>
