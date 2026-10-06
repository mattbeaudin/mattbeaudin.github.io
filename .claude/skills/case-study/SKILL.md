---
name: case-study
description: Turn a repository into a portfolio case-study page for matthewbeaud.in, with an interview-driven STAR writeup, framed WebP images and a front-matter tile. Use when Matt runs /case-study <local path | GitHub URL> or asks to write up a project.
---

# /case-study

Turns a repo plus an interview with Matt into a finished case-study page. **Never commit.** Matt reviews the diff and commits it himself.

Tools used (none of these get installed):
- `.claude/skills/case-study/frame.sh <browser|phone|terminal|diagram> <input> <out.webp> [thumb]` frames one image.
- `npx -y playwright@1.62.1 screenshot` takes raw web captures. It is pinned to the cached Chromium.

Work in a scratch directory: `$CLAUDE_JOB_DIR/tmp/case-study` if it is set, otherwise `mktemp -d`.

## 1. Get the repo
- **Local path:** use it as it is.
- **GitHub URL:** `gh repo clone <url> <scratch>/repo -- --depth 200`. If that fails because of auth, ask Matt to run `! gh auth login` or give a local path. Stop until he does.
- **Existing page:** check whether the repo already has a page: look for a `_projects/*.md` whose front matter or content matches it. If one exists, show Matt its current text and tile and ask whether to update it before the interview. If yes, reuse its slug and treat its text as the starting point for the interview. If no, stop.

## 2. Interview
Use **AskUserQuestion** only for these choices:
- Public or private?
- Project type: web, mobile, CLI/backend.

Then ask the following in **plain chat, one question per message**, and wait for each answer:
1. Situation: why did this project exist?
2. Task: what was your role, and what was the goal?
3. What were the hardest problems, and how did you solve them?
4. Result: what happened, and what would you do differently?
5. Which screens, flows or commands show it off best?

Use Matt's words. Don't invent motives, metrics or outcomes he didn't give.

## 3. Scan the repo
Read the following:
- the README;
- whichever exist of `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `*.csproj`, `Dockerfile`, `docker-compose*.yml`, k8s/helm manifests and CI configs (`.github/workflows`, `.gitlab-ci.yml`).

Then run:
- `git log --reverse --format='%ad %s' --date=short | sed -n '1p;$p'` for the time span;
- `git rev-list --count HEAD`;
- `git log --format=%s | head -50` to find notable commits;
- if `gh` works on the repo: `gh issue list --state all --limit 30` and `gh pr list --state all --limit 30`.

Show Matt the detected stack as a short list and let him correct it before you draft anything.

## 4. Draft
Read `_projects/*.md` for Matt's voice. It is first person, plain, specific, and honest about what went wrong. Draft:
- **Situation:** one paragraph.
- **Task:** a short `<ul>`.
- **Action:** one or two paragraphs. Include the hardest problem and how he solved it.
- **Result:** one paragraph.
- **Tile fields:**
  - one title, used for both the page h1 and the tile h3;
  - a one-line description of 15 words or fewer;
  - a stack line, comma separated.
- **Slug:** kebab-case from the title. Confirm it with Matt.
- **Images:** alt text and a figcaption for each.

**Private repos:** leave out the repo, org, client, host and internal service names, internal URLs and code. List every borderline item (for example a domain term, a metric, or a vendor) and get Matt's yes or no on each before using it.

Show the draft and revise until Matt approves it.

## 5. Visuals
Use 1–3 figures and 1 thumbnail. Name them `project/images/<slug>-1.webp`, `-2.webp`, and so on, and `project/images/<slug>-thumb.webp`. The thumbnail is the first visual rendered again with `thumb`.

- **Web:** get a URL from Matt, or start the app.
  - To start it, run the start command with Bash `run_in_background`, then poll `curl -sf -o /dev/null <url>` once per second for up to 60s.
  - For each screen from the interview, run `npx -y playwright@1.62.1 screenshot --viewport-size "1280, 800" <url> <scratch>/raw-N.png`.
  - Then run `frame.sh browser <scratch>/raw-N.png project/images/<slug>-N.webp`.
- **CLI/backend:**
  - **Terminal:** run each key command and save `$ <command>` plus its output, trimmed to 15 lines or fewer, to `<scratch>/term-N.txt`. Then run `frame.sh terminal`.
  - **Diagram:** write a Mermaid `graph LR` architecture diagram from the scan, with 8 nodes or fewer, to `<scratch>/arch.mmd`. Show Matt the source first, then run `frame.sh diagram`.
- **Mobile:** ask Matt for simulator PNG paths, then run `frame.sh phone` on each.
- **Private:** capture nothing without Matt's explicit OK. If he declines, produce the diagram only.

If a capture fails, tell Matt what failed and fall back to a diagram or images he supplies. Never finish with a page that has no images unless Matt has explicitly agreed to it.

Use the Read tool to open every `.webp` and check it before moving on.

## 6. Render (site-specific: matthewbeaud.in)
**If you are updating an existing page (step 1):** rewrite the existing `_projects/<slug>.md` and its images, keeping its `order`. Never create a second file for the same slug. Delete the old page's images once nothing references them, even when they don't follow the `<slug>-N` naming.

**Page:** write `_projects/<slug>.md`. Front matter:
```yaml
---
title: <Title>
description: <One-line description>
stack: <Stack line>
order: <tile position, 1 = first>
figures:
  - src: <slug>-1.webp
    alt: <alt text>
    caption: <caption>
---
```
Quote any value that contains `: `. Then the body in Markdown: `## Situation`, `## Task` (a `-` list), `## Action` and `## Result`. Write external links as `[text](url){:target="_blank" rel="noopener"}`.

The layout renders the `<head>`, nav, `.back` link, `<h1>`, figures and footer, and `index.html` builds the tile from the front matter. Don't edit `index.html`, and don't touch the sitemap: `jekyll-sitemap` generates it.

**Tile order:** a new page goes first. Give it `order: 1` and add one to the `order` of every other `_projects/*.md`.

## 7. Verify and hand off
1. Start the site: `just serve` in the background on :4000, if it isn't already running. Check that `_site/project/<slug>.html` exists and that `grep -c 'project/<slug>.html' _site/index.html` prints `1`.
2. Screenshot `http://localhost:4000/project/<slug>.html` and `http://localhost:4000/` at the `"1280, 800"` and `"375, 812"` viewports, using `npx -y playwright@1.62.1 screenshot --full-page`, into the scratch directory.
3. Open the screenshots with the Read tool and check that:
   - the figures sit right of the text on desktop and below it on mobile;
   - no image has a double border;
   - the tile is first and its thumbnail isn't cropped;
   - terminal text is readable at 375px.
4. Show Matt the screenshots and `git status --short` plus `git diff --stat`. **Don't commit.**
