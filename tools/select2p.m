function st = select2p(day,month,experiment,dataPath,d_s_d,plotPeaks,plotDifPeaks,plotLcc, plotDegree)
%% select2p Function
% Retrieves and organizes 2p experimental data from a specified two-photon 
% imaging experiment. The function loads the required data based on the 
% provided date, experiment ID, and data path, and returns a containers.Map 
% object containing all relevant information about the experiment.
%
% Usage:
%   st = select2p(day, month, experiment, dataPath, d_s_d,plotPeaks,plotDifPeaks,plotLcc, plotDegree);
%
% Inputs:
%   - day (string/int)          : The day of the experiment.
%   - month (string/int)        : The month of the experiment.
%   - experiment (string/int)   : Identifier for the specific experiment.
%   - dataPath (string)         : Path to the folder containing the experimental data.
%   - d_s_d (dictionary)        : Dictionary with information (state, depth) related to the experiment.
%   - plotPeaks (boolean)       : If true, plots each trace with its detected
%   peaks if false, does not plot.
%   - plotDifPeaks (boolean)    : If true, plots traces with its detected
%   peaks that are functionally connected cell and their respective lags
%   compared to a uniform distribution pdf.  if false, does not plot.
%   - plotLcc (boolean)         : If true, plots largest connected component of graph. If false, does not plot.
%   - plotDegree (boolean)      : If true, plots both degree distribution of graph. If false, does not plot.
%
%
% Outputs:
%   - st (containers.Map)   : A key-value data structure containing the 
%                             experimental details and data.
%
% Stored Information in 'st':
%   - 'nNeurons'    : Number of detected neurons.
%   - 'adc4'        : Airpuff signal.
%   - 'adc5'        : 2p shutter signal.
%   - 'analogFs'    : Sampling frequency of analog signals (Two photon shutter and air-puff).
%   - 'fs'          : Sampling frequency of calcium traces.
%   - 'F_dff'       : Calcium fluorescence signals (neurons x time).
%   - 'Coor'        : Coordinates of perimeter of neurons.
%   - 'day'         : The day of the experiment.
%   - 'month'       : The month of the experiment.
%   - 'experiment'  : Experiment identifier.
%   - 'depth'       : Imaging depth.
%   - 'state'       : Experimental state (awake/anesthetized).
%   - 'I_gray'      : Correlation image.
%   - 'plotPeaks'   : Boolean value.
%   - 'plotDifPeaks': Boolean value.
%   - 'plotLcc'     : Boolean value.
%   - 'plotDegree'  : Boolean value.
%
% Example:
%   dataPath = 'C:\data\experiment1';
%   st = select2p('15', '3', '001', dataPath, d_s_d ,plotPeaks ,plotDifPeaks,plotLcc,plotDegree);
%
%   % Access specific information
%   nNeurons = st('nNeurons');
%   fluorescenceData = st('F_dff');
%

%% Extracting state and depth of experiment from custom dictionary using the date of the experiment and an identifier.
tiffNum = 'All'; % Indicating the experiment is whole and was not split in to two separate TIFF files 
temp = d_s_d(strcat('20', month, day,'_',experiment));
state = temp{1};
depth = temp{2};
% Adding data to path, specifying the path and the experimental state the
% data was taken in (e.g. awake)
addpath(genpath(strcat(dataPath,state)));

st = containers.Map();
st('fs') = 30.9;% Imaging fs, change if boxscan is done with different number of rows
st('analogFs') = 1000; % Two photon shutter and air-puff signals sampleing rate

%% Load data
roi_exp_name = strcat('20', month, day,'_',experiment,'_',tiffNum);
load(strcat('ROI_',roi_exp_name,'.mat')) 

%% Cell coordinates 
centroid_roi = [];
for i = 1:length(Coor) % Coor is a variable that stores the perimeter of the cell. 
    temp = Coor(i, :);
    if ~isempty(temp{1})
        centroid_roi = [centroid_roi mean(temp{1}')']; % Getting the centroid of the cell. 
    else
        F_dff(i,:) = [];
    end
end
centroid_roi = [centroid_roi [1 250]']; % Stimulus node location
%% Organizing 2p experimental data
st('nNeurons')= size(F_dff,1);
st('adc4')= adc4;
st('adc5')= adc5;
st('F_dff') = full(F_dff);
st('Coor') = Coor;
st('day') = day;
st('month') = month;
st('experiment') = experiment;
st('depth') = depth;
st('state') = state;
st('I_gray') = I_gray;
st('plotPeaks') = plotPeaks;
st('plotDifPeaks') = plotDifPeaks;
st('plotLcc') = plotLcc;
st('plotDegree') = plotDegree;
st('centroid_roi') = centroid_roi;


