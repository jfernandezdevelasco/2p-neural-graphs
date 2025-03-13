%% single2pDemo Function
% This is a main demo script for analyzing two-photon calcium imaging data 
% from neuronal populations. The script integrates multiple functions 
% to process, visualize, and extract meaningful network metrics from the data. 
% It is designed to analyze neuronal activity patterns in different states 
% and at different cortical depths.
%
% Usage:
%   single2pDemo;
%
% Key Features:
%   - Loads two-photon calcium imaging data (Deconvolved calcium imaging data through CaImAn).
%   - Constructs functional connectivity graphs from neuronal activity.
%   - Computes key network metrics such as degree distribution, 
%     betweenness centrality, and modularity.
%   - Visualizes the resulting connectivity graphs and data distributions.
%
% Workflow:
%   1. **Data Loading:**
%      - The script loads calcium imaging data from pre-specified data.
%      - Data is structured as a containers.Map object, storing both neuronal 
%        signals and metadata such as cortical depth and experimental state.
%
%   2. **Functional Connectivity Graph Generation:**
%      - The script computes a directed graph using neuronal activity correlations 
%      - The graph object is used for subsequent network analysis.
%
%   3. **Network Analysis:**
%      - **Degree Analysis:** Computes in-degree and out-degree distributions.
%      - **Centrality Analysis:** Measures betweenness centrality to identify 
%        influential nodes in the network.
%      - **Modularity Analysis:** Identifies network community structure 
%        using modularity-based clustering.
%
%   4. **Visualization:**
%      - Generates raster plots for neuronal activity.
%      - Visualizes connectivity graphs color-coded by key metrics 
%        (e.g., centrality or modularity).
%
% Dependencies:
%   - `inAndOutDegrees.m`               : Computes in-degree and out-degree distributions.
%   - `rasterPlot.m`                    : Visualizes neuronal caclium peak activity.
%   - `neuralGraphNetworkMetrics.m`     : Computes and visualizes graph metrics.
%   - `plotDegree.m`                    : Plots degree distributions.
%   - `plotGraph.m`                     : Plots neural graph.
%   - `peakDet.m`                       : Finds and plots neuron traces and peaks.
%   - `signalAlignment.m`               : Aligns the calcium signals of detected neurons by upsampling them to analogFs (1000 Hz) 
%                                         to match the sampling rate of the air-puff signal and the two-photon 
%                                         microscope shutter signal.
%   - `plotPeaksDif.m`                  : Plots the distribution of lags between functionally connected neuronal 
%                                         traces and compares them to a uniform distribution..
%   - `select2p.m`                      : Retrieves and organizes 2p experimental data from a specified two-photon 
%                                         imaging experiment.
%   - `funCon.m`                        : Computes the adjacency matrix of a functionally connected neuronal graph 
%                                         based on calcium peak activity.
%   - `connComp.m`                      : Identifies and extracts the largest connected component in a neural graph. 
%                                         If a connected component exists, it is plotted for visualization.
%
% Example:
%   % Run the demo script to analyze data
%   single2pDemo;
%
% Notes:
%   - Data structure `data` should be formatted according to CaImAn's output,
%     where neuronal traces and spatial footprints are accessible for analysis.
%
% Authors:
%   - Developed in the Neuralchip Lab, University of Padova.

clear all; close all; clc; % Clear workspace

functionFolder = '/....../2p-neural-graphs/tools'; % Add function folder to path
brainConnToolBoxPath = '/......./MATLAB Add-Ons/Toolboxes/Brain Connectivity Toolbox'; % Add package to path 
dataPath = '/....../Data/';
addpath(genpath(functionFolder))
addpath(genpath(brainConnToolBoxPath))
load("d_s_d.mat");  % Load experiment data structure

plotPeaks= false;               % Visualization of cell traces with peaks 
plotDifPeaks = false;           % Visualization of functionally connected cell traces and their respective lags compared to a uniform distribution pdf. 
plotLcc = false;                % Visualization of largest connected component of graph
plotDegreeDist = false;         % Visualization of both in and out degree distribution
multi = false;                  % True if plotting multi-experiment network metrics
% For peak detection
MIND = 1500;                    % Minimum duration between events (ms)
MINW = 350;                     % Minimum event width (ms)
filt = [3,767];                 % Filter parameters [sigma, window size]


%% Single Experiment Analysis
month = ''; day = ''; experiment = '';

% Load and process experiment data
st = select2p(day,month,experiment,dataPath,d_s_d,plotPeaks,plotDifPeaks,plotLcc,plotDegreeDist);

% Time series processing
[st] = signalAlignment(st);

% Event detection
[st] = peakDet(st,MIND,MINW,filt);

% Raster plot 
rasterPlot(st);

% Adjency matrix construction
[adj,st] = funCon(st);

% Network construction
G = digraph(adj(1:end-1,1:end-1));

% Plot graph
plotGraph(G,st);

% Plot graph with stimulus node
plotGraph(digraph(adj),st);

% Plot graph network metrics
[st]=neuralGraphNetworkMetrics(adj,st);

% Connected component
[idx]=connComp(G,st);

% In-out degree
[st]=inAndOutDegrees(G,st);

% Plot degree distribution
plotDegree(st,multi);