<div style="text-align: right;">
  <figure style="display: inline-flex; align-items: center;">
    <img src="../docs/eo_lincs_logo.png" alt="Logo" style="height: 100px;">
    <figcaption style="font-weight: bold; font-size: 10px; margin-left: 10px;">EO-LINCS</figcaption>
  </figure>
</div>

# Scientific Analysis

Analysis code and notebooks used for SCS4, organised by step into the folders below.

## biomass_cube_extraction

Configuration and notebooks to build the European biomass data cube with `xcube-multistore`.

- `config_Europe.yml` — multistore configuration defining the data sources, variables, grid and time range for the Europe cube.
- `setup_config_mo-Europe.ipynb` — notebook that prepares/edits the cube configuration.
- `use_xcube_multistore_Europe.ipynb` — notebook that runs `xcube-multistore` to extract and build the cube.

## reference_data_preprocessing

Scripts to process the GLOBMAP LAI and FLUXCOM reference datasets onto the 0.125° Europe grid for ILAMB.

- `process.sh` — processes FLUXCOM-X GPP/ET (2001–2021): fixes time/lat/lon metadata, conservatively remaps to 0.125°, and subsets to Europe.
- `process_0.125d_Europe.txt` — GLOBMAP LAI workflow: converts HDF tiles to GeoTIFF, warps/resamples to the 0.125° Europe grid, and rescales to physical units.
- `fix_final_ncdf_time_meta.R` — rewrites the `time`/`time_bnds` axis of the final monthly LAI NetCDF to a CF-compliant `365_day` calendar.

## pft_landcover_and_ilamb

Scripts to convert land cover to JULES PFTs, compute observation-based biomass turnover, and run the ILAMB benchmarking.

- `create_JULES_PFTs.R` — converts HILDA+ land-cover states into JULES PFT fractions on the 0.125° Europe grid.
- `create_Europe_0.125d.sh` — converts ESA CCI/C3S land cover (1993–2022) to PFTs over Europe via the LC user tools cross-walk.
- `create_biomass_tau.R` — computes biomass turnover time (tau) from GPP and vegetation carbon, aligning their time axes.
- `setup_expanded_nocci_newLAI_seasonal_relationships.cfg` — ILAMB configuration defining the variables, datasets and scoring for the run.
- `run_ilamb_nocci_newLAI_seasonal_relationships_v2.sh` — sets the ILAMB environment and launches `ilamb-run` with the above config.
