---
name: agent-name-here
description: >-
  One or two sentences describing exactly when this agent should be used.
  Start with a verb. Be specific about trigger conditions.
tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Agent: [Name]

**Specialty**: [One line — the primary attack surface, e.g. "Horizontal IDOR on web endpoints, integer ID enumeration, cross-tenant access"]
**Inherits**: `_scope-guard.md` + Rules 1.1-1.12 from `plan.md` (scope discipline, in-scope filtering, A/B account discipline, testing depth, OPSEC, autonomy, mindset). Not repeated here — read `plan.md` + `_scope-guard.md` first.
**Requires**: [Account A/B for auth testing | Public access only | Physical device | ...]
**Condition** (from `AGENTS.md`): [Always | Only if GraphQL endpoint exists | Only if mobile in-scope | ...]

---

## Checklist

Organized by attack category. Check means "tested this category on this target."

### Category A: [e.g., IDOR / Horizontal Access]
- [ ] Integer ID enumeration (1-10, own accounts only)
- [ ] UUID/GUID enumeration
- [ ] Cross-account access via token swap
- [ ] Cross-tenant access

### Category B: [e.g., Injections]
- [ ] SQLi (time-based, error-based, union-based)
- [ ] NoSQL injection
- [ ] SSTI (Jinja2, ERB, etc.)

### [Add more categories as needed]

---

## Tools

List tools this agent uses, with key flags/modes:

- **tool1** : Purpose, key command pattern
- **tool2** : Purpose, key flags

---

## PoC Templates

### Finding Class: [e.g., IDOR]

```bash
# Minimal reproduction
curl -H "Authorization: Bearer $TOKEN_A" \
  https://{target}/api/users/{id_from_account_b}
# Expected: 200 + Account B data (vuln) OR 403/404 (secure)
```

### Finding Class: [e.g., SQLi]

```bash
# Time-based differential
time curl "https://{target}/search?q=test' AND SLEEP(5)--"
# Compare response time vs. time curl "https://{target}/search?q=test' AND SLEEP(0)--"
# If sleep-based = time-delayed response → SQLi confirmed
```

**[Add more PoC templates per finding class]**

---

## Handoff to Orchestrator

Signal these to the user if they occur:

- **[Scenario A]** : "Finding X looks real but Y is ambiguous — escalate before reporting"
- **[Scenario B]** : "Requires action that might be destructive — escalate to Tier 5"
- **[Scenario C]** : "Found a chain with [Agent Y] — coordinate handoff"

---

## Output Format

Every finding produced by this agent follows the **finding card standard** (see `FINDING_CARD.md`):

```
ID · Title · Severity · Endpoint · Evidence · Status · Preconditions · Chains-with
```

---

**Notes**:
- Inherits _scope-guard (hard limits, OPSEC tagging, autonomous rules)
- References plan.md for methodology context
- Coordinates with other agents via SIGNAL QUEUE in journal.md
