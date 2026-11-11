# Class 2 — Elastic constants of GaAs (workflow 5.2)

This example computes the elastic stiffness tensor `C_ij` of zinc-blende
GaAs in two independent ways:

| Method | Observable | Fit | Folder |
|--------|-----------|-----|--------|
| `stress` | stress tensor σ(ε) of each strained cell | linear: σ = C ε | `GaAs/stress/` |
| `energy` | total energy E(ε) | quadratic: E = E₀ + V/2 εᵀCε | `GaAs/energy/` |

Both start from the relaxed GaAs cell (a = 5.7797 Å) and apply strains of
±1 % and ±2 % (5 points per direction, including 0 %). Comparing the two
methods is a check on the result.

For a cubic crystal only three constants are independent: C11, C12 and C44.
STB uses the symmetry to choose which strain directions to compute:

- `stress`, `--symmetry-method basic`: directions `xx` and `xy`.
- `energy`: strain patterns `xx`, `xx+yy` and `yz`.

## Folder layout

```
elastic/GaAs/<stress|energy>/
├── run/                       structure.fdf + calc.fdf (starting point)
├── siesta_stage1_complete/    after Stage 1 + SIESTA   (energy: siesta_complete_stage1/)
└── complete/                  after Stage 2
    ├── elastic_runs/
    │   ├── <direction>/strain_<direction>_<pct>/   one SIESTA run per strain
    │   ├── reference_structure.fdf                  unstrained cell
    │   └── elastic_stage1.txt
    ├── elastic_plots/         <direction>_fit.dat/.gplot
    └── elastic_stage2.txt     (stress)
```

## Workflow

### Stage 1 — strained structures (`stb-elasticInputs`, menu 5.2.1)

```bash
conda activate stb
cd GaAs/stress/run

# stress method
stb-elasticInputs -s structure.fdf -c calc.fdf -p dojo \
    --method stress --dirs all --symmetry-method basic \
    --max 2 --steps 5 --save-report

# energy method (in GaAs/energy/run)
stb-elasticInputs -s structure.fdf -c calc.fdf -p dojo \
    --method energy --dirs all --max 2 --steps 5 --save-report
```

- `calc.fdf` must be the same input used to relax the structure. The
  workflow strains an equilibrium cell; it does not find one.
- Each strain folder gets a `config_extra.fdf` that forces a single-point
  SCF (`MD.Steps 0`, `MD.VariableCell false`): neither the cell nor the
  atoms relax at the strained geometry. These are clamped-ion constants.

### Run SIESTA (external)

In every `elastic_runs/<direction>/strain_*/` folder:

```bash
mpirun -np 2 siesta calc.fdf > calc.out
```

### Stage 2 — analysis (`stb-elasticAnalysis`, menu 5.2.2)

```bash
# stress
stb-elasticAnalysis --dir elastic_runs --symmetry-method basic \
    --save-report --save-gnuplot --plot-dir elastic_plots

# energy
stb-elasticAnalysis --dir elastic_runs --method energy \
    --save-gnuplot --plot-dir elastic_plots
```

The dimensionality (3D here) and the reference cell are detected
automatically. Use the same `--symmetry-method` as in Stage 1.

## Results — stress method (`stress/complete/elastic_stage2.txt`)

| Quantity | Value |
|----------|-------|
| C11 = C22 = C33 | 92.4 GPa |
| C12 = C13 = C23 | 39.4 GPa |
| C44 = C55 = C66 | 65.1 GPa |
| Bulk modulus B | 57.1 GPa |
| Young's modulus E | 107.6 GPa |
| Poisson's ratio ν | 0.186 |
| Anisotropy A^U | 1.035 |
| Born stability | **STABLE** |

Experimental values for GaAs are C11 ≈ 119, C12 ≈ 53.8 and C44 ≈ 59.5 GPa
(B ≈ 75 GPa). The underestimate of C11, C12 and B is typical of GGA-PBE,
which also overestimates the lattice constant (5.78 Å vs. 5.65 Å
experimental). C44 comes out above experiment because the atoms were not
relaxed inside the sheared cell (clamped-ion); internal relaxation lowers it.

How to read the report:

1. `[3] NUMERICAL QUALITY DIAGNOSTICS` first. A warning there (eggbox effect,
   bad fit) points to a specific direction to check. Here all checks pass:
   R² > 0.998 and the stress vs. energy cross-check agrees within 1 %.
2. `[4]`: Born stability criteria (for cubic: C11 − C12 > 0, C11 + 2C12 > 0,
   C44 > 0) and the final verdict.
3. Open the fits: `cd elastic_plots && gnuplot xx_fit.gplot`. Points should
   fall on a line (stress) or a parabola (energy).

Run Stage 2 in `energy/complete/` during class and compare its C_ij with the
stress method.

## Teaching notes

- Stress is cheaper and gives the full tensor from fewer runs. Energy is an
  independent check, but needs well-converged energies because the
  curvature is a small number.
- For a quick preview without DFT, `stb-mlelastic` (menu 7.4) runs the same
  physics with a MACE potential.
- Upstream reference: `~/Dropbox/dev/stb/examples/5.2-elastic/README.md`.
