# Contributing to k0n hunter

Thanks for helping improve k0n hunter. A few guidelines keep the framework
consistent and safe.

## Ground rules

- This is a **defensive, authorized-testing** framework. Contributions must not add
  features whose primary purpose is unauthorized access, mass exploitation, DoS,
  detection-evasion for malicious use, or data theft. Dual-use techniques are welcome
  when framed and documented for authorized testing.
- Keep the scope-guard contract intact: agents **reference** `_scope-guard.md`; they
  never weaken, bypass, or duplicate the hard limits.

## Adding or editing an agent

1. Start from `templates/AGENT_TEMPLATE.md`.
2. Keep the frontmatter (`name`, `description`, `tools`).
3. Every finding an agent emits follows the finding-card schema
   (`templates/FINDING_CARD.md`):
   `ID · Title · Severity · Endpoint · Evidence · Status · Preconditions · Chains-with`.
4. Methodology is owned by `plan.md` — **edit `plan.md` first**, then sync `AGENTS.md`.
5. Register the agent's row in `AGENTS.md`.

## Style

- Technical content (endpoints, payloads, tool names, CVE, field values) in English.
- PoCs stay **minimal and non-weaponized** — canary values, no real-data exfiltration.
- Line endings: **LF** (enforced by `.gitattributes`). Shell scripts stay POSIX-friendly bash.

## Tooling

- `tools/check_env.sh` verifies the toolchain; `tools/install_tools.sh` installs it (idempotent).
- Test your changes only on a scope you are authorized to test.
