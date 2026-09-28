#!/usr/bin/env bash
# Checks every tool used across plan.md + the 12 specialist agents.
# Prints OK/MISSING per tool, then a summary. Never installs anything — see install_tools.sh.
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin"

check() {
  local name="$1" bin="${2:-$1}"
  if command -v "$bin" >/dev/null 2>&1; then
    echo "  $name OK -> $(command -v "$bin")"
    return 0
  else
    echo "  $name MISSING"
    return 1
  fi
}

missing=0
total=0
run()     { total=$((total+1)); check "$@" || missing=$((missing+1)); }   # core — counted
run_opt() { check "$@" || true; }                                         # conditional — reported, NOT counted

echo "== Base runtimes (required before anything else can install) =="
uname -a
run go
run python3
run pip3
check npm || echo "  (npm only needed for retire-js / promptfoo)"
check git || echo "  (git required for the clone-based tools)"

echo ""
echo "== Core recon =="
run subfinder
run httpx
run nuclei
run katana
run waybackurls
run gau
run dnsx
run puredns
run tlsx
run wafw00f
run whatweb
run gitleaks
run interactsh-client
run curl
run jq
run dig
run amass
run assetfinder
run gowitness
run bfac
run git-secrets

echo ""
echo "== Web / Injection (web-hunter) =="
run ffuf
run sqlmap
run dalfox
run commix
run tplmap
run oxml_xxe
run lfisuite
run retire

echo ""
echo "== API / GraphQL (api-security, graphql-hunter) =="
run arjun
run kiterunner
run graphqlmap
run clairvoyance
run nosqlmap
run corstest
run graphql-cop
run graphw00f

echo ""
echo "== JWT / Crypto (jwt-cracker) =="
run jwt_tool
run hashcat
run john

echo ""
echo "== Subdomain Takeover =="
run subjack
run subzy
run_opt dnsreaper
run_opt tko-subs

echo ""
echo "== JS / Secrets Recon =="
run linkfinder
run secretfinder
run git-dumper
run trufflehog

echo ""
echo "== PoC Validation =="
run testssl testssl.sh

echo ""
echo "== Cloud (awscli core; az only if Azure surface) =="
run aws
run_opt az

echo ""
echo "== CONDITIONAL — only needed when that lane is in-scope (NOT counted in the summary) =="
echo "-- Mobile (mobile app in-scope) --"
run_opt frida
run_opt objection
run_opt apktool
run_opt jadx
run_opt mitmproxy
run_opt adb
run_opt drozer
run_opt ipatool
echo "-- LLM red-team (AI/LLM features) --"
run_opt promptfoo
run_opt garak

echo ""
echo "== Burp Suite (manual, not scriptable) =="
echo "  InQL, JWT Editor, Autorize — install via Burp BApp Store manually if using Burp"

echo ""
echo "=== SUMMARY: $((total-missing))/$total core tools installed, $missing missing ==="
if [ "$missing" -gt 0 ]; then
  echo "Run ./install_tools.sh to install the missing core tools (skips anything already present)."
  echo "Conditional tools (mobile / LLM / az / dnsreaper / tko-subs) are only needed when that lane is in-scope."
fi
