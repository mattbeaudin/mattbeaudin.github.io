#!/usr/bin/env bash
# Self-check for frame.sh: renders every mode from generated fixtures.
set -euo pipefail
here=$(dirname "$(realpath "$0")")
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
fail() { echo "FAIL: $*" >&2; exit 1; }
dims() { ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=x "$1"; }

ffmpeg -loglevel error -f lavfi -i testsrc=size=1280x800 -frames:v 1 "$t/web.png"
ffmpeg -loglevel error -f lavfi -i testsrc=size=390x844 -frames:v 1 "$t/phone.png"
printf '$ curl localhost:8080/api\n<html> & "quotes" -> ok\n' > "$t/term.txt"
printf 'graph LR\n  A[Client] --> B[API] --> C[(Postgres)]\n' > "$t/ok.mmd"
printf 'graph LR\n  A --> \n  ((( nope\n' > "$t/bad.mmd"
printf 'graph TD\n  A-->B-->C-->D-->E-->F-->G-->H\n' > "$t/tall.mmd"
for i in $(seq 15); do printf '%03d %s\n' "$i" "$(printf 'x%.0s' $(seq 95))"; done > "$t/long.txt"

"$here/frame.sh" browser "$t/web.png" "$t/browser.webp"
"$here/frame.sh" phone "$t/phone.png" "$t/phone.webp"
"$here/frame.sh" terminal "$t/term.txt" "$t/terminal.webp"
"$here/frame.sh" diagram "$t/ok.mmd" "$t/diagram.webp"
"$here/frame.sh" browser "$t/web.png" "$t/browser-thumb.webp" thumb
"$here/frame.sh" phone "$t/phone.png" "$t/phone-thumb.webp" thumb

[[ $(dims "$t/browser.webp") == 1200x* ]] || fail "browser width $(dims "$t/browser.webp")"
[[ $(dims "$t/phone.webp") == 640x* ]] || fail "phone width $(dims "$t/phone.webp")"
[[ $(dims "$t/terminal.webp") == 560x* ]] || fail "terminal width $(dims "$t/terminal.webp")"
[[ $(dims "$t/diagram.webp") == 1000x* ]] || fail "diagram width $(dims "$t/diagram.webp")"
[[ $(dims "$t/browser-thumb.webp") == 1600x1000 ]] || fail "browser thumb $(dims "$t/browser-thumb.webp")"
[[ $(dims "$t/phone-thumb.webp") == 1600x1000 ]] || fail "phone thumb $(dims "$t/phone-thumb.webp")"

# Thumbs must fit, not crop: an overflowing thumb never becomes ready, so frame.sh fails.
"$here/frame.sh" diagram "$t/tall.mmd" "$t/diagram-thumb.webp" thumb || fail "tall diagram thumb overflowed"
"$here/frame.sh" terminal "$t/long.txt" "$t/terminal-thumb.webp" thumb || fail "long terminal thumb overflowed"

! "$here/frame.sh" diagram "$t/bad.mmd" "$t/bad.webp" 2>/dev/null || fail "bad mermaid did not fail"
! "$here/frame.sh" browser "$t/missing.png" "$t/x.webp" 2>/dev/null || fail "missing input did not fail"
! "$here/frame.sh" sideways "$t/web.png" "$t/x.webp" 2>/dev/null || fail "unknown mode did not fail"

# Keep the outputs for a visual check when asked.
if [[ ${KEEP:-} ]]; then cp "$t"/*.webp "$KEEP"/; fi
echo "PASS"
