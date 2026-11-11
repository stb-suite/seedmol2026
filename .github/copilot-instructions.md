# Copilot Instructions

## Repository purpose

This repository contains the English-language proposal for a four-hour minicourse on SIESTA and STB-Suite. The curriculum is maintained in `proposta_curso_stb_siesta.md`; it is not the STB-Suite source repository. The course software lives at `~/Dropbox/dev/stb`, whose Python package is `stb-suite/src/stb/`.

## Repository architecture

- `proposta_curso_stb_siesta.md` is the curriculum-level source of truth: the two class schedules, delivery model, learning objectives, and course-wide claims must remain consistent.
- `exemplos/aula1/` contains the materialized Class 1 demonstrations. Sections `1.3_preparar_input`, `1.5_convergencia`, and `1.6_energia_coesiva` mirror the corresponding schedule blocks and use the same GaAs (3D) and h-BN (2D) contrast.
- `exemplos/aula2/2.2_bandas_dos/` implements Class 2's bands/DOS comparison for those materials, starting from the relaxed structures generated in the Class 1 input-preparation walkthrough.
- `exemplos/aula2/2.3_interpretar_resultados/` continues from Section 2.2 with DOS broadening, an h-BN work-function example, and optional fatbands; the work-function input must save `siesta.VT`, and fatbands requires `WFS.Write.For.Bands T` plus `SaveHS T`.
- Each example separates a live setup from evidence: `run/` is the clean, stage-by-stage demonstration workspace; `completed/` preserves generated inputs, SIESTA outputs, analyses, and reference conclusions; `test/`, where present, is a manual command walkthrough rather than an automated test suite.
- The practical dependency chain is structure/input preparation → STB-generated calculation directories → external SIESTA/SLURM execution → STB analysis. Keep the corresponding README commands, generated-file layout, and proposal language aligned when changing a workflow.

## Validation

There are no build, test, lint, or single-test commands in this repository. Preserve valid Markdown structure when editing, especially tables, inline math, and command formatting.

When a course edit requires checking STB behavior, use the upstream source rather than inferring it from a command name:

```bash
cd ~/Dropbox/dev/stb/stb-suite
pip install -e .
stb-<command> --help
```

ML demonstrations require the upstream `ml` extra (`pip install -e ".[ml]"`). The canonical runnable tutorial and documented stages for each tool are in `~/Dropbox/dev/stb/examples/<menu-code>-<tool>/README.md`.

## Curriculum structure

- The course is organized as two two-hour classes: foundations, installation, input preparation, convergence, and elastic constants in class 1; electronic properties, adsorption, MLFF/MACE, and phonons in class 2.
- Each lesson table aligns block number, duration, topic, conceptual/practical content, and the relevant STB command or workflow. Keep those columns aligned when adding or moving material.
- The final methodology section assumes live input preparation followed by inspection of precomputed results from the upstream repository's `examples/` directory. Do not describe examples as local files in this repository.
- For local lesson artifacts, preserve the `run/` versus `completed/` distinction: do not populate clean live-workspace stages with reference outputs, and update the matching completed result and README when a demonstrated command or expected conclusion changes.
- STB is organized as independent CLI tools and an interactive `stb-suite` menu. The menu’s relevant areas are Inputs (1), Analysis (2), Utils (3), Structures (4), Workflows (5), and ML Simulations (7); workflows are ordered chains that create SIESTA folders, require SIESTA runs, then analyze their outputs.
- Keep the practical sequence explicit: STB generates or analyzes files, but does not execute SIESTA itself. A live demonstration must mark where SIESTA/SLURM execution occurs and where precomputed outputs take over.
- The program intentionally covers more full workflows than can be calculated live in four hours. Preserve the “prepare live, inspect precomputed results” model unless the schedule or computing environment is changed.

## Content conventions

- Write instructional prose in English and retain the established Markdown style: bold emphasis, backticked executable names, and LaTex-style inline or display math.
- Use the exact `stb-*` command names and numbered workflow references established upstream. The core multi-stage workflows in this proposal are elastic constants (`5.2.1`/`5.2.2`), cohesive energy (`5.3.1`/`5.3.2`), convergence (`5.5.1`/`5.5.2`), adsorption (`5.8.1`–`5.8.4`), Hirshfeld-I (`5.17.1`–`5.17.3`), custom MLFF (`7.1.1`–`7.1.4`), and ML phonons (`7.3`). When changing one, update every affected lesson table and surrounding prose.
- Keep SIESTA and STB-Suite concepts distinct: SIESTA provides the DFT calculations and `.fdf` inputs; STB-Suite prepares inputs, orchestrates workflows, and post-processes results.
- Preserve the course’s practical framing: distinguish the interactive `stb-suite` TUI from direct `stb-*` commands used for automation, scripts, pipelines, and SLURM submissions.
- Describe MLFF as a four-stage data workflow: generate labeled configurations, train a MACE committee, validate against held-out SIESTA data and physical checks, then optionally perform active learning. Treat `stb-mlphonons` as a consumer of a foundation or validated custom model, not as evidence that the model is accurate by itself.
