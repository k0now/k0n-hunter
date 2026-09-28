# Finding Card Standard

**Every finding produced by any agent follows this schema.** This is the contract of inter-agent communication and the atomic unit of the 6-tier deliverable.

---

## Structure

```
ID · Title · Severity · Endpoint · Evidence · Status · Preconditions · Chains-with
```

---

## Fields (Detailed)

### ID
- Format: `F001`, `F002`, etc. (sequential per engagement)
- Unique within the engagement
- Used to reference in journal.md, exploit chains, remediation roadmap

### Title
- Short, specific name of the vulnerability
- Example: "IDOR sur /api/orders/{id} — accès cross-compte"
- NOT: "Access control issue" (vague) or "Vulnerability found" (empty)

### Severity
- **Critical** : Immediate exploitation, full system/data compromise, RCE, account takeover
- **High** : Feasible exploitation, significant data exposure, privilege escalation
- **Medium** : Exploitation requires specific conditions, moderate impact
- **Low** : Limited impact or high prerequisites
- **Informational** : Best practice, no direct security impact
- **Needs-dig** (special) : Looks suspicious but need more testing to confirm

### Endpoint
- Full URL or API path (or file, port, service) where the vulnerability exists
- Example: `https://api.target.com/v2/orders/{id}` or `/admin/panel` or `10.0.1.50:3306`
- Include parameters if relevant: `?sort=name&order=asc`

### Evidence
- Raw evidence of the vulnerability (curl output, screenshot, tool output, response body)
- Minimal PoC that reproduces it (2-3 commands, no more)
- If sensitive: redact real data, use canary values
- Format: code block with exact command + actual output

Example:
```bash
$ curl -H "Authorization: Bearer $TOKEN_A" \
  https://api.target.com/v2/orders/42
{
  "orderId": 42,
  "customerId": "victim-123",
  "total": 599.99
}
```

### Status
- **CONFIRMED** : PoC validated, reproducible, ready to report
- **FALSE_POSITIVE** : Initially flagged but ruled out (explain why)
- **NEEDS_REVIEW** : Validation requires second test account or irreversible action (escalated to Tier 5)
- **SIGNAL** : Informational/observation, not a finding (goes to Tier 3)

### Preconditions
- What must be true for the vulnerability to exist / be exploitable
- Example: "Account A can request any Account B resource" or "GraphQL introspection enabled"
- Example: "Requires authenticated session" or "Public endpoint, no auth needed"
- Example: "Depends on victim clicking a link"

### Chains-with
- List of other finding IDs that **chain into this one**
- Or: "Chains into [F003, F007]" if this finding enables other findings
- Format: `[F001, F003]` or `None` if it doesn't chain
- Used by `exploit-chainer.md` to identify attack paths

---

## Full Example

```
ID: F005
Title: Insecure deserialization → RCE (gadget chain Ysoserial)
Severity: Critical
Endpoint: POST https://api.target.com/v2/webhook/sync (Content-Type: application/x-java-serialized-object)

Evidence:
java -jar ysoserial.jar CommonsCollections5 'touch /tmp/pwned' | base64 > payload.b64
curl -X POST https://api.target.com/v2/webhook/sync \
  -H "Content-Type: application/x-java-serialized-object" \
  --data-binary @payload.b64

Response: 200 OK, command executed on server (confirmed via log analysis)

Status: CONFIRMED
Preconditions: 
- Endpoint accepts serialized Java objects
- Commons Collections library on classpath (version < 3.2.2)
- Server deserializes user input without validation

Chains-with: [F001 (initial access via webhook), F008 (post-exploitation via RCE)]
```

---

## Usage in 6-Tier Deliverable

### Tier 1: Confirmed Findings
- Status: CONFIRMED only
- Severity: High, Critical, Medium (in that order)
- Include Evidence + Status + endpoint

### Tier 2: Borderline / Needs-Dig
- Status: NEEDS_REVIEW or "looks real but ambiguous"
- Include: Why it might be a bug + direction to make it reportable

### Tier 3: Observations & Signals
- Status: SIGNAL
- Include: Why it matters (inforant) + potential to chain

### Tier 4: Eliminated Surface
- Status: CONFIRMED (but negative result)
- Example: "IDOR on /api/users/{id} tested, NOT vulnerable (403 on cross-account)"

### Tier 5: Manual Follow-up
- Status: NEEDS_REVIEW
- Include: Exact steps + why manual confirmation needed (destructive, needs second account, etc.)

### Tier 6: Not Tested & Why
- Include: Scope exclusions, blocked features, reasons

---

## Consistency Rules

**Every card must have**:
- ✅ ID (unique)
- ✅ Title (specific, not generic)
- ✅ Severity (one of the 6 levels)
- ✅ Endpoint (exact URL or path)
- ✅ Evidence (raw curl output or screenshot, minimal PoC)
- ✅ Status (CONFIRMED / FALSE_POSITIVE / NEEDS_REVIEW / SIGNAL)
- ✅ Preconditions (what must be true)
- ✅ Chains-with (chain list or None)

**If any field is missing, the finding is incomplete and cannot be reported.**

---

## Storage

- **During testing** : cards live in `findings/F0XX-*.md` (one file per finding)
- **In journal.md** : SIGNAL QUEUE references them by ID
- **In final deliverable** : FINDINGS.md aggregates all 6 tiers with cross-references to individual cards

---

**Last Updated**: 2026-09-20
