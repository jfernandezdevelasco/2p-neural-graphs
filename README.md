# 2p-neural-graphs
---
# Overview 

This repository contains the MATLAB code implementation for the paper:  
**"An analysis pipeline for two-photon calcium imaging data to reveal the functional connectivity of the mouse somatosensory cortex"**

The provided code processes two-photon calcium imaging data extracted using **CaImAn** and applies network science techniques to analyze neuronal connectivity patterns. The pipeline is designed to reveal functional connectivity changes under different cortical depths and experimental conditions (e.g., awake vs anesthetized states).

---
## **Features**
- Data preprocessing involves filtering the CaImAn output, followed by peak identification of calcium signals.
- Functional graph construction from calcium imaging data.  
- Analysis of connectivity metrics such as in-degree, out-degree, betweenness centrality, and modularity.  
- Visualizations for neuronal patterns, connectivity graphs, and statistical comparisons.  
---
## **Repository Structure**

## **Requirements**
- **MATLAB** (Recommended version: R2020b or later)  
- **CaImAn** (for calcium imaging data extraction)  
- **Brain Connectivity Toolbox (BCT)** for network analysis  
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
- `d_s_d`: Dictionary containing each experiment state and depth of acquisition

---
## Usage

Usage 

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

## Contributing
Contributions welcome! Please:
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a pull request

---
# Citation
# Refrences

### Data
[1] C. Cecchetto, S. Vassanelli, and B. Kuhn, “Simultaneous Two-Photon
Voltage or Calcium Imaging and Multi-Channel Local Field Potential
Recordings in Barrel Cortex of Awake and Anesthetized Mice,” Front.
Neurosci., vol. 15, p. 741279, Nov. 2021, doi:
10.3389/fnins.2021.741279.

### Deconvolution of calcium imaging data
[2] E. A. Pnevmatikakis, “Analysis pipelines for calcium imaging data,”
Curr. Opin. Neurobiol., vol. 55, pp. 15–21, Apr. 2019, doi:
10.1016/j.conb.2018.11.004.

[3] A. Giovannucci et al., “CaImAn an open source tool for scalable calcium
imaging data analysis,” eLife, vol. 8, p. e38173, Jan. 2019, doi:
10.7554/eLife.38173.

### Functional connectivity 
[4] Y. Bollmann et al., “Prominent in vivo influence of single interneurons in
the developing barrel cortex,” Nat. Neurosci., vol. 26, no. 9, pp. 1555–
1565, Sep. 2023, doi: 10.1038/s41593-023-01405-5.

[5] L. Mòdol, V. H. Sousa, A. Malvache, T. Tressard, A. Baude, and R.
Cossart, “Spatial Embryonic Origin Delineates GABAergic Hub Neurons
Driving Network Dynamics in the Developing Entorhinal Cortex”.

# License

# Acknowledgment 
This study was funded by the EU H2020-MSCA-IF-2017
project ‘GRACE’ (id number: 796177) to C. C. and the PNRR-
MSCA ‘Young Researchers Award’ project 'NEUPAGES' to
C.C.

# Contact
