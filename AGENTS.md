# AGENTS Index

> **AI agents / assistants working in this repo — start here.** This is **k0n hunter**, an authorized bug-bounty / VDP framework. Whatever tool you run in (Claude Code, Cursor, Codex, Zed, Gemini CLI, …):
>
> 1. **Authorized, defensive security research ONLY** — in-scope assets only, no DoS, no real-user-data exfiltration, no destructive actions, test accounts only. Full hard limits: **`_scope-guard.md`**. Never operate outside them.
> 2. **Read `CLAUDE.md`, then `plan.md` and `_scope-guard.md`, before doing anything.** `plan.md` is the methodology source of truth. (Claude Code loads `CLAUDE.md` automatically; other tools should open it first.)
> 3. **At session start**: show the banner (`tools/banner.txt`), ask the language (**EN default / FR**), then ask for the engagement folder — per `plan.md` → *Agent Initialization Protocol*.
> 4. Delegate by the catalog below. On tools without subagent spawning, work the methodology in a single context.

**Machine-readable catalog of all 12 specialist agents.** Used by the orchestrator to route tasks and by humans to understand who owns what.

Keep one row per agent. Ref column points to the file.

> **Source of truth**: `plan.md` §5.1 (assignment matrix) and §5.2.1 (ownership rules) are authoritative for methodology. The tables here mirror them for quick machine-readable routing — **edit `plan.md` first**, then sync this file.

---

## Index

| Agent | Phase | Specialty | Requires | Condition | Risk | File |
|-------|-------|-----------|----------|-----------|------|------|
| **subdomain-takeover** | recon | Dangling DNS, cloud takeover, default creds | No | Always | active | `subdomain-takeover.md` |
| **web-hunter** | web | XSS, injections, IDOR, access-control bypass, file upload, cache poisoning/deception, request smuggling, Host header attacks | A/B for auth | Always | active | `web-hunter.md` |
| **api-security** | api | BOLA, BFLA, mass assignment, OAuth, rate-limit abuse | A/B | If API exists | active | `api-security.md` |
| **graphql-hunter** | api | GraphQL schema, introspection, batching, complexity abuse, CSRF | A/B | If GraphQL endpoint | active | `graphql-hunter.md` |
| **bizlogic-hunter** | web | Business logic flaws, workflow bypass, race conditions, price manipulation | A/B | Always if workflows exist | active | `bizlogic-hunter.md` |
| **ssrf-hunter** | web | SSRF sinks, filter bypass, cloud metadata | No (often public) | If URL-fetching features | active | `ssrf-hunter.md` |
| **jwt-cracker** | web | JWT/session attacks, account takeover chains, crypto (conditional) | A/B to obtain token | If app has login | active | `jwt-cracker.md` |
| **exploit-chainer** | exploit | Combine findings into chains, score, prioritize | No (works on findings) | After hunters produce findings | active | `exploit-chainer.md` |
| **poc-validator** | exploit | Confirm/reject findings, minimize PoC, kill false positives | No (works on findings) | Before reporting | active | `poc-validator.md` |
| **cloud-security** | cloud | Post-SSRF cloud metadata exploitation, IAM role enumeration | No | Only if SSRF→IMDS confirmed | active | `cloud-security.md` |
| **mobile-pentester** | mobile | Android/iOS decompile, cert-pinning bypass, API extraction | Physical device + A/B | Only if mobile in-scope | active | `mobile-pentester.md` |
| **llm-redteam** | exploit | Prompt injection, tool abuse, RAG poisoning | A/B if behind auth | Only if LLM features | active | `llm-redteam.md` |
| **secrets-hunter** | recon | Exposed secrets, leaked keys/tokens, `.git`/`.env` exposure, open cloud buckets, dorking | No | Always | active | `secrets-hunter.md` |
| **auth-hunter** | web | OAuth/OIDC, SAML, SSO, MFA/2FA bypass, reset/registration flows, session fixation | A/B (+ IdP) | If login/SSO/OAuth | active | `auth-hunter.md` |
| **cve-hunter** | scan | Known-CVE / n-day: fingerprint → CVE map → non-destructive validation | No (some need auth) | Always (light) | active | `cve-hunter.md` |

---

## Ownership Table (Overlapping Domains)

When two agents could test the same thing, this table says **who tests first** and **who only signals**:

| Concept | OWNS (tests) | SIGNALS (notes, doesn't re-test) |
|---------|----------|-----------------|
| Horizontal IDOR on web endpoints | `web-hunter` | — |
| BOLA on REST APIs | `api-security` | `web-hunter` (if stumbled upon) |
| BOLA via GraphQL | `graphql-hunter` | — |
| Mass assignment (extra fields) | `api-security` | `bizlogic-hunter` (only if field has biz impact) |
| Escalation as workflow issue (state-specific) | `bizlogic-hunter` | — |
| Escalation as access-control gap (static) | `web-hunter` OR `api-security` | `bizlogic-hunter` |
| Exposed secrets / leaked keys / open buckets | `secrets-hunter` | any agent that stumbles on one (hands off, doesn't re-test); `cloud-security` exploits a found cloud key |
| Auth **flow** (OAuth/OIDC, SAML, SSO, MFA, reset/registration) | `auth-hunter` | `jwt-cracker` (token crypto) · `api-security` (API scope) |
| Token crypto / session-token forgery | `jwt-cracker` | `auth-hunter` (signals it from the flow) |
| Known CVE / n-day in off-the-shelf components | `cve-hunter` | `web-hunter` (JS-lib CVEs via `retire-js` — first to run owns) |

**Rule of thumb**: If the bug is "the check is missing," it's a hunter's job. If the bug is "a state transition breaks the check," it's `bizlogic-hunter`'s job. If it's "the check exists but the multi-step *flow* around it breaks," it's `auth-hunter`'s job.

---

## Conditional Activation

| Agent | Condition | How to Check |
|-------|-----------|---|
| `graphql-hunter` | GraphQL endpoint exists | curl -X POST https://target/graphql -d '{"query":"{__typename}"}' |
| `bizlogic-hunter` | App has workflows (checkout, auth, approvals, etc.) | Explore the app; look for multi-step processes |
| `cloud-security` | SSRF→IMDS access confirmed | `ssrf-hunter` must find working SSRF first |
| `mobile-pentester` | Mobile app in-scope | Check program scope; requires physical device |
| `llm-redteam` | LLM features present (chat, generation, RAG) | Explore app; look for AI-powered features |
| `auth-hunter` | App has login / OAuth / SAML / SSO / MFA | Look for a login, "Sign in with…", an SSO redirect, or a 2FA step |
| `cve-hunter` | Always (light fingerprint); deep only if a version maps to a CVE | `whatweb` / nuclei tech-detect on alive hosts |

(`secrets-hunter` is **always on** in recon — no condition, like `web-hunter`.)

If condition not met: **skip the agent, note in journal.md as "N/A — [reason]"**

---

## Agent Activation Priority (Feature-First)

1. **High-value features first** (cross-tenant, payments, auth, admin, custom code)
   - Activate: `web-hunter`, `api-security`, `bizlogic-hunter`, `jwt-cracker`, `auth-hunter` (if login/SSO/OAuth)
2. **Discovery & infrastructure**
   - Activate: `subdomain-takeover`, `secrets-hunter`, `ssrf-hunter`, `cve-hunter` (after fingerprint)
3. **Specialized** (conditional)
   - Activate: `graphql-hunter` (if endpoint), `llm-redteam` (if features), `mobile-pentester` (if app), `cloud-security` (if SSRF)
4. **Post-hunting**
   - Activate: `exploit-chainer` (combine low-severity into chains)
   - Activate: `poc-validator` (confirm before reporting)

---

## Handoff Coordination

Handoffs happen via `journal.md`:
- **SIGNAL QUEUE** (mid-hunting) : `[Agent X → Agent Y] Finding desc`
- **Exploit chains** (after hunting) : `exploit-chainer` reads all findings, builds chains
- **Validation** (before report) : `poc-validator` reviews all findings, confirms/rejects

---

**Last Updated**: 2026-09-20  
**Schema Version**: 1.0
