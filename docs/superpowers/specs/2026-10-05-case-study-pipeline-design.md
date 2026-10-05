# Repo → case-study pipeline (`/case-study` skill), revised spec

## Context
Matt wants to turn GitHub repos into portfolio case studies for matthewbeaud.in. Each one gets a STAR writeup and framed, polished images, not raw captures.

The original spec is `docs/superpowers/specs/2026-10-05-case-study-pipeline-design.md`. Reviewing it against the site found problems, which Matt has now resolved:
- **Double frame:** framed images would sit inside the site's existing bordered boxes.
- **Bad thumbnail crops:** tiles force 16:10 `cover`/`top`, which cuts off phone and diagram images.
- **Unreadable terminal shots:** the figures column is about 400px wide, too narrow for terminal text.
- **showcase-kit risk:** it is pre-1.0 (v0.3.0), and two framers would have to match each other's style.
- **Wrong interview tool:** open-ended questions don't fit AskUserQuestion.
- **Undefined re-runs:** nothing says what happens when the page already exists.
- **Dry-run clash:** testing on this repo would overwrite `project/portfolio.html`.

### Decisions (all confirmed by Matt)
- Built for his own site first and shareable later. The site-specific steps live in one "Render" section of the skill.
- All repo types are in scope: web, mobile, backend/CLI and private. The story comes from an interview, and the output is a finished page.
- It is a Claude Code skill, and it lives in this repo.
- Keep the STAR structure.
- Skip devb.io.
- **Drop showcase-kit.** One `frame.html` template frames every image, so they all share one look.
- Images are WebP. The thumbnail is its own exact 16:10 render.
- New `<img>`s get a `.framed` class, which removes the site's border and background. Existing pages stay as they are.
- New tiles go first in `.projects`.
- If `project/<slug>.html` already exists, show it, ask, then update it in place. The tile is kept, never duplicated.
- The skill never commits. Matt reviews and commits.
- Private repos: anything sensitive is flagged for Matt to approve, and nothing is captured without his OK.

## Tooling (nothing new installed, `package.json` unchanged)
- **Capture and render:** `npx playwright@1.62.1 screenshot`. The version is pinned because its Chromium (revision 1234) is already in `~/.cache/ms-playwright`.
- **WebP:** `ffmpeg -i in.png -c:v libwebp -quality 82 out.webp`. The system ffmpeg has libwebp.
- **Diagrams:** Mermaid, loaded from jsDelivr inside `frame.html`.

## Files
1. **`.claude/skills/case-study/SKILL.md`** holds the workflow below.
2. **`.claude/skills/case-study/frame.html`** is one template.
   - Its `<body class="browser|phone|terminal|diagram">` sets the mode, and a `<!-- CONTENT -->` slot holds the image.
   - Each mode uses the same gradient, padding and shadow, using the site palette (`css/sass/_variables.scss`).
   - For each shot, the skill writes a filled copy to the temp directory and screenshots it:
     - **browser:** window chrome around a raw `<img>` capture.
     - **phone:** a CSS bezel around a PNG Matt supplies.
     - **terminal:** a window with a large monospace `<pre>` holding captured command output. Plain text keeps it readable at a 400px column.
     - **diagram:** a Mermaid `<pre class="mermaid">`.
3. **`css/sass/content.scss`:** add a `.framed` modifier with `border: 0; background: none; border-radius: 0` for `figure img` and `.projects img`. Then run `just build` to update `css/style.min.css`.

## Flow: `/case-study <local path | GitHub URL>`
1. **Get the repo.** Use a local path as it is. For a URL, `gh repo clone` it into `$TMPDIR`.
2. **Interview.**
   - AskUserQuestion only for the choices: public or private, and project type (web, mobile, CLI/backend).
   - Plain chat, one question at a time, for the free text: Situation, Task and role, the hardest problems and how they were solved, Result, and which screens to show.
3. **Scan the repo.**
   - README and manifests: `package.json`, `pyproject`, `Cargo.toml`, `go.mod`, Dockerfile, k8s and CI files.
   - `git log` for the time span and notable commits, plus `gh` issues and PRs when available.
   - Show Matt the detected stack so he can confirm it.
4. **Draft the writeup.**
   - STAR text in Matt's voice, using `project/*.html` as reference. Also the tile title, a one-line description and the stack line.
   - Alt text and figcaptions for every image.
   - For a private repo, leave out names, hosts and internal code, and list anything borderline for approval.
5. **Make the visuals.**
   - **Web:** capture the raw `screenshot` of the URL or start command at 1280×800, then frame it in browser mode.
   - **CLI/backend:** run the key commands, capture their stdout and frame it in terminal mode. Add a Mermaid architecture diagram drawn from the scan.
   - **Mobile:** frame Matt's PNGs in phone mode.
   - **Private:** no capture without his OK. If he declines, use the diagram only.
   - **Output sizes:** figures are about 1200px wide. The thumbnail is exactly 1600×1000 and is the first visual reframed at 16:10. Everything is converted to WebP in `project/images/<slug>-*.webp`.
6. **Render** (the site-specific section).
   - Write `project/<slug>.html` from the structure of `project/react-native-app.html`: head, nav, `.back`, `.split` with `.figures` first, the STAR h2s, and the footer. Figures use `class="framed"`.
   - Insert the tile as the first `<li>` in `index.html` `.projects`, with `class="framed"` on its thumbnail.
   - Add the page's URL to `sitemap.xml`.
   - If the page already exists, ask first, then replace the page and images. The tile text is updated in place.
7. **Verify and hand off.** Screenshot the page and the index at 1280px and 375px, check them, then show Matt the screenshots and a summary of the diff. Don't commit.

### Error handling
- **App won't start, or a capture fails:** say so, then fall back to the diagram or images Matt supplies. Never ship a page with no images without saying so.
- **No `gh` auth for a private repo:** ask Matt to run `! gh auth login` or give a local path.

## Steps after approval
1. Overwrite the spec in `docs/superpowers/specs/` with this revised version. Ask before committing it (short message, no Claude mention, no trailer).
2. Use the writing-plans skill to write the implementation plan.

## Verification (once built)
- Matt picks one web repo and one backend/CLI repo when testing starts. Don't use this repo.
- For each, check that:
  - the page matches the existing case-study layout at 1280, 768, 375 and 360px;
  - the tile is first and its thumbnail isn't cropped;
  - no image has a double border;
  - terminal text is readable at 375px;
  - every image shares one frame style.
- Re-run on the same repo, and check that the page updates in place and the tile isn't duplicated.
