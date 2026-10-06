---
name: case-study
description: Turn a repository into a portfolio case-study page for matthewbeaud.in, with an interview-driven STAR writeup, framed WebP images, an index tile and a sitemap entry. Use when Matt runs /case-study <local path | GitHub URL> or asks to write up a project.
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
- **Existing page:** check whether the repo already has a page: look for a `project/*.html` whose tile or content matches it. If one exists, show Matt its current text and tile and ask whether to update it before the interview. If yes, reuse its slug and treat its text as the starting point for the interview. If no, stop.

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
Read `project/lm-telem.html` and `project/portfolio.html` for Matt's voice. It is first person, plain, specific, and honest about what went wrong. Draft:
- **Situation:** one paragraph.
- **Task:** a short `<ul>`.
- **Action:** one or two paragraphs. Include the hardest problem and how he solved it.
- **Result:** one paragraph.
- **Tile fields:**
  - title, in Title Case for the page h1 and sentence case for the tile h3;
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
**If you are updating an existing page (step 1):** replace the page and its images, and edit the existing tile **in place** without moving it. Never add a second `<li>` for the same slug. Delete the old page's images once nothing references them, even when they don't follow the `<slug>-N` naming.

**Page:** copy `project/lm-telem.html`, then change only these parts:
- `<title>`: `<Title> - Matthew Beaudin`.
- `<meta name="description">`: the one-line description.
- `<h1>`: the title.
- Inside `<div class="split">`:
  - first, `<div class="figures">` with one block per image:
    ```html
    <figure>
    	<img class="framed" alt="<alt text>" src="./images/<slug>-N.webp">
    	<figcaption><caption></figcaption>
    </figure>
    ```
  - then the `<h2>Situation</h2>`, `<h2>Task</h2>`, `<h2>Action</h2>` and `<h2>Result</h2>` sections.

Leave the head links, nav, `.back` link, footer and `../` paths unchanged.

**Tile:** insert this as the first `<li>` inside `<ul class="projects">` in `index.html`:
```html
<li>
	<a href="./project/<slug>.html">
		<img class="framed" src="./project/images/<slug>-thumb.webp" alt="">
		<div>
			<h3><Tile title></h3>
			<p><One-line description></p>
			<p class="stack"><Stack line></p>
		</div>
	</a>
</li>
```

**Sitemap:** add this before `</urlset>` in `sitemap.xml`, unless the `<loc>` is already present:
```xml
<url>
  <loc>https://matthewbeaud.in/project/<slug>.html</loc>
  <lastmod><today>T00:00:00+00:00</lastmod>
  <priority>0.80</priority>
</url>
```

## 7. Verify and hand off
1. Check that `grep -c 'project/<slug>.html' index.html` prints `1`.
2. Start the site: `yarn live` in the background on :8000, if it isn't already running.
3. Screenshot `http://localhost:8000/project/<slug>.html` and `http://localhost:8000/` at the `"1280, 800"` and `"375, 812"` viewports, using `npx -y playwright@1.62.1 screenshot --full-page`, into the scratch directory.
4. Open the screenshots with the Read tool and check that:
   - the figures sit right of the text on desktop and below it on mobile;
   - no image has a double border;
   - the tile is first and its thumbnail isn't cropped;
   - terminal text is readable at 375px.
5. Show Matt the screenshots and `git status --short` plus `git diff --stat`. **Don't commit.**
