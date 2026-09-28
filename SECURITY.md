# Security & Responsible Use

## What this is

k0n hunter is an **authorized-testing** framework for bug-bounty and Vulnerability
Disclosure Programs (VDP). It exists for **defensive security research** — finding
and responsibly disclosing vulnerabilities under an explicit authorization
(Safe Harbor / declared program scope).

## Acceptable use

Use k0n hunter **only** against assets you are explicitly authorized to test:

- targets inside a bug-bounty / VDP program's declared scope, or
- systems you own or have written permission to test.

## Hard limits (enforced by `_scope-guard.md`)

- **In-scope assets only** — parsed from `scope.md`, enforced strictly.
- **No DoS**, resource exhaustion, or brute-force.
- **No exfiltration of real user data** — canary values / test accounts only.
- **No destructive actions** (delete, drop, truncate, wipe).
- **No social engineering or phishing.**
- **Test accounts only** for authenticated testing.

Testing anything you are not authorized to test may be **illegal**. You are solely
responsible for how you use this tool. The authors accept no liability for misuse
(see `LICENSE`).

## Reporting a vulnerability in k0n hunter itself

Found a bug in this framework (not in a target)? Open a GitHub issue, or for
anything sensitive use the repository's private security advisory feature.
Please never include real client or engagement data in a report.
