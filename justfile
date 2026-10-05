# List recipes
default:
    @just --list

# Watch CSS and serve together; Ctrl+C stops both
dev:
    #!/usr/bin/env bash
    trap 'kill 0' EXIT
    yarn watch &
    yarn live
