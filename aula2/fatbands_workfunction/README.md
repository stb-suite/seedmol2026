# Class 2 — Fatbands (GaAs) and work function (h-BN)

Two short analyses that continue from the bands/DOS example
(`../bandas_dos/`). Each one needs a SIESTA option that is **off** by
default, so the lesson is: decide what you want to analyze *before* running
SIESTA.

| Folder | Tool | Menu | Extra SIESTA option |
|--------|------|------|---------------------|
| `fatband_GaAs/` | `stb-fatbands` | 2.10 | `WFS.Write.For.Bands T` and `SaveHS T` |
| `workfunction_hBN/` | `stb-workfunction` | 2.7 | `SaveTotalPotential T` (writes `siesta.VT`) |

Both folders are complete (inputs, SIESTA outputs and STB reports).

---

## Fatbands — orbital character of the GaAs bands

Fatbands are band structures where each point is weighted by how much a
chosen orbital (for example As-p or Ga-s) contributes to that state
(Mulliken-like projection of the wavefunctions).

### Inputs

```bash
conda activate stb
cd fatband_GaAs
stb-inputfile structure.fdf -t bands -p dojo --save-report
stb-kpath -f structure.fdf -p 0.01 --save-report   # -p 0.01: recover the FCC path
```

`fatbands.fdf` adds the two required options on top of `calc.fdf`:

```
%include calc.fdf

SaveHS T
WFS.Write.For.Bands T
```

### Run SIESTA (external)

```bash
mpirun -np 2 siesta fatbands.fdf > siesta.out
```

This writes `siesta.bands`, `siesta.bands.WFSX` (wavefunctions along the
path) and `siesta.HSX` (overlap matrix).

### Analysis

```bash
stb-fatbands --label siesta --shift vbm --projection species_l \
    --save-report --save-gnuplot
gnuplot fatbands.gplot
```

- `--projection species_l` (default) splits by element and angular momentum:
  As-s, As-p, As-d, Ga-s, Ga-p, Ga-d. Other modes: `l`, `ml`, `atom`,
  `species`.
- `--category As-p Ga-s` keeps only the categories you list.
- Output: `fatbands_<category>.dat`, `fatbands.gplot`,
  `stb_fatbands_report.txt`.

### Result

- Direct gap at Γ: 0.36 eV (PBE; experiment 1.42 eV, the usual GGA
  underestimate).
- At Γ, the top of the valence band is about 83 % **As-p** (plus ~9 %
  Ga-p), and the bottom of the conduction band is about 63 % **Ga-s** and
  37 % As-s. This is the textbook picture of a III–V semiconductor.
  Check it in `fatbands_As-p.dat` and `fatbands_Ga-s.dat` at k = 0.

---

## Work function — h-BN monolayer

The work function is the energy to move an electron from the Fermi level to
the vacuum:

$$\Phi = V_{vac} - E_F$$

STB takes the planar average of the electrostatic potential along the
vacuum axis, finds the flat region in the vacuum, and reads E_F from the
SIESTA output.

### Inputs

```bash
cd workfunction_hBN
stb-inputfile structure.fdf -t total_energy -p dojo --save-report
```

`workfunction.fdf`:

```
%include calc.fdf

SaveTotalPotential T
```

### Run SIESTA (external)

```bash
mpirun -np 2 siesta workfunction.fdf > calc.out
```

### Analysis

```bash
stb-workfunction --label siesta --file calc.out --save-report --save-gnuplot
```

STB detects the vacuum axis (z) from `siesta.XV`, so `-z` is not needed.

### Result (`stb_workfunction_report.txt`)

| Quantity | Value |
|----------|-------|
| E_F | −3.95 eV |
| Vacuum level | −0.12 eV |
| **Work function** | **3.83 eV** |

`siesta_WF.pdf` shows the planar-averaged potential.

Points to discuss:

- The potential must be flat in the vacuum region (the report flags it if
  it is noisy). A slope means a dipole is missing; for an asymmetric slab
  add `Slab.DipoleCorrection T`.
- h-BN is an insulator, so E_F sits somewhere in the gap and Φ depends on
  where SIESTA places it. Report the ionization energy (V_vac − E_VBM) as
  well when comparing with experiment.
- The work function is only meaningful for slabs and 2D materials, not for
  3D bulk crystals, which have no vacuum.

---

Upstream reference: `~/Dropbox/dev/stb/examples/2.10-stb-fatbands/` and
`2.7-stb-workfunction/`.
