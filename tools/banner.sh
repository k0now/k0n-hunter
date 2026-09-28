#!/usr/bin/env bash
# Prints the k0n hunter banner in white.
# Honors NO_COLOR, a non-TTY stdout (piped/redirected), and a --no-color flag.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BANNER="$DIR/banner.txt"

if [ ! -f "$BANNER" ]; then
  echo "k0n hunter"
  exit 0
fi

use_color=1
if [ -n "${NO_COLOR:-}" ] || [ "${1:-}" = "--no-color" ] || [ ! -t 1 ]; then
  use_color=0
fi

if [ "$use_color" -eq 1 ]; then
  printf '\033[97;1m'   # bright white, bold
  cat "$BANNER"
  printf '\033[0m\n'
else
  cat "$BANNER"
  echo
fi
