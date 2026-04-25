# PokeMarkt — Project Instructions (CLAUDE.md)

> Project-specific rules for this repo. The user's global rules at `~/.claude/CLAUDE.md` still apply on top of these.

## 1. Project overview

PokeMarkt is the static GitHub Pages marketing site for the PokeMarkt browser extension (Chrome + Firefox), served at **pokemarkt.com** via the repo-root `CNAME`. The site's only job is to convert visitors into Chrome Web Store / Firefox Add-ons installs. Stack is vanilla HTML / CSS / JS — no framework, no bundler, no build step. Push to `main` and GitHub Pages rebuilds in ~1 minute.

Layout:
- `index.html` — production landing page (monolithic, ~77KB).
- `styles.css` + `app.js` — production stylesheet and vanilla ES6 script.
- `privacy/index.html` — minimal, system-font privacy policy at `/privacy`.
- `PokeMarkt-Landing/` — in-progress redesign (parallel work surface, **not yet promoted to root**).
- `assets/` — canonical production images (logo, browser icons, screenshots, demo.gif).
- `uploads/` — scratch/source dump folder. **Not** referenced by the live site.
- `CNAME` — pins `pokemarkt.com` for GitHub Pages.

## 2. Goals (current)

1. **[HIGH — PRIORITY / HEADLINE ASK]** Build & execute a multi-channel promotion plan to drive PokeMarkt extension installs. Reddit (r/pokemon, r/PokemonTCG, r/PokeInvesting), X/Twitter, TikTok, Instagram, Discord, ProductHunt, Chrome Web Store, Firefox Add-ons. Audience research, channel-specific content, posting cadence, conversion measurement.
2. **[HIGH]** Polish landing-page conversion: hero, CTAs, copy, glassmorphism, and extract a reusable design-system layer so CTA iterations stop rewriting `index.html` from scratch.
3. **[HIGH]** Promote/launch the extension and convert visitors to installs — per-browser CTA routing validated, click-through measurable, hero/screenshots accurate to the current extension UX.
4. **[MEDIUM]** Maintain `privacy/` and any other legal pages as the extension's data behavior evolves.
5. **[MEDIUM]** Reduce single-file (`index.html`) churn — extract reusable sections/components into `styles.css` so the average commit touches < 30% of `index.html` lines.

## 3. Workflow

- Trunk-based, push-to-deploy. Edit → commit to `main` → GitHub Pages rebuilds the static site (~1 min). Verify at `https://pokemarkt.com`.
- No CI/CD, no tests, no lint, no formatter, no build step.
- Solo developer (Ido).
- Commit messages: imperative single-liners with an area prefix and a colon (`CTA buttons: ...`, `Nav: ...`, `Hero ...`). No Conventional Commits taxonomy.

## 4. Design rules (project-specific)

These are in addition to the user's global design rules. Pulled from `.a5c/project-profile.json` → `conventions.additionalRules`.

- **Banned: solid-gradient + Zap/Sparkles icon CTA** (permanently banned). If you catch yourself producing it, stop.
- **Banned: simple purple → blue gradients.** Generic SaaS look is rejected.
- **Banned: "Add to ..." CTA copy.** Multiple commits explicitly killed this verb.
- **Wordmark-only CTAs preferred** over icon+label (locked in by commit `9919c00`).
- Preferred direction: complex, rich, detailed; black glassmorphism; custom display fonts; high-end assets. Never minimal, never shadcn-style, never generic.
- **CSS conventions: BEM-ish.** `block__element` class names (`.how__step`, `.cta__inner`, `.tooltip__tabs`), state class `.is-active`, scroll-in animation classes `.will-in` / `.in`. CSS custom properties scoped to `:root` in kebab-case (`--ink`, `--crimson`, `--display`).
- **File naming:** kebab-case for multi-word files and assets. Lowercase single-word for entry HTML. PascalCase preserved **only** for brand-icon files (`Main-Logo.png`, `Main-Icon-48.png`, `Main-Icon-128.png`) and the `PokeMarkt-Landing/` directory.
- **JS:** Vanilla ES6 inside a single `DOMContentLoaded` handler. Native APIs only — `IntersectionObserver`, `requestAnimationFrame`, `matchMedia`. No modules, no bundler, no npm dependencies on the shipped site. Google Fonts via CDN URL is the only external resource.
- **Respect `prefers-reduced-motion`** in any new animation (already followed in the redesign rail script).
- **Privacy page is intentionally minimal / system-font** — do not premium-style it.
- **`PokeMarkt-Landing/` is parallel work** — not yet linked from production `index.html`. Treat as a separate surface.
- **`uploads/` is scratch.** `assets/` is canonical for production.

## 5. Architecture pain points to remember

- **100% of commits (23/23) touch `index.html`.** It is a single-file bottleneck — page structure, inline styles, and CTA markup all live in one ~77KB file. Refactoring toward extracted sections / a tokens layer in `styles.css` is on the roadmap (goal #5).
- **CTA churn is the historical anti-pattern.** 5+ full CTA rebuilds in a single 4-hour session, each ~100 lines of churn on the same component. **Before rebuilding hero/CTA, document the chosen variant** (decision + reason) so we don't re-churn the same area. Iterative convergence over rewrite-from-scratch.
- **`styles.css` is barely touched** (1/23 commits) because most styling is inlined into `index.html`. Migrating inline styles into `styles.css` with documented tokens is part of the design-system goal.

## 6. Babysitter

- This project is configured for **autonomous mode** (`.a5c/project-profile.json` → `babysitterPreferences.autonomy = "autonomous"`). Run phases without per-step approval; only pause on hard failures, destructive operations, or final review breakpoints.
- **Recommended methodology: `hypothesis-driven-development`.** Multi-channel promotion + zero analytics baseline + the documented CTA-churn pattern demand explicit falsifiability. Frame every channel / creative / CTA experiment as a hypothesis with a primary metric and a kill criterion. This forces analytics-implementation as a prerequisite and prevents the rabbit-holes that drove the historical churn.
- **Recommended processes** (ready to drop into the babysit skill):
  - GSD core: `gsd/plan-phase`, `gsd/execute-phase`, `gsd/iterative-convergence`
  - Marketing / promotion: `specializations/domains/business/digital-marketing/social-media-strategy`, `social-content-calendar`, `landing-page-optimization`, `digital-analytics-implementation`, `keyword-seo-strategy`
  - Marketing strategy: `specializations/domains/business/marketing/customer-persona-development`, `integrated-campaign-planning`
  - Product / launch: `specializations/product-management/product-launch-gtm`, `conversion-funnel-analysis`
  - Design / experimentation: `specializations/ux-ui-design/design-system`, `ab-testing`
  - Engineering: `specializations/web-development/google-analytics-integration`
- **To run a process:** invoke the `babysitter:babysit` skill with the process path.
- **Profile lookup:** the live profile lives at `.a5c/project-profile.json`. Read it via `babysitter profile:read --project --json` (or open the file directly).

## 7. Promotion plan (HIGH priority deliverable)

Channels in scope:
- **Reddit** — r/pokemon, r/PokemonTCG, r/PokeInvesting, plus other niche subs once persona work lands.
- **X / Twitter** — TCG niches.
- **TikTok** — short-form video promotion.
- **Instagram** — visual promotion.
- **Discord** — TCG community engagement.
- **ProductHunt** — launch event.
- **Chrome Web Store / Firefox Add-ons** — already linked from CTAs; promotion plan should also optimize the listing copy + screenshots.

Prerequisites still TODO before the promotion plan can measure anything:
- Install **analytics** (Google Analytics 4 or Plausible) on `index.html` and `privacy/index.html` — script-tag install only, no npm.
- Add **UTM-tagged share/install CTAs** so per-channel install conversion is attributable.
- Build a **content calendar** (cadence per channel).
- Draft **channel-tailored launch copy** + creative cuts (demo.gif edits, screenshot variants, hooks per channel).

The user will provide credentials / API keys / posting integrations for any channel as needed.

## 8. Local development

- No install required. The site is fully static.
- Open `index.html` directly in a browser, or run a quick static server: `python -m http.server 8000` or `npx serve .`.
- For the redesign at `PokeMarkt-Landing/`: same approach — vanilla HTML, just open it.
- **Per the user's global rules, the assistant does NOT run dev servers, tests, or applications.** The user runs / tests, then reports results back.

## 9. Git

- **Per the user's global rules, the assistant never runs `git add` / `commit` / `push` / `stash` / `reset` / `rebase` / etc.** unless the user explicitly requests a specific operation.
- Read-only git commands are fine: `git status`, `git diff`, `git log`.
- If a commit is needed, list the changed files for the user and let them commit.

## 10. File pointers

- Profile JSON: `.a5c/project-profile.json`
- Profile MD: `.a5c/project-profile.md`
- Babysitter run artifacts: `.a5c/runs/`
- Babysitter SDK (installed locally): `.a5c/node_modules/@a5c-ai/babysitter-sdk`
- Production landing: `index.html` + `styles.css` + `app.js` + `assets/`
- Privacy: `privacy/index.html`
- Redesign-in-progress: `PokeMarkt-Landing/`
- Domain pin: `CNAME` (pokemarkt.com)
