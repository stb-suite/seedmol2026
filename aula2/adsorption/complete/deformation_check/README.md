# deformation_check (not STB output)

Single points of the slab at the relaxed site geometry, with no ghost atoms
(H removed from `bsse/<site>/bsse_slab/structure.fdf`).

Why: `stb-adsorbAnalysis` computes E_ads(BSSE) = E_site - E_bsse_slab - E_bsse_adsorbate,
with the slab at the deformed geometry. That is the interaction energy: it drops the
slab deformation energy. The counterpoise adsorption energy is

    E_ads^CP = E_ads + (E_slab_def - E_slab_def[ghost H]) + (E_H - E_H[ghost slab])

| site          | E_slab_def (eV) | deformation (eV) | E_ads raw | CP (STB) | CP + deformation |
|---------------|-----------------|------------------|-----------|----------|------------------|
| site_1_ontop  | -5833.387767    | +0.430           | -0.093    | -0.437   | -0.007           |
| site_3_bridge | -5833.832468    | -0.015 (noise)   | -0.107    | -0.034   | -0.049           |
