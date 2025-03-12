# 2p-neural-graphs

This repository contains the MATLAB code implementation for the conference proceedings paper: **"An analysis pipeline for two-photon calcium imaging data to reveal the functional connectivity of the mouse somatosensory cortex"**. The provided code processes two-photon calcium imaging data extracted using **CaImAn** [1] and applies network science techniques to analyze neuronal connectivity patterns. 

The pipeline is designed to reveal functional connectivity as described and developed in [2],[3], and to examine how it changes across different cortical depths and experimental conditions (e.g., awake vs. anesthetized states). A dataset of two-photon calcium imaging acquisitions, performed across three different cortical layers in both anesthetized and awake mice, was used to develop the pipeline [4]. Network topology was investigated using the **Brain Connectivity Toolbox**, a MATLAB package, employing network measures [5]. The figure below illustrates a functional neural graph generated using the methods outlined in the pipeline available in this repository.

<img src="https://github.com/user-attachments/assets/a75eaae8-8e71-423d-ab6d-27bed1c48096" width="1000"/>

---
## **Features**
- Data preprocessing involves filtering the CaImAn [1] output, followed by peak identification of calcium signals.
- Functional graph construction from calcium imaging data.  
- Analysis of connectivity metrics such as in-degree, out-degree, betweenness centrality, and modularity.  
- Visualizations for neuronal patterns, connectivity graphs, and statistical comparisons.  
---
## Repository structure 
    .
    ├── tools                         
    │     ├── select2p
    │     ├── signalAlinment
    │     ├── peakDet
    │     ├── rasterPlot
    │     ├── funCon
    │     ├── plotGraph
    │     ├── neuralGraphNetworkMetrics
    │     ├── connComp
    │     ├── inAndOutDegrees
    │     ├── plotDegrees
    │     └── plotMulti2pNetworkMetrics
    ├── single2pDemo                        # Single 2 photon expriment demo
    ├── multi2pDemo                         # Multi 2 photon experiment demo
    ├── LICENSE
    └── README.md

---

## **Requirements**
- **MATLAB** (Recommended version: R2020b or later)  
- **CaImAn** [1] (for calcium imaging data extraction)  
- **Brain Connectivity Toolbox (BCT)** [5] for network analysis
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
Input should be CaImAn output files containing:
- `F_dff`: Matrix of fluorescence traces (neurons × time)
- `I_gray`: Grayscale correlation image from the experiment
- `Coor`: Perimeter of detected neurons
  
Signal data required for alignment:  
- `adc4`: Stimulus signal (airpuff)
- `adc5`: Two photon shutter signal
- `d_s_d`: Dictionary with the experiment identifier and date as keys and experiment state and depth of acquisition as values.

---
## Usage

This demo applies to a single experiment scenario. For an analysis involving multiple experiments, refer to the multi2pDemo file.

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

If you use this pipline in your research, please reference the upcoming conference proceedings paper describing this pipeline:

J.Fernandez de Velasco, M.Pedersen, B.Kuhn, and C.Cecchetto, "An analysis pipeline for two-photon calcium imaging data to reveal the functional connectivity of the mouse somatosensory cortex". ICBET 2025 IEEE Conference Proceedings.
___

# Refrences

### Deconvolution of calcium imaging data

[1] A. Giovannucci et al., “CaImAn an open source tool for scalable calcium
imaging data analysis,” eLife, vol. 8, p. e38173, Jan. 2019, DOI: [10.7554/eLife.38173](https://doi.org/10.7554/eLife.38173).

### Functional connectivity 
The function funCon is a modified version of the original functional connectivity method described in:

[2] Y. Bollmann et al., “Prominent in vivo influence of single interneurons in
the developing barrel cortex,” Nat. Neurosci., vol. 26, no. 9, pp. 1555–
1565, Sep. 2023, DOI: [10.1038/s41593-023-01405-5](https://doi.org/10.1038/s41593-023-01405-5).

The original implementation can be found in the repository associated with the paper: HolohubDev on GitLab (https://gitlab.com/yannicko-neuro/holohubdev).

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

# License
This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.

# Acknowledgment 
This study was funded by the EU H2020-MSCA-IF-2017
project ‘GRACE’ (id number: 796177) to C. C. and the PNRR-
MSCA ‘Young Researchers Award’ project 'NEUPAGES' to
C.C.

# Contact
For questions, please contact Juan Fernandez de Velasco at jfernandezdevelasco@gmail.com.
