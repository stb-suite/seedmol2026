# SIESTA + STB-Suite short course — SeedMol 2026

Hands-on examples for a two-class minicourse on SIESTA and STB-Suite. All
examples use the same two materials: **GaAs** (3D) and **h-BN** (2D
monolayer).

STB-Suite prepares SIESTA inputs, organizes multi-step workflows and
analyzes the outputs. **It does not run SIESTA.** Each README marks where
the SIESTA step happens.

## Examples

| Class | Example | STB tools / workflow | README |
|-------|---------|----------------------|--------|
| 1 | CIF → relaxed structure | `stb-translate`, `stb-inputfile`, `stb-symmetry`, `stb-structural` | [aula1/relaxation](aula1/relaxation/README.md) |
| 1 | Convergence tests | workflow 5.5 (`stb-convergence`, `stb-convergenceAnalysis`) | [aula1/convergence](aula1/convergence/README.md) |
| 1 | Cohesive energy + BSSE | workflow 5.3 (`stb-cohesive`, `stb-cohesiveAnalysis`) | [aula1/cohesive_energy](aula1/cohesive_energy/README.md) |
| 2 | Bands and DOS | `stb-kpath`, `stb-bands`, `stb-dos` | [aula2/bandas_dos](aula2/bandas_dos/README.md) |
| 2 | Fatbands and work function | `stb-fatbands`, `stb-workfunction` | [aula2/fatbands_workfunction](aula2/fatbands_workfunction/README.md) |
| 2 | Elastic constants | workflow 5.2 (`stb-elasticInputs`, `stb-elasticAnalysis`) | [aula2/elastic](aula2/elastic/README.md) |
| 2 | H adsorption on h-BN | workflow 5.8 (`stb-adsorb` … `stb-adsorbGibbs`) | [aula2/adsorption](aula2/adsorption/README.md) |

Slides are in `aula1/presentation/` and `aula2/presentation_aula_2/`.
The course proposal is `proposta_curso_stb_siesta.md`.

## Folder convention

- `run/` (or `input/`) — clean starting point for the live demo.
- `siesta_stage<N>_complete/` — after STB stage N **and** the SIESTA runs,
  before the next analysis.
- `complete/` — final state with all STB reports and plots.

In class: prepare inputs live in `run/`, then switch to the precomputed
folders instead of waiting for SIESTA.

## Setup

```bash
conda activate stb
stb-suite          # interactive menu; type a menu code such as 5.5.1
stb-<tool> --help  # direct command-line use
```
