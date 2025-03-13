%% multi2pDemo Function
% This is the main demo script for analyzing two-photon calcium imaging data 
% from multiple experimental conditions across different cortical depths. 
% The script integrates multiple functions to process, visualize, and extract 
% meaningful network metrics from the data. 
% It is designed to analyze neuronal activity patterns across:
%   - Different states 
%   - Different cortical depths 
%   - Multiple experimental sessions
%
% Usage:
%   multi2pDemo;
%
% Key Features:
%   - Loads two-photon calcium imaging data from multiple experiments (Deconvolved calcium imaging data through CaImAn).
%   - Constructs functional connectivity graphs .
%   - Computes key network metrics such as degree distribution, 
%     betweenness centrality, and modularity.
%   - Compares connectivity patterns across different cortical depths and 
%     experimental states.
%   - Visualizes the resulting connectivity graphs and data distributions.
%
% Workflow:
%   1. **Data Loading:**
%      - Data is structured as a containers.Map object, storing neuronal 
%        signals, cortical depth, experimental state, and session metadata.
%
%   2. **Functional Connectivity Graph Generation:**
%      - Constructs separate functional connectivity graphs for each condition 
%        using neuronal activity correlations.
%
%   3. **Network Analysis:**
%      - **Degree Analysis:** Computes in-degree and out-degree distributions 
%        for each experimental condition.
%      - **Centrality Analysis:** Measures betweenness centrality to identify 
%        influential nodes in each graph.
%      - **Modularity Analysis:** Identifies network community structure 
%        using modularity-based clustering.
%
%   4. **Visualization:**
%      - Generates raster plots for neuronal activity in each condition.
%      - Creates boxplots comparing neuron counts and network connectivity 
%        metrics across cortical depths and experimental states.
%      - Visualizes connectivity graphs color-coded by key metrics 
%        (e.g., centrality or modularity), enabling intuitive comparisons 
%        between conditions.
%
% Dependencies:
%   - `inAndOutDegrees.m`               : Computes in-degree and out-degree distributions.
%   - `rasterPlot.m`                    : Visualizes neuronal caclium peak activity.
%   - `neuralGraphNetworkMetrics.m`     : Computes and visualizes graph metrics.
%   - `plotDegree.m`                    : Plots degree distributions.
%   - `plotGraph.m`                     : Plots neural graph.
%   - `peakDet.m`                       : Finds and plots neuron traces and peaks.
%   - `plotMulti2pNetworkMetrics.m`     : Plots box plot and degree distributions.
%   - `signalAlignment.m`               : Aligns the calcium signals of detected neurons by upsampling them to analogFs (1000 Hz) 
%                                         to match the sampling rate of the air-puff signal and the two-photon 
%                                         microscope shutter signal.
%   - `plotPeaksDif.m`                  : Plots the distribution of lags between functionally connected neuronal 
%                                         traces and compares them to a uniform distribution.
%   - `select2p.m`                      : Retrieves and organizes 2p experimental data from a specified two-photon 
%                                         imaging experiment.
%   - `funCon.m`                        : Computes the adjacency matrix of a functionally connected neuronal graph 
%                                         based on calcium peak activity.
%   - `connComp.m`                      : Identifies and extracts the largest connected component in a neural graph. 
%                                         If a connected component exists, it is plotted for visualization.
%
% Example:
%   % Run the demo script to analyze data
%   multi2pDemo;
%
% Notes:
%   - Data structure `data` should be formatted according to CaImAn's output,
%     where neuronal traces and spatial footprints are accessible for analysis.
%
% Authors:
%   - Developed in the Neuralchip Lab, University of Padova.

clear all; close all; clc; % Clear workspace
functionFolder = '/......./2p-neural-graphs/tools'; % Add function folder to path
brainConnToolBoxPath = '/........../MATLAB Add-Ons/Toolboxes/Brain Connectivity Toolbox'; % Add package to path 
dataPath = '/......./Data/';
addpath(genpath(functionFolder))
addpath(genpath(brainConnToolBoxPath))
load("d_s_d.mat");  % Load experiment data structure

plotPeaks= false;              % Visualization of cell traces with peaks (always false if single cell false)
plotDifPeaks = false;          % Visualization of functionally connected cell traces and their respective lags compared to a uniform distribution pdf. 
plotLcc = false;               % Visualization of largest connected component of graph.
plotDegreeDist = false;        % Visualization of both degree distribution
multi = false;                 % True if plotting multi-experiment network metrics
% For peak detection
MIND = 1500;                   % Minimum duration between events (ms)
MINW = 350;                    % Minimum event width (ms)
filt = [3,767];                % Filter parameters [sigma, window size]

%% Initialize storage variables for network metrics
data.nNeuron = containers.Map(); data.edge = containers.Map(); degree.in = containers.Map(); degree.out = containers.Map();
fields = {'Awake', 'Anesthetized', 'Awake_60', 'Anesthetized_60', 'Awake_150', 'Anesthetized_150','Awake_500', 'Anesthetized_500'};
numExp = size(d_s_d,1);
for i = 1:length(fields)
    data.nNeuron(fields{i}) = zeros(numExp,1);
    data.edge(fields{i})  = [];
    degree.in(fields{i})  = [];
    degree.out(fields{i}) = [];
end
% Initialize data storage for group analysis
summaryTable = table();
%% Multi-Experiment Analysis
% Process all experiments in the dataset
for k = 1:length(d_s_d.keys)
    keys = d_s_d.keys; keys = keys(k);
    key = keys{1, 1};
    
    % Extract experiment metadata from key
    month = key(3:4); day = key(5:6); 
    experiment = key(8:end); state = d_s_d(key);
    
    % Load and process experiment data
    st = select2p(day,month,experiment,dataPath,d_s_d,plotPeaks,plotDifPeaks,plotLcc,plotDegreeDist);
    
    % Time series processing
    [st] = signalAlignment(st);
    
    % Event detection
    [st] = peakDet(st,MIND,MINW,filt);

    % Raster plot 
    %rasterPlot(st);

    % Adjency matrix construction
    [adj,st] = funCon(st);

    % Network analysis
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
    %% Storing network metrics
    depth = st("depth");state = st('state');
    for g = 1:length(fields)
        temp1 = fields{g};
        if length(temp1)~=sum(isletter(temp1))
            if str2num(temp1(isstrprop(temp1, 'digit'))) == str2num(depth) && isequal(temp1(isletter(temp1)), state)
                s = data.nNeuron(fields{g});s(k,1) = st('nNeurons');data.nNeuron(fields{g}) = s;
                data.edge(fields{g})= [data.edge(fields{g}); numedges(G)];
                degree.in(fields{g}) = [degree.in(fields{g}); st('degree_in')];
                degree.out(fields{g}) = [degree.out(fields{g}); st('degree_out')];
            end
        else 
            if isequal(temp1(isletter(temp1)), state)
                s = data.nNeuron(fields{g});s(k,1) = st('nNeurons');data.nNeuron(fields{g}) = s;
                data.edge(fields{g})= [data.edge(fields{g}); numedges(G)];
                degree.in(fields{g}) = [degree.in(fields{g}); st('degree_in')];
                degree.out(fields{g}) = [degree.out(fields{g}); st('degree_out')];
            end
        end
    end
    newRow = {strcat(day,'_',month,'_',st('depth'),'_',st('state')),st('nNeurons'),numedges(G)};
    summaryTable(end+1,:) = newRow;
end
%% Final summary table
summaryTable.Properties.VariableNames = {'Experiment', 'Number of neurons','Number of edges'};
summaryTable;

%% Plot final network descriptors (degree, number of neurons and edges)
plotMulti2pNetworkMetrics(data,degree)

