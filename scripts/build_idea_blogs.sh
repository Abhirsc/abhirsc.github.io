#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IDEA_DIR="$ROOT_DIR/idea-pages"
OUT_DIR="$ROOT_DIR/_generated"
OUT_FILE="$OUT_DIR/idea-blogs.html"

mkdir -p "$IDEA_DIR" "$OUT_DIR"

escape_html() {
  sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

{
  # This file is embedded in the Idea-Blogs tab via iframe.
  printf '<div class="blog-list">\n'

  shopt -s nullglob
  files=("$IDEA_DIR"/page*.txt)

  if [ ${#files[@]} -eq 0 ]; then
    # Friendly empty-state for first-time setup.
    printf '  <article class="blog-entry"><h3>No idea pages yet</h3><p>Add <code>idea-pages/page1.txt</code> and render to publish it here.</p></article>\n'
  else
    for file in "${files[@]}"; do
      base="$(basename "$file")"
      title="$(awk 'NF { print; exit }' "$file" | sed 's/^#\s*//')"
      if [ -z "$title" ]; then
        title="$base"
      fi

      # Avoid head/sed broken-pipe failures under set -euo pipefail in CI.
      excerpt="$(
        awk 'NF { c++; if (c > 1) { print; d++; if (d == 3) exit } }' "$file" \
          | tr '\n' ' ' \
          | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//'
      )"
      if [ -z "$excerpt" ]; then
        excerpt="Open the file to add your content."
      fi

      safe_title="$(printf '%s' "$title" | escape_html)"
      safe_excerpt="$(printf '%s' "$excerpt" | escape_html)"

      printf '  <article class="blog-entry">\n'
      printf '    <h3>%s</h3>\n' "$safe_title"
      printf '    <p>%s</p>\n' "$safe_excerpt"
      printf '    <a href="idea-pages/%s" target="_blank" rel="noopener">Open %s</a>\n' "$base" "$base"
      printf '  </article>\n'
    done
  fi

  printf '</div>\n'
} > "$OUT_FILE"
