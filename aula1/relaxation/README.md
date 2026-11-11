# Class 1 — From CIF to a relaxed structure (GaAs and h-BN)

This example takes a crystal from a CIF file to a relaxed SIESTA geometry
using STB-Suite. It produces the starting structures used by every other
example in the course:

- **GaAs** — 3D zinc-blende semiconductor (space group F-43m).
- **h-BN** — 2D monolayer with 15 Å of vacuum along `c`.

STB prepares and analyzes the files. **SIESTA runs the calculation**; STB
never runs it for you.

## Folder layout

```
relaxation/
├── GaAs/
│   ├── cif/        GaAs.cif — starting point
│   ├── run/        empty, clean workspace for the live demo
│   └── complete/   inputs, SIESTA outputs and STB reports (reference)
└── hBN/
    ├── cif/        hBN.cif
    ├── run/
    └── complete/
```

## Workflow

| Step | Tool | Menu code | What it does |
|------|------|-----------|--------------|
| 1 | `stb-translate` | 3.1 | CIF → SIESTA `structure.fdf` |
| 2 | `stb-inputfile` | 1.1 | writes `calc.fdf` (relax template) and copies pseudopotentials |
| 3 | `siesta` | — | runs the CG relaxation (external step) |
| 4 | `stb-symmetry` | 2.5 | checks that symmetry survived the relaxation |
| 5 | `stb-structural` | 2.4 | bond lengths, coordination, RDF |
| 6 | `stb-translate` | 3.1 | `siesta.STRUCT_OUT` → `relaxed_structure.fdf` for the next examples |

Every command can also be run from the interactive menu: type `stb-suite`
and enter the menu code.

### 1. Convert the CIF

```bash
conda activate stb
cd GaAs/run
cp ../cif/GaAs.cif .
stb-translate -i GaAs.cif -o structure.fdf --save-report
```

`stb_translate_report.txt` lists the cell, species and nearest-neighbour
distances, and re-reads the written file to confirm the conversion is
faithful.

### 2. Generate the SIESTA input

```bash
stb-inputfile structure.fdf -t relax -p dojo --save-report
```

- `-t relax` selects the CG relaxation template.
- `-p dojo` copies the PseudoDojo pseudopotentials (`.psml`) into the folder.
- STB detects dimensionality. For GaAs (3D) it sets `MD.VariableCell true`.
  For h-BN it detects the vacuum axis and sets `MD.VariableCell false`, so
  the in-plane lattice parameter stays at the CIF value (2.504 Å) and only
  atomic positions relax.
- The k-grid is set from the cell: `12×12×12` for GaAs and `15×15×1` for h-BN.

Inspect `calc.fdf` before running.

### 3. Run SIESTA (external)

```bash
mpirun -np 2 siesta calc.fdf > calc.out
```

### 4–5. Check the relaxed structure

```bash
stb-symmetry   --file siesta.STRUCT_OUT --format struct_out --save-report
stb-structural --file siesta.STRUCT_OUT --format struct_out --mode mean --save-report
```

- `stb_symmetry_report.txt` should still give **F-43m (No. 216)** for GaAs.
  If a relaxation lost symmetry through numerical noise, try `--scan-symprec`.
- `stb_structural_report.txt` gives the Ga–As bond length (2.478 Å), the
  tetrahedral bond angles (109.47°), coordination numbers and the RDF in
  `rdf.dat`.

### 6. Export the relaxed geometry

```bash
stb-translate -i siesta.STRUCT_OUT -if siesta -o relaxed_structure.fdf -of fdf --save-report
```

`relaxed_structure.fdf` is the relaxed geometry you would carry into the
next workflows (convergence, cohesive energy, bands).

For h-BN, repeat the same steps in `hBN/run/` with `hBN.cif`.

## Expected results (`complete/`)

| | GaAs | h-BN |
|---|---|---|
| Cell after relaxation | primitive FCC vectors of 4.049 Å (conventional ≈ 5.73 Å) | a = 2.504 Å (fixed), c = 15 Å |
| Symmetry check | F-43m (No. 216) | — |
| Files to look at | `stb_symmetry_report.txt`, `stb_structural_report.txt`, `relaxed_structure.fdf` | `calc.out`, `structure.png`, `siesta.STRUCT_OUT` |

## Teaching notes

- Point out where STB stops and SIESTA starts (step 3).
- For class, prepare the inputs live in `run/` and use `complete/` for the
  analysis. The relaxations are fast, but waiting for them costs class time.
- Upstream reference: `~/Dropbox/dev/stb/examples/1.1-stb-inputfile`,
  `3.1-stb-translate`, `2.4-stb-structural`, `2.5-stb-symmetry`.
