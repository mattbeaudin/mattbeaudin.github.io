#!/usr/bin/env bash
# Usage: frame.sh <browser|phone|terminal|diagram> <input> <out.webp> [thumb]
# Frames one image with frame.html, renders it with Playwright, writes WebP.
set -euo pipefail
[[ $# -ge 3 ]] || { echo "usage: frame.sh <mode> <input> <out.webp> [thumb]" >&2; exit 1; }
mode=$1 in=$2 out=$3 thumb=${4:-}
[[ -f $in ]] || { echo "frame.sh: input not found: $in" >&2; exit 1; }
here=$(dirname "$(realpath "$0")")
dir=$(mktemp -d); trap 'rm -rf "$dir"' EXIT
esc() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$1"; }

case $mode in
	browser) width=1200; cp "$in" "$dir/raw"; content='<img src="raw" alt="">' ;;
	phone)   width=640;  cp "$in" "$dir/raw"; content='<img src="raw" alt="">' ;;
	terminal) width=560;  content="<pre>$(esc "$in")</pre>" ;;
	diagram)  width=1000; content="<pre class=\"mermaid\">$(esc "$in")</pre>" ;;
	*) echo "frame.sh: unknown mode: $mode" >&2; exit 1 ;;
esac

classes=$mode
if [[ $thumb ]]; then classes+=" thumb"; size="1600, 1000"; full=(); else size="$width, 100"; full=(--full-page); fi

tpl=$(<"$here/frame.html")
tpl=${tpl/"{{MODE}}"/"$classes"}
printf '%s' "${tpl/"{{CONTENT}}"/"$content"}" > "$dir/shot.html"

timeout 60 npx -y playwright@1.62.1 screenshot "${full[@]}" --viewport-size "$size" \
	--wait-for-selector 'body.ready' "file://$dir/shot.html" "$dir/shot.png" >/dev/null \
	|| { echo "frame.sh: render failed: invalid Mermaid, a thumb that cannot fit, or a CDN/network timeout" >&2; exit 1; }
ffmpeg -loglevel error -y -i "$dir/shot.png" -c:v libwebp -quality 82 "$out"
