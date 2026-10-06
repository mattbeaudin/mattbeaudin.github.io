# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Static personal portfolio site served by GitHub Pages at `matthewbeaud.in` (see `CNAME`). No framework, no bundler, no tests — plain HTML pages, one SCSS stylesheet, one small JS file. Whatever is committed is what gets deployed.

## Commands

Tooling is uv (Python), no Node: `pysassc` (libsass) compiles the CSS, `watchfiles` rebuilds it, and `http.server` serves it. `uv run` installs them on first use.

```sh
just build   # compile css/style.scss -> css/style.min.css (compressed)
just watch   # same, rebuilding on change
just serve   # http.server on http://localhost:8000 (no live reload; refresh)
just dev     # watch + serve together
```

## Structure that matters

- **Styles:** edit only `css/style.scss` and the partials in `css/sass/` (theme tokens in `_variables.scss`). Pages load the compiled `css/style.min.css`, which is committed — rebuild and commit it after any SCSS change.
- **Pages:** `index.html` plus case studies in `project/*.html`. Each page carries its own full copy of the `<head>`, nav (`.nav-title` + `.nav-link`), and footer — there are no includes, so shared changes must be made in every page. `project/` pages use `../` relative paths.
- **JS:** `js/main.js` only fills `[data-since]` elements with the years since that year.
- `blog/index.html` is just a redirect to `blog.matthewbeaud.in`.
- `sitemap.xml` is hand-maintained.
