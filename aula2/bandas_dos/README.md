# Section 2.2 — Live bands and DOS workflow

This exercise reuses the relaxed geometries from `../../aula1/relaxation/`:

- `GaAs/run/structure.fdf` is based on the relaxed GaAs `siesta.STRUCT_OUT`.
- `hBN/run/structure.fdf` is based on the relaxed h-BN `siesta.STRUCT_OUT`.

Layout: `<GaAs|hBN>/run/` holds only the starting structure;
`<GaAs|hBN>/complete/` holds the inputs, SIESTA outputs and STB reports.

The structures in this folder are already the relaxed starting points. Do not
relax them again for this exercise. GaAs is the 3D example; h-BN is the 2D
example with 15 Å of vacuum and one k point along the nonperiodic direction.

For the scheduled 25-minute block, prepare and inspect the inputs live, then
switch to the completed results for interpretation. Do not wait for SIESTA
calculations during class. The execution command below documents the boundary
between STB preparation and the external SIESTA step; use it for a live run
only when time and computing resources allow.

## Generate bands and PDOS

Activate the course environment, then work in either `GaAs/` or `hBN/`:

```bash
conda activate stb
cd GaAs
mkdir -p bands
cp structure.fdf bands/
cd bands

# Prepare a fixed-structure calculation with a high-symmetry path and PDOS.
stb-inputfile structure.fdf -t bands -p dojo --save-report
stb-kpath -f structure.fdf --save-report   # GaAs: add -p 0.01 (see below)

# Optional: STB prepares the input; SIESTA performs the calculation.
mpirun -np 2 siesta calc.fdf > siesta.out
```

For GaAs, check the Bravais lattice in the `stb-kpath` report. The relaxed
cell is cubic only to about 10^-3 Å, so the default tolerance reads it as
rhombohedral; `-p 0.01` recovers FCC and the standard
\Gamma-X-W-K-\Gamma-L-U-W-L-K-U-X path. h-BN needs no change.

For h-BN, return to `run/` and repeat with `cd hBN` instead of `cd GaAs`.
Inspect `calc.fdf` and `kpath_bs.fdf` before execution. The path samples
selected high-symmetry lines; it does not replace the converged SCF k-point
mesh used to calculate the electronic density.

## Analyze the results

Run these commands from the same `bands/` directory after SIESTA finishes:

```bash
stb-bands --label siesta --shift vbm --save-report
stb-dos --label siesta --shift vbm --save-report --save-gnuplot
```

`stb-bands` reports the VBM, CBM, direct and indirect gaps, and writes
`bands_gnuplot.dat` and `bands.gplot`. Because the matching `siesta.EIG` and
`siesta.KP` are present, it also compares the path-based gap with the SCF
k-mesh result. `stb-dos` reads `siesta.PDOS.xml`; its VBM reference comes
from the companion `siesta.bands` file, so the band-edge reference agrees
with the band analysis.

For class, inspect the precomputed outputs in `GaAs/complete/` and
`hBN/complete/` and run the analysis commands there. The `run/` folders
contain only the relaxed starting structures; keep generated calculation
outputs in a separate working directory.

## Results (`complete/stb_bands_report.txt`)

| | GaAs | h-BN |
|---|---|---|
| Gap (PBE) | 0.36 eV, direct at Γ | 4.59 eV, direct at K |
| Path vs. SCF mesh | agree within 0.1 meV | agree within 0.1 meV |
| Experiment | 1.42 eV | ≈ 6 eV |

Both gaps are underestimated, as expected for GGA-PBE. The fatbands and
work-function follow-ups are in `../fatbands_workfunction/`.
