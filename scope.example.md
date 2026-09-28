# Engagement Scope — {Program Name}

> Copy this file to `scope.md` **inside your engagement folder** and fill it in.
> `scope.md` is gitignored — it is never committed.

## Program
- Platform: HackerOne | Bugcrowd | Intigriti | YesWeHack | self-hosted
- Type: VDP | Bug Bounty
- Program URL: https://...
- Researcher handle: your-platform-username
  # used for the identifying User-Agent, journal, and report attribution

## In Scope
- example.com
- *.example.com
- api.example.com
- https://app.example.com/*

## Out of Scope
- admin.example.com
- *.internal.example.com
- Third-party services (SSO providers, CDNs, payment processors, support desks)

## Rules of Engagement
- Max request rate: 10–20 req/s (conservative default — never DoS)
- Testing window: anytime | off-hours only (state the timezone)
- Prohibited: DoS / stress testing, automated scanning against production,
  social engineering, physical, anything touching real user data
- Required identifier: User-Agent must carry your handle, e.g.
  `research: your-handle (+https://hackerone.com/your-handle)`
- Any program-specific constraints go here.
