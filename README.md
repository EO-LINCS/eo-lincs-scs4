<div style="text-align: right;">
  <figure style="display: inline-flex; align-items: center;">
    <img src="docs/eo_lincs_logo.png" alt="Logo" style="height: 100px;">
    <figcaption style="font-weight: bold; font-size: 10px; margin-left: 10px;">EO-LINCS</figcaption>
  </figure>
</div>


# SCS4: EO enhanced benchmarking of GCB DGVMs

This repo gathers code for the SCS4 throughout the project. 

## Short description

**Objective**: SCS4 aims to deepen the understanding of the processes that drive the European land carbon sink, with a focus on productivity, turnover, and the impacts of disturbances and land management. Leveraging new EO data and the [International Land Model Benchmarking (ILAMB)](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2018MS001354) system, it will assess Dynamic Global Vegetation Models (DGVMs) that contribute to the Global Carbon Budget (GCB) reports. The project will result in an enhanced ILAMB tool, offering insights into carbon dynamics and DGVM performance, and providing a roadmap for future model improvements.

**Outcomes**: An enhanced ILAMB evaluation tool with a focus on internal carbon dynamics and temporal 
change able to provide novel insights into DGVM capabilities to simulate the European land carbon sink and 
identify its main drivers. The spatiotemporal analysis will enable us to produce a roadmap for model 
improvements, in particular regarding forest management.


## Repository structure

The repository is structured as follows:

- `data_extraction` - gathers the data extraction process using [xcube Multi-Source Data Store](https://xcube-dev.github.io/xcube-multistore/).
  The final analysis-ready data cubes are stored in the `data` directory.
- `data` - contains the final analysis-ready data cubes. (will be created during data extraction process)
- `scientific_analyis` - contains the notebooks for the scientific analysis.

For further information, please refer to the ReadMe in the directroies 
`data_extraction` and `scientific_analysis`.
