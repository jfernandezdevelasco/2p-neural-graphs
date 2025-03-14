# 2p-neural-graphs

This repository contains the MATLAB code implementation for the conference proceedings paper: **An analysis pipeline for two-photon calcium imaging data to reveal the functional connectivity of the mouse somatosensory cortex**. The provided code processes two-photon calcium imaging data extracted using **CaImAn** [1] and applies network science techniques to analyze neuronal connectivity patterns. 

The pipeline is designed to reveal functional connectivity as described and developed in [2],[3], and to examine how it changes across different cortical depths and experimental conditions (e.g., awake vs. anesthetized states). A dataset of two-photon calcium imaging acquisitions from the mouse somatosensory cortex, performed across three different cortical layers in both anesthetized and awake mice, was used to develop the pipeline [4]. Network topology was investigated using the **Brain Connectivity Toolbox** [5], a MATLAB package, employing connectivity and network measures. The figure below illustrates a functional neural graph generated using the methods outlined in the pipeline.

<img src="https://github.com/user-attachments/assets/a75eaae8-8e71-423d-ab6d-27bed1c48096" width="1000"/>

---
## **Features**
- Data preprocessing involves filtering the deconvolved calcium imaging data by **CaImAn** [1], followed by peak identification.
- Functional graph construction using statistical inference.  
- Analysis of connectivity metrics through **Brain Connectivity Toolbox** [5], such as in-degree, out-degree, betweenness centrality, and modularity.  
- Visualization of neuronal patterns, connectivity graphs, and statistical comparisons.  
---
## Repository structure 
    .
    ├── tools  
    │     ├── dict_st_dep.m
    │     ├── d_s_d.mat                        # Dictionary containing experiment metadata
    │     ├── select2p.m
    │     ├── signalAlinment.m
    │     ├── peakDet.m
    │     ├── rasterPlot.m
    │     ├── funCon.m
    │     ├── plotGraph.m
    │     ├── neuralGraphNetworkMetrics.m
    │     ├── connComp.m
    │     ├── inAndOutDegrees.m
    │     ├── plotDegrees.m
    │     └── plotMulti2pNetworkMetrics.m
    ├── single2pDemo.m                        # Single 2 photon expriment demo
    ├── multi2pDemo.m                         # Multi 2 photon experiment demo
    ├── LICENSE.txt
    └── README.md

---

## **Requirements**
- **MATLAB** (Recommended version: R2020b or later)  
- **CaImAn** [1] (For deconvolving calcium imaging data)  
- **Brain Connectivity Toolbox (BCT)** [5] (For network analysis)
- Additional MATLAB toolboxes:
  - Signal Processing Toolbox  
  - Image Processing Toolbox
    
---

## **Installation**
1. Clone the repository:  
   ```bash
   git clone https://github.com/jfernandezdevelasco/2p-neural-graphs.git
   cd 2p-neural-graphs
___

## Data Format
Input should be CaImAn output files (Deconvolved calcium imaging data through CaImAn) containing:
- `F_dff`: Matrix of fluorescence traces (neurons × time)
- `I_gray`: Correlation image from the experiment
- `Coor`: Perimeter of detected neurons
  
Signal data required for alignment:  
- `adc4`: Stimulus signal (airpuff)
- `adc5`: Two photon shutter signal

Object where experiment metadata is stored:
- `d_s_d`: Dictionary with the experiment identifier and date as keys and experiment state and depth of acquisition as values.

---
## Usage

This demo applies to a single experiment scenario. For an analysis involving multiple experiments, refer to the multi2pDemo.m.

### Data Structuring

```matlab
%% Example dictonary with experiment state and depth information needed by the select2p function
an = 'Anesthetized'; aw = 'Awake';
d1 = '60';d2 = '150';d3 = '500'; % micro-meters
d_s_d = containers.Map();
%% Example experiment conducted on the 23/02/25 with acquisitions taken at 3 cortical depths and 2 different states

% anesthetized
d_s_d('250223_001') = {an,d1};d_s_d('250223_002') = {an,d2};d_s_d('250223_003') = {an,d3};

%awake
d_s_d('250223_004') = {aw,d3};d_s_d('250223_005') = {aw,d2};d_s_d('250223_006') = {aw,d1};

save('d_s_d.mat', 'd_s_d');
```

### Preprocessing
```matlab
% Load and process experiment data
st = select2p(day,month,experiment,dataPath,d_s_d,plotPeaks,plotDifPeaks,plotLcc,plotDegreeDist);

% Time series processing
[st] = signalAlignment(st);

% Event detection
[st] = peakDet(st,MIND,MINW,filt);
```

### Network Construction
```matlab
% Adjency matrix construction
[adj,st] = funCon(st);

% Network analysis
G = digraph(adj(1:end-1,1:end-1));
```

### Analysis
```matlab
% Network metrics
[st]=neuralGraphNetworkMetrics(adj,st);

% Connected component
[idx]=connComp(G,st);

% In-out degree
[st]=inAndOutDegrees(G,st);
```

### Visualization
```matlab
% Raster plot 
rasterPlot(st);

% Plot graph
plotGraph(G,st);

% Plot degree distribution
plotDegree(st,multi);
```
---

# Citation

If you use this pipeline in your research, please reference the upcoming conference proceedings paper detailing it:

J.Fernandez de Velasco Biasiolo, M.Pedersen, B.Kuhn, and C.Cecchetto, "An analysis pipeline for two-photon calcium imaging data to reveal the functional connectivity of the mouse somatosensory cortex". ICBET 2025 IEEE Conference Proceedings.
___

# References

### Deconvolution of calcium imaging data

[1] A. Giovannucci et al., “CaImAn an open source tool for scalable calcium
imaging data analysis,” eLife, vol. 8, p. e38173, Jan. 2019, DOI: [10.7554/eLife.38173](https://doi.org/10.7554/eLife.38173).

### Functional connectivity 
The function funCon is a modified version of the original functional connectivity method described in:

[2] Y. Bollmann et al., “Prominent in vivo influence of single interneurons in
the developing barrel cortex,” Nat. Neurosci., vol. 26, no. 9, pp. 1555–
1565, Sep. 2023, DOI: [10.1038/s41593-023-01405-5](https://doi.org/10.1038/s41593-023-01405-5).

The original implementation can be found in the repository associated with the paper: [HolohubDev](https://gitlab.com/yannicko-neuro/holohubdev) on GitLab.

[3] L. Mòdol, V. H. Sousa, A. Malvache, T. Tressard, A. Baude, and R.
Cossart, “Spatial Embryonic Origin Delineates GABAergic Hub Neurons
Driving Network Dynamics in the Developing Entorhinal Cortex”.

### Data

[4] C. Cecchetto, S. Vassanelli, and B. Kuhn, “Simultaneous Two-Photon
Voltage or Calcium Imaging and Multi-Channel Local Field Potential
Recordings in Barrel Cortex of Awake and Anesthetized Mice,” Front.
Neurosci., vol. 15, p. 741279, Nov. 2021, DOI:
[10.3389/fnins.2021.741279](https://doi.org/10.3389/fnins.2021.741279).

### Network measures

[5] M. Rubinov and O. Sporns, “Complex network measures of brain
connectivity: Uses and interpretations,” NeuroImage, vol. 52, no. 3, pp.
1059–1069, Sep. 2010, DOI: [10.1016/j.neuroimage.2009.10.003](https://doi.org/10.1016/j.neuroimage.2009.10.003). 

Additional information about the toolbox and download instructions can be found here: [Brain Connectivity Toolbox](https://sites.google.com/site/bctnet/home?authuser=0)

# License
This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.

# Acknowledgment 
This study was funded by the EU H2020-MSCA-IF-2017 project ‘GRACE’ (id number: 796177) to Dr. Cecchetto and the PNRR-MSCA ‘Young Researchers Award’ project 'NEUPAGES' to Dr. Cecchetto.

# Contact
For questions, please contact Juan Fernandez de Velasco Biasiolo at juan.fernandezdevelasco@unipd.it
