## SCS4: EO enhanced benchmarking of GCB DGVMs

This repo gathers code for the SCS4 throughout the project. 

### Short description

**Objective**: SCS4 aims to deepen the understanding of the processes that drive the European land carbon sink, with a focus on productivity, turnover, and the impacts of disturbances and land management. Leveraging new EO data and the [International Land Model Benchmarking (ILAMB)](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2018MS001354) system, it will assess Dynamic Global Vegetation Models (DGVMs) that contribute to the Global Carbon Budget (GCB) reports. The project will result in an enhanced ILAMB tool, offering insights into carbon dynamics and DGVM performance, and providing a roadmap for future model improvements.

**Outcomes**: An enhanced ILAMB evaluation tool with a focus on internal carbon dynamics and temporal 
change able to provide novel insights into DGVM capabilities to simulate the European land carbon sink and 
identify its main drivers. The spatiotemporal analysis will enable us to produce a roadmap for model 
improvements, in particular regarding forest management.


### How to Generate the Data Cubes

#### Set up the Environment

Before proceeding, ensure that all required dependencies are installed. The recommended approach is to create a Conda/Mamba environment using the provided environment specification:

`conda env create -f environment.yml`

The corresponding file can be found here: https://github.com/EO-LINCS/eo-lincs-scs4/blob/main/cube_generation/environment.yml

After creation, activate the environment:

`conda activate eo-lincs-scs4`

Next, to access the FLUXCOM-X-BASE data from the [ICOS Data Portal](https://www.icos-cp.eu/data-services/about-data-portal), users must [create an account](https://cpauth.icos-cp.eu/login/?targetUrl=https%3A%2F%2Fwww.icos-cp.eu%2Fdata-services%2Fabout-data-portal) and provide their registered email address and password to the [configuration YAML scs4_config.yml#L71](https://github.com/EO-LINCS/eo-lincs-scs4/blob/main/cube_generation/scs4_config.yml#L71).


#### Execute the Cube Generation Pipeline

All scripts and notebooks required for cube generation are located in the `cube_generation` folder.

The cube generation workflow is split into two notebooks:

1. The **GLOBMAP Global Leaf Area Index (LAI) Dataset Since 1981** must be prepared in advance. To do so, run the notebook `prepare_lai.ipynb`. 
2. Run the notebook `scs4_xcube_multistore.ipynb`, which consists of a step-by-step guide to generate the data cubes  
