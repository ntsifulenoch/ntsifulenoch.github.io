# ntsifulenoch.github.io

Personal academic website of Enoch Ntsiful, PhD candidate in Economics at the University of Barcelona. Built with [AcademicPages](https://github.com/academicpages/academicpages.github.io) (Jekyll, MIT licence) and published with GitHub Pages.

## Where things live

| To change | Edit |
|---|---|
| Home page: bio, job market paper card, references, contact | `_pages/about.md` |
| What's new (dated news list) | `_pages/news.md` |
| Papers (JMP, working papers, publications, work in progress) | `_pages/research.md` |
| Policy brief, videos, interviews, competitions | `_pages/media.md` |
| Presentations and webinars | `_pages/conferences.md` |
| Teaching and guest talks | `_pages/teaching.md` |
| Mini-courses | `_pages/mini-courses.md` |
| CV page ("Click here for the latest CV") | `_pages/cv.md` |
| CV (LaTeX source, also on Overleaf) | `cv/resume_ntsiful.tex` |
| Sidebar (photo, links, job-market badge) and site settings | `_config.yml` |
| Top menu | `_data/navigation.yml` |
| Colours, fonts, buttons, cards | `_sass/_custom.scss` |
| Photo | `images/profile.jpg` |

Keep the website and the CV consistent: every paper, coauthor, year and talk should match.

## Editing: GitHub, this computer or Overleaf

You can edit in any of the three places.

- **On github.com (no software needed):** open a file, click the pencil icon, edit, then *Commit changes*. The site rebuilds itself in a few minutes. This also works for the CV: edit `cv/resume_ntsiful.tex` and the CV PDF on the site is recompiled automatically.
- **On Overleaf:** edit the CV as usual.
- **On this computer:** edit any file.

Then run the sync command on this computer. It brings all three places back in line:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync.ps1 -Message "What you changed"
```

It saves your local edits, pulls the edits made on GitHub and Overleaf, rebuilds the CV PDF, and pushes everything to GitHub and the CV to Overleaf. If the same lines were edited in two places, it stops and lists them so you can choose; nothing is overwritten.

How it is wired: this folder is the GitHub repository. `cv/` is a git subtree of the Overleaf CV project (remote `overleaf`, branch `main`), so the CV source lives here, on GitHub and on Overleaf.

## Updating the PDFs

- Job market paper: replace `files/Ntsiful_JMP.pdf` with the new version, keeping the same name so links never break.
- CV: never edit the PDF by hand. It is built from `cv/resume_ntsiful.tex`: by `scripts\cv.ps1` on this computer, and automatically on GitHub when the site is built.

## Visitor and download counts (private)

The site can count visits, and every click on a PDF link (the CV and the JMP), with [GoatCounter](https://www.goatcounter.com). It uses no cookies, and the numbers are visible only to you when logged in.

1. Sign up at <https://www.goatcounter.com/signup>. The "code" you choose gives your dashboard address, e.g. `ntsiful` → `https://ntsiful.goatcounter.com`.
2. In `_config.yml`, put that code after `goatcounter` under `analytics`, e.g. `goatcounter : "ntsiful"`, and commit.
3. In the dashboard, downloads appear as events named `download/Enoch_Ntsiful_CV.pdf` and `download/Ntsiful_JMP.pdf`. Visits to the CV page appear as `/cv/`.

To keep your own clicks out of the counts, open `https://ntsifulenoch.github.io/#toggle-goatcounter` once in each browser you use. Opening the PDF from a link elsewhere (an email, Google) is not counted; only clicks on the website are.

## Preview locally (Windows + WSL Ubuntu)

One-time setup, in an Ubuntu terminal:

```bash
sudo apt update && sudo apt install -y ruby-full ruby-bundler build-essential zlib1g-dev
```

Then, from this folder in Ubuntu:

```bash
bundle config set --local path "$HOME/.gems/github_site"
bundle install
bundle exec jekyll serve -l -H localhost --force_polling --destination "$HOME/github_site_build"
```

Open <http://localhost:4000>. Restart the server after editing `_config.yml`.

## Publishing

Every push to `master` runs `.github/workflows/jekyll.yml`. It compiles the CV, builds the site, and, once the repository is public, deploys it to <https://ntsifulenoch.github.io> (Settings → Pages → Source: GitHub Actions). While the repository is private, the run only checks that everything builds.
