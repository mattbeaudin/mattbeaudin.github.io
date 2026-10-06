# List recipes
default:
    @just --list

# Build the site into _site
build:
    bundle exec jekyll build

# Serve on http://localhost:4000 with live reload
serve:
    bundle exec jekyll serve --livereload
