#!/usr/bin/env bash
# Installs every tool used across plan.md + the 12 specialist agents.
# Skips anything already installed — safe to re-run anytime.
# NOTE: tools are installed ON TOP of base runtimes (go, python3/pip3, git, npm).
#       If a runtime is missing, the prerequisite check below tells you what to get first.
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin"
TOOLS_DIR="$HOME/tools_src"
mkdir -p "$TOOLS_DIR" "$HOME/.local/bin"

# ---------------------------------------------------------------------------
# Prerequisites — the installer needs these runtimes to fetch everything else.
# ---------------------------------------------------------------------------
echo "=== Prerequisites (base runtimes) ==="
prereq_missing=0
for r in go git python3 pip3; do
  command -v "$r" >/dev/null 2>&1 && echo "  $r OK" || { echo "  $r MISSING"; prereq_missing=1; }
done
command -v npm >/dev/null 2>&1 && echo "  npm OK" || echo "  npm MISSING (only needed for retire-js / promptfoo)"
if [ "$prereq_missing" -eq 1 ]; then
  echo ""
  echo "!! Missing base runtime(s). Install them first, then re-run this script:"
  echo "   Debian/WSL : sudo apt update && sudo apt install -y golang-go python3 python3-pip git nodejs npm ruby"
  echo "   macOS      : brew install go python git node ruby"
  echo "   (Go can also be installed from https://go.dev/dl/)"
  echo "   Continuing anyway — go/pip/npm steps will fail until the runtime exists."
  echo ""
fi

skip_if_present() {
  command -v "$1" >/dev/null 2>&1 && { echo ">>> $1 already installed, skipping"; return 0; }
  return 1
}

go_install() {
  local bin="$1" pkg="$2"
  skip_if_present "$bin" && return
  echo ">>> installing $bin (go install $pkg)"
  go install -v "$pkg" && echo "OK $bin" || echo "FAIL $bin"
}

pip_install() {
  local bin="$1" pkg="${2:-$1}"
  skip_if_present "$bin" && return
  echo ">>> installing $bin (pip3 install $pkg)"
  pip3 install --user "$pkg" && echo "OK $bin" || echo "FAIL $bin"
}

npm_install() {
  local bin="$1" pkg="${2:-$1}"
  skip_if_present "$bin" && return
  command -v npm >/dev/null 2>&1 || { echo "SKIP $bin (npm not installed)"; return; }
  echo ">>> installing $bin (npm install -g $pkg)"
  npm install -g "$pkg" && echo "OK $bin" || echo "FAIL $bin"
}

git_clone_tool() {
  # $1 = friendly command name, $2 = repo url, $3 = entry script within repo (optional)
  # Clones into ~/tools_src, installs its requirements.txt if any, and symlinks the
  # entry script into ~/.local/bin so `command -v <name>` finds it (check_env sees it).
  local bin="$1" repo="$2" entry="$3"
  skip_if_present "$bin" && return
  local dest="$TOOLS_DIR/$(basename "$repo" .git)"
  echo ">>> cloning $bin ($repo)"
  [ -d "$dest" ] || git clone --depth 1 "$repo" "$dest"
  [ -f "$dest/requirements.txt" ] && { echo "    installing $bin python deps"; pip3 install --user -r "$dest/requirements.txt" >/dev/null 2>&1; }
  if [ -n "$entry" ] && [ -f "$dest/$entry" ]; then
    chmod +x "$dest/$entry" 2>/dev/null
    ln -sf "$dest/$entry" "$HOME/.local/bin/$bin"
    echo "OK $bin -> ~/.local/bin/$bin"
  else
    echo "NOTE: $bin cloned to $dest — invoke by full path (see agent .md for usage)"
  fi
}

echo ""
echo "=== Go-based tools ==="
go_install subfinder     "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
go_install httpx         "github.com/projectdiscovery/httpx/cmd/httpx@latest"
go_install nuclei        "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
go_install dnsx          "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
go_install katana        "github.com/projectdiscovery/katana/cmd/katana@latest"
go_install gau           "github.com/lc/gau/v2/cmd/gau@latest"
go_install waybackurls   "github.com/tomnomnom/waybackurls@latest"
go_install ffuf          "github.com/ffuf/ffuf/v2@latest"
go_install amass         "github.com/owasp-amass/amass/v4/...@master"
go_install assetfinder   "github.com/tomnomnom/assetfinder@latest"
go_install gowitness     "github.com/sensepost/gowitness@latest"
go_install tlsx          "github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
go_install dalfox        "github.com/hahwul/dalfox/v2@latest"
go_install subzy         "github.com/PentestPad/subzy@latest"
go_install puredns       "github.com/d3mondev/puredns/v2@latest"
go_install interactsh-client "github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
go_install gitleaks      "github.com/gitleaks/gitleaks/v8@latest"
go_install subjack       "github.com/haccer/subjack@latest"
go_install kiterunner    "github.com/assetnote/kiterunner@latest"
go_install trufflehog    "github.com/trufflesecurity/trufflehog/v3@latest"

echo ""
echo "=== Python-based tools (pip3 --user) ==="
pip_install wafw00f
pip_install arjun
pip_install sqlmap
pip_install git-dumper
pip_install clairvoyance
pip_install graphql-cop
pip_install graphw00f
pip_install aws awscli

echo ""
echo "=== npm-based tools ==="
npm_install retire

echo ""
echo "=== Git-clone tools (symlinked into ~/.local/bin when an entry script exists) ==="
git_clone_tool commix       "https://github.com/commixproject/commix.git"     commix.py
git_clone_tool linkfinder   "https://github.com/GerbenJavado/LinkFinder.git"  linkfinder.py
git_clone_tool secretfinder "https://github.com/m4ll0k/SecretFinder.git"      SecretFinder.py
git_clone_tool jwt_tool     "https://github.com/ticarpi/jwt_tool.git"         jwt_tool.py
git_clone_tool graphqlmap   "https://github.com/swisskyrepo/GraphQLmap.git"   graphqlmap.py
git_clone_tool testssl.sh   "https://github.com/drwetter/testssl.sh.git"      testssl.sh
git_clone_tool tplmap       "https://github.com/epinna/tplmap.git"            tplmap.py
git_clone_tool nosqlmap     "https://github.com/codingo/NoSQLMap.git"         nosqlmap.py
git_clone_tool corstest     "https://github.com/RUB-NDS/CORStest.git"         corstest.py
git_clone_tool lfisuite     "https://github.com/D35m0nd142/LFISuite.git"      lfisuite.py
git_clone_tool bfac         "https://github.com/mazen160/bfac.git"            bin/bfac
git_clone_tool oxml_xxe     "https://github.com/BuffaloWill/oxml_xxe.git"
git_clone_tool dnsreaper    "https://github.com/punk-security/dnsReaper.git"  main.py
git_clone_tool tko-subs     "https://github.com/anshumanbh/tko-subs.git"

echo ""
echo "=== git-secrets (clone + make install) ==="
if command -v git-secrets >/dev/null 2>&1; then
  echo ">>> git-secrets already installed, skipping"
else
  git clone --depth 1 https://github.com/awslabs/git-secrets.git "$TOOLS_DIR/git-secrets" 2>/dev/null
  if (cd "$TOOLS_DIR/git-secrets" && sudo make install) 2>/dev/null; then
    echo "OK git-secrets"
  else
    echo "NOTE: git-secrets cloned to $TOOLS_DIR/git-secrets — run 'sudo make install' there manually"
  fi
fi

echo ""
echo "=== System packages (apt — Linux/WSL only) ==="
if command -v apt >/dev/null 2>&1; then
  for pkg in curl jq whatweb hashcat john dnsutils ruby; do
    dpkg -s "$pkg" >/dev/null 2>&1 && echo ">>> $pkg already installed, skipping" || {
      echo ">>> installing $pkg (apt)"
      sudo apt install -y "$pkg" && echo "OK $pkg" || echo "FAIL $pkg"
    }
  done
else
  echo "apt not found — install curl, jq, whatweb, hashcat, john, dig, ruby manually for your OS (brew on macOS)"
fi

echo ""
echo "=== Conditional tools (installed only when their lane is in-scope) ==="
echo "-- Mobile (only if a mobile app is in-scope) --"
echo "   pip3 install --user frida-tools objection drozer"
echo "   apktool + jadx: download from their GitHub releases"
echo "   adb: 'sudo apt install -y android-tools-adb' (Linux)"
echo "   mitmproxy: pip3 install --user mitmproxy"
echo "   ipatool: 'brew install ipatool' (macOS) or a GitHub release binary"
echo "-- Cloud (Azure surface / post-SSRF) --"
echo "   awscli installed above. az cli: 'curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash' (Debian) or 'brew install azure-cli'"
echo "-- LLM red-team (only if AI/LLM features) --"
echo "   npm install -g promptfoo   ;   pip3 install --user garak"

echo ""
echo "=== DONE — run ./check_env.sh to verify ==="
