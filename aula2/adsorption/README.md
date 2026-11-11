# Class 2 — H adsorption on h-BN (workflow 5.8)

This example finds the most stable adsorption site of a hydrogen atom on an
h-BN monolayer and follows it to a temperature-dependent Gibbs free energy.
It uses all four stages of the STB adsorption workflow:

| Stage | Tool | Menu | What it does |
|-------|------|------|--------------|
| 0 | `stb-supercell`, `stb-inputfile` | 4.2, 1.1 | 4×4×1 slab and its `calc.fdf` |
| 1 | `stb-adsorb` | 5.8.1 | finds sites, writes slab, adsorbate and site folders |
| 2 | `stb-adsorbBsse` | 5.8.2 | ghost-atom (counterpoise) folders at each relaxed site |
| 3 | `stb-adsorbAnalysis` | 5.8.3 | adsorption energies, site ranking, Gibbs folders |
| 4 | `stb-adsorbGibbs` | 5.8.4 | ΔG(T), desorption temperature and rough kinetics |

SIESTA runs between every stage. STB only prepares and analyzes.

$$E_{ads} = E_{slab+H} - E_{slab} - E_{H}$$

Negative means favourable.

## Folder layout

The folders are snapshots of the same calculation at each point:

```
adsorption/
├── run/                     structure.fdf (4×4 h-BN) + calc.fdf — start here
├── siesta_stage1_complete/  Stage 1 + SIESTA on clean slab, H and sites
├── siesta_stage2_complete/  + Stage 2 + SIESTA on the BSSE folders
├── siesta_stage3_complete/  + Stage 3 analysis
└── complete/                + Stage 4 (Gibbs) — final result
    ├── adsorption_report.txt, adsorption_bsse_report.txt
    ├── adsorption_ranking.png, adsorption_curve.dat/.gplot
    ├── best_adsorbed_structure.fdf
    ├── deformation_check/   extra check, not STB output (see its README)
    └── adsorption_run/
        ├── clean_slab/  adsorbate/  sites/site_*/  bsse/site_*/  gibbs/
        ├── adsorption_gibbs_report.txt
        └── adsorption_gibbs.png, adsorption_desorption_kinetics.png
```

## Workflow

### Stage 0 — build the slab

```bash
conda activate stb
stb-supercell -f primitive_hBN.fdf -d 4 4 1 -o structure.fdf --save-report
stb-inputfile structure.fdf -t relax -p dojo --save-report
```

A 4×4 cell keeps the H atom about 10 Å away from its periodic images. The
relax template keeps the cell fixed because of the vacuum axis.

### Stage 1 — sites and reference folders (`stb-adsorb`)

```bash
stb-adsorb -s structure.fdf -c calc.fdf -p dojo \
    --adsorbate H --site-type all --all-sites --height 1.5
```

STB finds 6 candidate sites (site_1: on top of B; site_2: on top of N;
sites 3–6: bridge) and writes:

- `clean_slab/` — the bare slab;
- `adsorbate/` — isolated H in a 20 Å box (Γ only);
- `sites/site_*/` — H placed 1.5 Å above each site.

It also forces spin polarization (H has one unpaired electron), the slab
dipole correction and DFT-D3 in these folders. Read `adsorption_prep_report.txt`
section `[1]` for the self-interaction checks.

Run SIESTA in `clean_slab/`, `adsorbate/` and every `sites/site_*/`.

### Stage 2 — BSSE folders (`stb-adsorbBsse`)

```bash
stb-adsorbBsse --dir adsorption_run --save-report
```

For each **relaxed** site (it reads `siesta.XV`), STB writes
`bsse/site_*/bsse_slab/` (slab + ghost H) and `bsse/site_*/bsse_adsorbate/`
(H + ghost slab). Run SIESTA in all of them.

### Stage 3 — energies and ranking (`stb-adsorbAnalysis`)

```bash
stb-adsorbAnalysis --dir adsorption_run --save-report --apply structure.fdf \
    --compute-gibbs --zpe-mode local
```

Writes the ranking, saves the best site as `best_adsorbed_structure.fdf`,
and with `--compute-gibbs` creates finite-displacement folders in
`gibbs/` for the vibrational frequencies. Run SIESTA in every
`gibbs/*/disp_*/` folder.

### Stage 4 — Gibbs free energy (`stb-adsorbGibbs`)

```bash
stb-adsorbGibbs --dir adsorption_run --save-report --tmin 200 --tmax 800 --tstep 50
```

## Results

**Site ranking (`adsorption_report.txt`):**

| | Best site | E_ads |
|---|---|---|
| Uncorrected | site_3_bridge | −0.107 eV |
| BSSE-corrected | site_1_ontop (H on B) | −0.437 eV |

The BSSE correction changes which site wins. Trust the corrected ranking.
Note that the correction here makes E_ads *more* negative, which differs from
the usual case. `complete/deformation_check/README.md` shows why: STB's
correction does not include the slab deformation energy. Once that is
added, site_1_ontop is close to −0.01 eV and site_3_bridge is about −0.05 eV.
H binds very weakly to pristine h-BN either way.

**Thermodynamics (`adsorption_run/adsorption_gibbs_report.txt`):**

- D₀ (E_ads + ΔZPE) = −0.28 eV.
- ΔG = −0.06 eV at 200 K and turns positive at **≈248 K**. Above that,
  the loss of H translational entropy makes desorption favourable.
- Rough Eyring estimate: residence time of picoseconds at 200 K and
  femtoseconds at 300 K (a lower bound, assuming no barrier).

## Teaching notes

- The four stages show why BSSE needs its own stage: the ghost atoms must
  sit at the *relaxed* geometry, which only exists after SIESTA finishes
  Stage 1.
- There are 32 SIESTA runs in `adsorption_run/` (8 in Stage 1, 12 BSSE,
  12 finite displacements). In class, run Stage 1 live in
  `run/` and step through the snapshot folders for the rest.
- Upstream reference: `~/Dropbox/dev/stb/examples/5.8-adsorption/README.md`.
