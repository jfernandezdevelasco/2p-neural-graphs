function [adjBin,st] = funCon(st)
%% funCon Function
% Computes the adjacency matrix of a functionally connected neuronal graph 
% based on calcium peak activity. This function infers functional connectivity by analyzing the
% distribution of relative delays in the activation peaks of neuronal pairs. 
% It also analyzes activation peak dealys relative to the stimulus to assess whether individual neurons
% are functionally connected and driven by the stimulus itself.
%
% This function is a modified version of the original functional connectivity 
% method described in [Bollmann et al., 2023]. The original implementation can be found 
% in the repository associated with the paper: 
% https://gitlab.com/yannicko-neuro/holohubdev
%
% Reference:
% Bollmann, Y., Modol, L., Tressard, T. et al. Prominent in vivo influence of single 
% interneurons in the developing barrel cortex. Nat Neurosci 26, 1555–1565 (2023). 
% https://doi.org/10.1038/s41593-023-01405-5
%
% Usage:
%   adjBin = funCon(st);
%
% Inputs:
%   - st (containers.Map) : A key-value data structure containing experimental 
%                            data, including calcium fluorescence signals and their relative peaks.
%
% Outputs:
%   - adjBin (matrix NxN)     : The binary adjacency matrix representing functional 
%                            connectivity between neurons.
%   - st (containers.Map) : A key-value data structure containing experimental 
%                            data, including calcium fluorescence signals and their relative peaks.
%
% Processing Steps:
%   1. Extracts calcium activity data (`peaks`) from the input structure.
%   2. Computes functional connectivity between neurons based on statistical tests to assess uniformity in the 
%      delay distributions, the Kolmogorov–Smirnov (KS) test is applied and a t-test is also used to exclude delays centered around zero.
%   3. Constructs the adjacency matrix, where each element represents a connection 
%      between two neurons or stimulus-neuron.
%
% Stored Information in 'st':
%   - 'adjBin' : The binary adjacency matrix of functional connectivity graph.
%
% Example:
%   [adjBin,st] = funCon(st);

% Unpacking variables
nNeurons = st('nNeurons'); peaks = st('peaks');
time = st('time');tpuff = st('tpuff');
% Creates adjency matrix of functional connectivity graph
adjBin = zeros(nNeurons+1,nNeurons+1); % nNeurons+1 the extra node in the adjency matrix is for the stimulus node   
% Defining maxium lag for connectivity 
maxLag = 2; st('maxLag') = maxLag; 
maxLagStim = ceil(max(diff(tpuff))); % The maximum time difference between stimulation events
% Defining cumulative distribution function of uniform distribution on the interval [-2,2]
uniProbCDF = [-maxLag:maxLag; unifcdf(-maxLag:maxLag,-maxLag,maxLag)]'; 
% Defining cumulative distribution function of uniform distribution on the interval [0,maxLagStim]
uniProbCDFStim = [0:maxLagStim; unifcdf(0:maxLagStim,0,maxLagStim)]';
%% Loop through all neurons 
for i = 1:nNeurons
    pks = time(peaks(i,:)==1); % Peak times
    %% Stimulus driven functional connectivity between stimulus and individual neuron
    stimPeakDif = []; % Time difference between stimulus and peaks 
    for r = 1:length(tpuff)-1 % For each stimulus 
        if ~isempty(pks(pks<tpuff(r+1) & pks>tpuff(r)) - tpuff(r)) 
             stimPeakDif = [stimPeakDif; pks(pks<tpuff(r+1) & pks>tpuff(r)) - tpuff(r)]; % 
        end
    end
    % Statistical tests
    if ~isempty(stimPeakDif)
        [~,pttStim] = ttest(stimPeakDif,1); % Test the mean of the stimulus-neuron peak difference distribution
        [~,pksStim] = kstest(stimPeakDif,uniProbCDFStim); % Test if the stimulus-neuron peak difference distribution is uniform or not 
        skew = skewness(stimPeakDif); % Test if the stimulus-neuron peak difference distribution is skewed towards 0
        % Test distribution conditions
        if length(stimPeakDif)> 10 && pttStim > 0.05 && skew > 2 && pksStim < 0.05 
            adjBin(end,i) = 1; % Connection between stimulus and neuron is infered
        end
    end
    %% Functional connectivity between individual neurons 
    for j = i:nNeurons
        if i ~= j
            lagsWithinStim = []; % Lags of different neurons between two stimulation events. 
            for r = 1:length(tpuff) % For each stimulation 
                if r <= length(tpuff)-1 % Before the last stimulation 
                    % multiplied by 1000 because signal has sampleing
                    % frequency 1000 Hz
                    crossCorr = xcorr(peaks(i,round(tpuff(r)*1000):round(tpuff(r+1)*1000)),peaks(j,round(tpuff(r)*1000):round(tpuff(r+1)*1000)),maxLag*1000);
                    lags = repelem(-maxLag*1000:maxLag*1000,round(crossCorr))/1000; 
                    if(~isempty(lags))
                        lagsWithinStim = [lagsWithinStim lags];
                    end 
                else
                    % The time period after the last stimulation event.
                    crossCorr = xcorr(peaks(i,round(tpuff(end)*1000):end),peaks(j,round(tpuff(end)*1000):end),maxLag*1000);
                    lags = repelem(-maxLag*1000:maxLag*1000,round(crossCorr))/1000;
                    if(~isempty(lags))
                        lagsWithinStim = [lagsWithinStim lags];
                    end

                end
            end
            % Statistical test 
            if(~isempty(lagsWithinStim) && length(lagsWithinStim)>5) % There needs to be a minimum of 5 lag samples 
                % Kolmogorov-Smirnov Test for uniformity
                [~,pktest] = kstest(lagsWithinStim,uniProbCDF);
                % t-Test to check if mean is different from 0
                [~,pttest] = ttest(lagsWithinStim);
                if pktest < 0.05 && pttest < 0.05
                    %% Plot difference of peaks
                    plotPeaksDif(lagsWithinStim,i,j,pktest,pttest,st)
                    %% Fill in adjency matrix 
                    if mean(lagsWithinStim) < 0 % If mean is less than zero cell i is on average before cell j
                        adjBin(i,j) = 1; 
                    else
                        adjBin(j,i) = 1; % If mean is more than zero the opposite is true 
                    end              
                end
            end
        end
    end
end
end