# SIESTA + STB-Suite short course — SeedMol 2026

Hands-on material for a two-class minicourse on DFT calculations with
[SIESTA](https://siesta-project.org) and **STB-Suite**. All examples use the
same two materials, so results can be compared across workflows:

- **GaAs** — 3D zinc-blende semiconductor
- **h-BN** — 2D monolayer

STB-Suite prepares SIESTA inputs, organizes multi-step workflows and
analyzes the outputs. **It does not run SIESTA.** Each example README marks
where the SIESTA step happens.

## Examples

### Class 1 — structure, convergence and energetics

| Example | What you learn | STB tools |
|---------|----------------|-----------|
| [Relaxation](aula1/relaxation/) | CIF → SIESTA input → relaxed structure, symmetry and bond analysis | `stb-translate`, `stb-inputfile`, `stb-symmetry`, `stb-structural` |
| [Convergence](aula1/convergence/) | MeshCutoff, EnergyShift and k-grid tests on energy *and* volume | `stb-convergence`, `stb-convergenceAnalysis` (5.5) |
| [Cohesive energy](aula1/cohesive_energy/) | Cohesive energy with counterpoise (BSSE) correction and cutoff scan | `stb-cohesive`, `stb-cohesiveAnalysis` (5.3) |

### Class 2 — electronic and mechanical properties, surfaces

| Example | What you learn | STB tools |
|---------|----------------|-----------|
| [Bands and DOS](aula2/bandas_dos/) | High-symmetry path, band gap, total and projected DOS | `stb-kpath`, `stb-bands`, `stb-dos` |
| [Fatbands and work function](aula2/fatbands_workfunction/) | Orbital character of the GaAs bands; work function of h-BN | `stb-fatbands`, `stb-workfunction` |
| [Elastic constants](aula2/elastic/) | C_ij of GaAs by the stress and energy methods, Born stability | `stb-elasticInputs`, `stb-elasticAnalysis` (5.2) |
| [Adsorption](aula2/adsorption/) | H on h-BN: site ranking, BSSE, Gibbs free energy vs. temperature | `stb-adsorb` → `stb-adsorbGibbs` (5.8) |

Numbers in parentheses are the workflow codes in the `stb-suite` menu.

## Key results

| Property | GaAs | h-BN |
|----------|------|------|
| Band gap (PBE) | 0.36 eV, direct at Γ | 4.59 eV, direct at K |
| Cohesive energy (BSSE-corrected) | −3.06 eV/atom (10 Å cutoff) | −7.01 eV/atom |
| Elastic constants C11 / C12 / C44 | 92.4 / 39.4 / 65.1 GPa | — |
| Work function | — | 3.83 eV |
| H adsorption (BSSE-corrected) | — | −0.44 eV, on top of B |

See each example's README for how these were obtained and how to read them.

## Folder convention

Each example keeps snapshots of the same calculation:

| Folder | Content |
|--------|---------|
| `run/` or `input/` | clean starting point for the live demo |
| `siesta_stage<N>_complete/` | after STB stage N **and** the SIESTA runs, before the next analysis |
| `complete/` | final state with all STB reports and plots |

In class, prepare the inputs live in `run/`, then switch to the
precomputed folders instead of waiting for SIESTA.

Slides: `aula1/presentation/` and `aula2/presentation_aula_2/`.

## Requirements

- SIESTA 5.x (results computed with 5.4.2)
- STB-Suite (conda environment `stb`)
- gnuplot (optional, for the `.gplot` files)

```bash
conda activate stb
stb-suite          # interactive menu; type a code such as 5.5.1
stb-<tool> --help  # direct command-line use
```

Large SIESTA binaries (`.DM`, and `.HSX` except in the fatbands example)
were removed to keep the repository small. They are only needed to restart
a calculation, not for the analyses.

## Author

Carlos M. O. Bastos — Universidade de Brasília (UnB)
