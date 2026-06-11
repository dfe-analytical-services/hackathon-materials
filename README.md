# Hackathon Materials

Materials and build scripts for the DfE Analytical Services pre-Stats Awayday hackathon.

## What This Repository Contains

This repo stores source content and generated outputs for:

- project briefs
- pre-hack tasks
- participant packs
- volunteer and event documentation
- slides and supporting images

Most documents are authored in Quarto (`.qmd`) and rendered to HTML.
For key deliverables (for example participant packs, pre-hack tasks, and project briefs), generation is orchestrated by R scripts.

## Repository Structure

- `common_docs/`: volunteer lists, agenda, and event details
- `data/`: source CSV inputs (including hackathon proposal form exports)
- `images/`: shared images used across materials
- `misc/`: code of conduct, project teams, and ice-breaker content
- `participant_packs/`: participant pack source, generator script, and generated outputs
- `pre-hack-tasks/`: pre-hack task source, generator script, and generated outputs
- `project_briefs/`: project brief source, generator script, and generated outputs
- `slides/`: slide decks and styling assets
- `renv/`: project package management files

## Updating Content Workflow

1. Export the project scoping form to CSV.
2. In the CSV, ensure the first column is named `Qualifiers`.
3. Save the CSV to `data/`.
4. Update any scripts or references that point to the old CSV filename (for example in `project_briefs/generate_project_b.R`).
5. Update relevant content in:
   - `common_docs/` (data/tech volunteer lists, agenda, event details, presentation timings)
   - `slides/`
   - `images/`
   - `misc/` (project teams, code of conduct, ice breaker)
6. Re-generate affected outputs using the relevant R scripts:
   - `participant_packs/generate_participant_guide.R`
   - `pre-hack-tasks/generate_pre_hack_tasks.R`
   - `project_briefs/generate_project_b.R`
7. Use direct `quarto render` only for files that are not covered by a generator script.

## Primary Build Method (R Scripts)

For the main pack/brief outputs, run the generator scripts rather than rendering individual `.qmd` files manually.

```r
source("participant_packs/generate_participant_guide.R")
source("pre-hack-tasks/generate_pre_hack_tasks.R")
source("project_briefs/generate_project_b.R")
```

## Rendering Documents

For documents not handled by a generator script, render directly with Quarto.

Render a single document:

```bash
quarto render path/to/file.qmd
```

Render all documents in a folder:

```bash
quarto render folder-name
```

## R Environment

This project uses `renv` for reproducible package management.

Typical setup in R:

```r
renv::restore()
```

## Contribution Notes

- Keep source `.qmd` files and generated `.html` outputs in sync.
- Use clear, descriptive filenames.
- Update this README when workflow steps or folder purposes change.