# Class 1 — Cohesive energy with BSSE correction (workflow 5.3)

This example computes the cohesive energy of GaAs (3D) and h-BN (2D):

$$E_{coh} = \frac{E_{bulk} - \sum_i n_i E_{atom,i}}{N}$$

With localized (LCAO) basis sets, an isolated atom has fewer basis functions
around it than an atom inside the solid. This basis set superposition error
(BSSE) makes the solid look too strongly bound. STB corrects it with the
counterpoise method: each isolated atom is computed again with **ghost
atoms** (basis functions without nuclei or electrons) at the positions of
its neighbours inside a cutoff radius.

## Folder layout

```
cohesive_energy/<GaAs|hBN>/
├── input/                       structure.fdf (relaxed) + calc.fdf
├── run/ or siesta_*stage*_complete/   after Stage 1 + SIESTA
└── complete/                    after Stage 2 (GaAs)
    └── cohesive_runs/
        ├── structure/                 full crystal
        ├── atoms/<El>/                isolated atom, no ghosts
        ├── atoms_bsse/<El>/           atom + ghosts within 4 Å (base cutoff)
        ├── atoms_bsse_check_<R>/<El>/ ghosts within R = 6, 8, 10 Å (cutoff scan)
        ├── cohesive_stage1.txt
        ├── cohesive_results.dat       Stage 2 report
        ├── cohesive_correction.png
        └── run.sh                     runs SIESTA in every folder
```

Folder names differ slightly between materials: for GaAs the
post-SIESTA snapshot is `siesta_estage_1_complete/` and the analyzed one is
`complete/`; for h-BN, `siesta_stage1_complete/` is the post-SIESTA snapshot
and `run/` already holds the analyzed result.

## Workflow

### Stage 1 — generate the calculations (`stb-cohesive`, menu 5.3.1)

```bash
conda activate stb
mkdir work && cp input/structure.fdf work/ && cd work
# (h-BN: cp input/relaxed_structure.fdf work/structure.fdf)

# GaAs
stb-cohesive -s structure.fdf -p dojo -k 0.2 \
    --bsse-cutoff 4.0 --bsse-convergence-check \
    --bsse-convergence-increment 6 8 10 --save-report

# h-BN: same command plus --dispersion (DFT-D3 on)
```

- Unlike convergence and elastic constants, **no `calc.fdf` is needed**:
  `stb-cohesive` builds its own inputs.
- The isolated atoms sit in a 20 Å vacuum box. The box grows with the
  cutoff so ghost atoms never touch their periodic images.
- `--bsse-convergence-increment 6 8 10` repeats the BSSE reference with
  larger cutoffs, so you can see if the correction is converged.

### Run SIESTA (external)

```bash
cd cohesive_runs
bash run.sh
```

### Stage 2 — analysis (`stb-cohesiveAnalysis`, menu 5.3.2)

```bash
cd ..   # the folder that contains cohesive_runs/
stb-cohesiveAnalysis -o calc.out --save-report --view
```

`-o calc.out` is the name of the SIESTA output in each folder. The report is
saved to `cohesive_runs/cohesive_results.dat` and the plot to
`cohesive_correction.png`.

## Results

| | GaAs | h-BN |
|---|---|---|
| Uncorrected | −4.69 eV/atom | −8.00 eV/atom |
| BSSE-corrected (4 Å) | −3.65 eV/atom | −7.03 eV/atom |
| BSSE correction | +1.04 eV/atom | +0.97 eV/atom |
| Cutoff scan 6 / 8 / 10 Å | −3.17 / −3.08 / −3.06 | −7.01 / −7.01 / −7.01 |
| Last step (8 → 10 Å) | +0.023 eV/atom | +0.0005 eV/atom |

How to read it:

1. Section `[2]`: SCF converged and residual force below 0.05 eV/Å. Check
   this before trusting the numbers.
2. Section `[3]`: the BSSE correction is always **positive** (less binding).
   Without it, LCAO over-binds by about 1 eV/atom here.
3. Section `[3b]`: for h-BN the correction is already converged at 4 Å.
   For GaAs it still changes by 0.6 eV/atom between 4 and 10 Å. The
   larger-cutoff value (≈ −3.06 eV/atom) is the one to report, and the
   4 Å default is **not** enough for this material.

## Teaching notes

- The GaAs vs. h-BN contrast in `[3b]` is the main lesson: never trust a
  single BSSE cutoff.
- Stage 1 runs in seconds, so it can be done live. SIESTA on the isolated
  atoms (large boxes, spin) is slow, so use the precomputed folders for
  Stage 2.
- Upstream reference: `~/Dropbox/dev/stb/examples/5.3-cohesive/README.md`.
