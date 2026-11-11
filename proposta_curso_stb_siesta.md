# Course Proposal: SIESTA + STB-Suite Minicourse
**Target audience:** Researchers and undergraduate or graduate students in Physics, Chemistry, and Materials Science  
**Total duration:** 4 hours (two 2-hour classes)  
**Base environment / repository:** `~/Dropbox/dev/stb` (`stb-suite`)

---

## 🎯 Learning Objectives

After four hours, participants should be able to:
1. Identify the main components of a DFT calculation in **SIESTA**: LCAO basis, pseudopotentials, real-space grid, k-point sampling, and the self-consistent cycle.
2. Prepare and inspect a GaAs (3D) or monolayer h-BN (2D) `.fdf` input with `stb-*` tools, and explain why numerical parameters must be converged before comparing energies or properties.
3. Read basic electronic results from calculations that have already run, and recognize what each analysis can—and cannot—conclude.
4. Understand the staged structure of an STB workflow, including external SIESTA execution and the checks required before interpreting calculated properties.

The focus is a complete, reproducible preparation → calculation → analysis experience, rather than a superficial demonstration of every module in the suite.

---

## ⏱️ Proposed Schedule

### 📅 Class 1 — From the physical problem to a converged calculation (2 h)

| Block | Time | Topic | Conceptual and practical content | Tools / actions |
|---|---|---|---|---|
| **1.1** | 10 min | **Opening and suite map** | • Course objectives and workflow.<br>• `stb-suite` is the interactive menu; each `stb-*` is an independent command.<br>• STB prepares inputs and analyzes results, but does not execute SIESTA. Installation and environment checks must be completed before class. | `stb-suite`<br>`stb-<command> --help` |
| **1.2** | 20 min | **What a SIESTA calculation approximates** | • DFT, the self-consistent field (SCF) cycle, and the essential content of an `.fdf` file.<br>• LCAO numerical-orbital basis and pseudopotentials: what is treated explicitly and what remains in the core.<br>• `PAO.EnergyShift` controls orbital confinement; `Mesh.Cutoff` controls real-space-grid resolution; the k-point grid samples the Brillouin zone.<br>• Avoid treating these parameters as a single plane-wave “cutoff”: they control distinct numerical errors. | Slides and `.fdf` inspection |
| **1.3** | 25 min | **Preparing structure and input: GaAs and h-BN** | • Convert zincblende GaAs (3D, 2-atom primitive cell) to `.fdf`; check the cell, species, and coordinates.<br>• Select PseudoDojo pseudopotentials and generate an initial 0.2 Å$^{-1}$ k-point density: 10×10×10 for GaAs.<br>• Contrast it with monolayer h-BN (2D, 15 Å vacuum): `stb-kgrid` detects the nonperiodic axis and proposes 15×15×1.<br>• Generate separate PBE/DZP inputs for total energy and relaxation; for h-BN, keep the cell fixed to preserve the vacuum. Use `Mesh.Cutoff = 320 Ry` and `PAO.EnergyShift` as initial values for the convergence section. | `stb-translate`<br>`stb-pseudo`<br>`stb-kgrid`<br>`stb-inputfile`<br>Short SIESTA SCF |
| **1.4** | 5 min | **Break** | Short break. | — |
| **1.5** | 30 min | **Convergence: preparation and interpretation** | • Introduce the three parameters scanned by the workflow: `Mesh.Cutoff`, `PAO.EnergyShift`, and k-point density.<br>• Show how `stb-convergence` prepares independent relaxation folders for the scan points; SIESTA execution occurs afterward, outside STB.<br>• Use prepared results and `stb-convergenceAnalysis` to compare energy per atom and relaxed geometry, identify a plateau, and explain why these are distinct criteria.<br>• Do not select parameters merely because the energy appears stable. | `stb-convergence`<br>`stb-convergenceAnalysis`<br>Prepared example `5.5` |
| **1.6** | 30 min | **Cohesive energy: closing Class 1** | • Define cohesive energy per atom, $E_{\text{coh}} = [E_{\text{bulk}} - \sum_i E_{\text{atom},i}]/N$; in this convention, a negative value indicates a bound solid.<br>• Show how `stb-cohesive` prepares crystal and isolated-atom calculations and how `stb-cohesiveAnalysis` collects the results.<br>• Connect property reliability to parameter convergence and introduce BSSE/counterpoise correction as an important diagnostic for LCAO bases.<br>• Demonstrate the analysis with precomputed results; running SIESTA in all generated folders does not fit within this block. | Workflow `5.3`<br>`stb-cohesive`<br>`stb-cohesiveAnalysis`<br>Prepared example `5.3` |

---

### 📅 Class 2 — Analyzing results and exploring property workflows (2 h)

| Block | Time | Topic | Conceptual and practical content | STB tools |
|---|---|---|---|---|
| **2.1** | 10 min | **Review: from output to property** | • Review the flow: input → SIESTA execution → output files → STB analysis.<br>• Identify which results from the previous class will be reused. | `stb-status` |
| **2.2** | 25 min | **Bands and density of states** | • Generate a high-symmetry path and analyze bands and the direct/indirect gap.<br>• Relate DOS/PDOS to the band structure without confusing path sampling with a converged SCF k-point grid.<br>• Perform the analysis on precomputed outputs. | `stb-kpath`<br>`stb-bands`<br>`stb-dos`<br>Prepared example `2.1` / `2.2` |
| **2.3** | 20 min | **Critical reading of electronic results** | • Interpret band edges and states near the Fermi level.<br>• Show Gaussian DOS convolution/broadening with `stb-convdos` and discuss that the selected width affects visual resolution, not the accuracy of the original calculation.<br>• Introduce work function for systems with surfaces/vacuum, $\Phi = E_{\text{vac}} - E_F$, and show how `stb-workfunction` obtains the vacuum level from the planar-averaged potential; emphasize that it is not defined for a periodic 3D crystal without vacuum.<br>• Show orbital projections (*fatbands*) only if prepared example files are available.<br>• Relate confidence in the result to numerical-parameter convergence. | `stb-convdos`<br>`stb-workfunction`<br>`stb-fatbands` (optional) |
| **2.4** | 5 min | **Break** | Short break. | — |
| **2.5** | 25 min | **2D case study: adsorption on graphene** | • Discuss out-of-plane vacuum, lateral supercell, and interactions between periodic images.<br>• Show that `stb-adsorb` prepares the calculations, but clean-slab, isolated-adsorbate, and site directories must be executed by SIESTA.<br>• Interpret $E_{\text{ads}} = E_{\text{site}} - E_{\text{slab}} - E_{\text{adsorbate}}$; to discuss BSSE correction, include the dedicated `stb-adsorbBsse` stage before `stb-adsorbAnalysis`.<br>• Analyze a precomputed result and visualization; do not attempt to run every stage during class. | Workflow `5.8`<br>`stb-adsorb`<br>`stb-adsorbBsse`<br>`stb-adsorbAnalysis` |
| **2.6** | 30 min | **Workflow example: elastic constants** | • Start from a relaxed reference structure and show how `stb-elasticInputs` generates strained structures to calculate elastic constants.<br>• Explain external SIESTA execution and analyze prepared results with `stb-elasticAnalysis`.<br>• Interpret the determination of $C_{ij}$ from stresses or energies, the role of symmetry, derived elastic moduli, and quality and mechanical-stability checks.<br>• Use the prepared example to follow the workflow without waiting for strained calculations. | Workflow `5.2`<br>`stb-elasticInputs`<br>`stb-elasticAnalysis`<br>Prepared example `5.2` |
| **2.7** | 5 min | **Closing** | Recap the reproducible workflow, point participants to examples and documentation, and open the floor for final questions. | `stb-suite` |

---

## 💡 Delivery Strategy (Methodology)

1. **Preparation before the course**
   - Install and test STB and SIESTA before class; installation must not consume contact time. The Python package is in `stb-suite/`; for a development installation, run `pip install -e .` in that directory.
   - Confirm beforehand which pseudopotentials, binaries, dependencies, and computational resources will be available.
   - Prepare the completed Section 1.3 walkthrough for both structural contrasts: zincblende GaAs (3D, 2-atom primitive cell) and monolayer h-BN (2D, 15 Å vacuum). For both, include `stb-translate` → `stb-pseudo` → `stb-kgrid` → `stb-inputfile` → SIESTA SCF, with reports and outputs available for inspection.
   - Prepare complete demonstration directories: a completed convergence scan; cohesive-energy/BSSE results; a calculation with outputs for bands/DOS; and adsorption and elastic-constant results that can be inspected without waiting for calculations.
   - Test examples and scripts, remove machine-specific absolute paths, and prepare a clean copy of the data for all participants.
2. **In-class delivery**
   - Prepare the GaAs input live and use h-BN to contrast dimensionality, vacuum, and k-point sampling. Submit at most one short SCF calculation; explain that the queue does not need to finish during class.
   - Explicitly mark the boundary between STB preparation, SIESTA (or SLURM) execution, and STB analysis.
   - Use precomputed results for interpretation, clearly stating the parameters, configuration, and level of theory that produced them.
3. **Choosing systems**
   - Do not force a single material for every topic: use GaAs as the 3D reference for initial preparation and h-BN as the 2D contrast in Class 1; use silicon as a simple reference for convergence and bands; use graphene as the 2D adsorption case study, supported by existing STB examples. For elastic constants, choose an example whose symmetry and dimensionality allow a clear discussion of $C_{ij}$ interpretation.
   - If the priority is an experimental cycle entirely on one material, choose the system according to the audience and available resources first; in that case, reduce the number of workflows shown.

---

## 🧭 Schedule Assessment and Recommendations

The initial schedule has a strong selection of tools and an attractive narrative: prepare a calculation, converge parameters, interpret properties, and finish with modern workflows. Its weakness is density: convergence, cohesion/BSSE, elastic constants, bands/DOS, three charge methods, adsorption, and MLFF/phonons do not fit as practical activities in four hours, especially because several workflows require generating many directories, executing SIESTA, and only then analyzing results.

The revision therefore prioritizes a fundamental cycle (input → convergence → properties) and retains adsorption as a demonstration with prepared data. Cohesive energy closes the first class as a concrete application of convergence and introduces BSSE; elastic constants receive a 30-minute guided example in the second class, while charge analysis becomes an advanced topic. This reduces breadth but makes it more likely that participants will understand and reproduce the central workflow after the course.

Two simplifications in the initial text should also be avoided: (1) do not characterize `PAO.EnergyShift` as a direct cutoff radius, because it controls orbital confinement; (2) do not state that Bader analysis is simply invalid for pseudopotentials—the quality depends on the valence density and the pseudopotential, and some basins may not be well defined.

## 📌 Outstanding Practical Decisions

1. **Demonstration environment defined:** `conda activate stb`, with STB-Suite and SIESTA 5.4.2 MPI. Validate the environment and PseudoDojo pseudopotentials before class; installation remains outside contact time.
2. **SIESTA access:** the short SCF calculation in the examples ran with two MPI processes. Confirm whether participants will have the same binary and pseudopotentials; without them, hands-on input preparation and analysis still work with prepared data, but the live calculation cycle will not be reproducible.
3. **Advanced emphasis:** the revised proposal uses graphene adsorption and elastic constants. If the audience is more interested in another workflow, replace one of these examples—do not simply add it.
