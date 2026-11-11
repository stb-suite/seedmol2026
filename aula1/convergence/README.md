# Class 1 — Convergence tests (workflow 5.5)

This example tests how three SIESTA parameters affect the total energy and
the relaxed structure of GaAs (3D) and h-BN (2D):

| Parameter | What it controls | Swept range | Converged when |
|-----------|------------------|-------------|----------------|
| `MeshCutoff` | real-space grid for the density | 100 → 400 Ry, step 50 | larger value stops changing E |
| `PAO.EnergyShift` | radius of the atomic orbitals | 0.001 → 0.05 Ry, step 0.01 | smaller value stops changing E |
| k-grid density | Brillouin-zone sampling | 0.05 → 0.30 Å⁻¹, step 0.05 | smaller value stops changing E |

Every point in the sweep is a **full relaxation** (atoms + cell where
allowed), not a single-point energy. This way STB checks convergence of the
energy *and* of the relaxed volume.

## Folder layout

```
convergence/<GaAs|hBN>/
├── input/                    structure.fdf + calc.fdf you start from
├── siesta_stage1_complete/   after Stage 1 + SIESTA (no analysis yet)
│   └── convergence_runs/
│       ├── meshcutoff/convergence_meshcutoff_*/
│       ├── energyshift/convergence_energyshift_*/
│       ├── kgrid/convergence_kgrid_*/
│       ├── convergence_stage1.txt
│       └── run.sh            runs SIESTA in every folder with a calc.fdf
└── complete/                 after Stage 2 (reports and plots)
```

For h-BN, `input/relaxed_structure.fdf` is the relaxed monolayer; copy it as
`structure.fdf` before Stage 1.

## Workflow

### Stage 1 — generate the calculations (`stb-convergence`, menu 5.5.1)

```bash
conda activate stb
mkdir work && cp input/structure.fdf input/calc.fdf work/ && cd work
stb-convergence -s structure.fdf -c calc.fdf -p dojo --parameter all --save-report
```

- `-c calc.fdf` is **your production input**. STB tests *your* settings and
  only overrides the swept parameter in each folder.
- `--parameter all` creates three independent sweeps. You can also pass
  `meshcutoff`, `energyshift` or `kgrid`, and change ranges with
  `--meshcutoff-range MIN MAX STEP` (same for the others).
- Each folder gets a `config_extra.fdf` that forces the swept value plus a
  full CG relaxation (`MD.VariableCell true`, 200 steps), whatever your
  `calc.fdf` says. See `[3]` in `convergence_stage1.txt`.
- For h-BN the vacuum axis is detected and keeps one k point along `c`
  (for example `[29 29 1]` at 0.10 Å⁻¹).

### Run SIESTA (external)

```bash
cd convergence_runs
bash run.sh          # helper script: mpirun -np 2 siesta calc.fdf --out calc.out in each folder
```

`siesta_stage1_complete/` shows the result of this step.

### Stage 2 — analysis (`stb-convergenceAnalysis`, menu 5.5.2)

```bash
cd ..   # the folder that contains convergence_runs/
stb-convergenceAnalysis --dir convergence_runs --save-report --save-gnuplot
# optional: write the recommended values into your calc.fdf
stb-convergenceAnalysis --dir convergence_runs --apply calc.fdf
```

Default tolerances: 0.01 eV/atom for the energy and 0.5 % for the volume.
Outputs in `complete/`:

- `convergence_report.txt` — tables per parameter and the summary `[4]`.
- `<parameter>_convergence.dat` / `.gplot` — energy and volume vs. parameter
  (`gnuplot kgrid_convergence.gplot`).

## Results (`complete/convergence_report.txt`, section `[4]`)

| Parameter | GaAs | h-BN |
|-----------|------|------|
| MeshCutoff | 400 Ry | 150 Ry |
| EnergyShift | not converged | not converged |
| k-grid | 0.25 Å⁻¹ | 0.25 Å⁻¹ |

How to read it:

1. Check the **Quality** column of each `[2.N]` table first (`SCF?`,
   `F>tol`, `steps`). A flagged row means the number may not be reliable.
2. In `[4]`, compare *Energy-converged* and *Structure-converged*. When they
   disagree, use *Recommended*.
3. **EnergyShift not converged** is a teaching point: the energy keeps
   dropping as the orbitals get longer, so the plateau never appears within
   the tolerance. In practice, choose a value such as 0.01 Ry and check the
   property you care about, or extend the range.
4. The same tolerance gives different answers for different materials: GaAs
   needs 400 Ry and h-BN only 150 Ry. Convergence must be tested for each
   system.

## Teaching notes

- Each sweep point is a relaxation, so Stage 1 + SIESTA takes too long for
  class. Run Stage 1 live, then switch to `siesta_stage1_complete/` and run
  Stage 2 there.
- Sweeps are independent (one parameter at a time, the others fixed at the
  `calc.fdf` values). They do not test interactions between parameters.
- Upstream reference: `~/Dropbox/dev/stb/examples/5.5-convergence/README.md`.
