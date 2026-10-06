# List recipes
default:
    @just --list

# Compile css/style.scss -> css/style.min.css
build:
    uv run pysassc -t compressed css/style.scss css/style.min.css

# Rebuild CSS on every SCSS change
watch:
    uv run watchfiles --ignore-paths css/style.min.css 'pysassc -t compressed css/style.scss css/style.min.css' css

# Serve the site on http://localhost:8000
serve:
    uv run python -m http.server 8000

# Watch CSS and serve together; Ctrl+C stops both
dev:
    #!/usr/bin/env bash
    trap 'kill 0' EXIT
    just watch &
    just serve
