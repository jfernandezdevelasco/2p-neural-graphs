function [st] = peakDet(st,MIND,MINW,filt)
%% peakDet Function
% Detects calcium peaks for each neuronal trace in an experiment. The function 
% applies filtering using a Savitzky-Golay (sgolay) filter, then identifies peaks 
% based on specified peak detection parameters such as minimum peak distance 
% and width. Optionally, it can plot the detected peaks for visualization.
%
% Usage:
%   st = peakDet(st, MIND, MINW, filt);
%
% Inputs:
%   - st (containers.Map) : A key-value data structure containing experimental data, 
%                            including calcium fluorescence signals.
%   - MIND (numeric)      : Minimum peak distance for detection.
%   - MINW (numeric)      : Minimum peak width for detection.
%   - filt (vector)       : Filtering parameters for the Savitzky-Golay filter [polynomial order, window size].
%
% Outputs:
%   - st (containers.Map) : The updated structure containing peak detection results.
%
% Processing Steps:
%   1. Applies Savitzky-Golay filtering to smooth the calcium fluorescence signal.
%   2. Detects peaks using the specified minimum distance (`MIND`), width (`MINW`) and threshold (`THRESH`).
%   3. If `plotPeaks` is true, generates plots of each calcium trace with detected peaks.
%
% Stored Information in 'st' (Updated):
%   - 'peaks'   : One-hot encoded cell array containing detected peak times for each neuron (nxm = number of neurons x time).
%   - 'dfFilt'  : The filtered fluorescence signal after applying the sgolay filter.
%
% Example:
%   MIND = 0.2;  % Minimum peak distance 
%   MINW = 5;    % Minimum peak width
%   filt = [3, 11]; % Savitzky-Golay filter parameters (polynomial order, window size)
%   st('plotPeaks') = true;
%   st = peakDet(st, MIND, MINW, filt);
%
%   % Access detected peaks in 
%   peakTimes = st('peaks');

% Unpacking variables
nNeurons = st('nNeurons'); day = st('day');month = st('month');experiment = st('experiment');depth = st('depth');
state = st('state'); centroid_roi = st('centroid_roi'); time=st('time');tpuff= st('tpuff'); df=st('dFshiftups'); 

peaks = zeros(nNeurons,size(df,2)); % Peak array 
dffilt = zeros(nNeurons,size(df,2));% Filtered data   
for i = nNeurons:-1:1 % For each neuron.
    %% Filtering
    dfFilt = sgolayfilt(df(i,:),filt(1),filt(2))'; % Filtering with Savitzky-Golay.
    THRESH = 1.5*std(dfFilt)+mean(dfFilt); % Threshold for peak detection. 
    %% Peak detection
    [~,LOCS] = findpeaks(dfFilt,'MinPeakHeight',THRESH,'MinPeakDistance',MIND,'MinPeakWidth',MINW); % Peak detection with optimized parameters.
    %% Peak detection if signal has low SNR
    if length(LOCS)> 100 % If the number of peaks is over 100 the trace is likely to be mostly noise. (This was tested by eye)
        THRESH = THRESH*3; % Peak threshold is increased. 
    end

    [~,LOCS] = findpeaks(dfFilt,'MinPeakHeight',THRESH,'MinPeakDistance',MIND,'MinPeakWidth',MINW); % Find peaks with increased threshold.
    %% If peaks are found
    if ~isempty(LOCS) 
        realLOCS = []; 
        dffilt(i,:) = dfFilt'; 
        for peakLOCS = 1:length(LOCS)
            realLOCS = [realLOCS find(df(i,:)==max(df(i,LOCS(peakLOCS)-200:LOCS(peakLOCS)+200)))]; % Finding position of the peaks in the unfiltered trace.
        end
        peaks(i,realLOCS)= 1; % One-hot encoding peak location matrix 

        %% Ploting peaks and traces.

        if st('plotPeaks')
            figure('Position', [100, 100, 600, 600]);
            hold on;

             p= plot(time,dfFilt); 
            
            % Plot peak location as dashed vertical lines
            for k = 1:length(LOCS)
                pk = xline(time(LOCS(k)), 'k--','LineWidth',1);
            end

            % Plot stimulus location as dashed vertical lines 
            for r = 1:length(tpuff)
                 stim = xline(tpuff(r), 'r--');
            end

            title(...
            strcat('\textbf{Neuron calcium trace number:}',num2str(i)), ...
            'Interpreter', 'latex', 'FontSize', 20);

            xlim([0 time(end)]);
            xlabel('\textbf{Time (s)}', 'Interpreter', 'latex', 'FontSize', 20);
            ylabel('\textbf{DF/F}', 'Interpreter', 'latex', 'FontSize', 20);
            legend([p pk stim],{'Neuron','Peaks','Stimulus'})
            set(gca, 'FontSize', 15, 'LineWidth', 1.5);
            set(gca, 'TickLabelInterpreter', 'latex');
            set(gcf, 'Color', 'w');  
            hold off;
        end
    else
        % If not peaks are found (likely very low SNR) the cell trace is deleted 
        st('nNeurons') = st('nNeurons')-1; % Number of neurons is decreased
        peaks(i,:) = []; 
        centroid_roi(:,i) = [];
        df(i,:) = []; 
        dffilt(i,:) = [];
    end
end
% Updating varaibles
st('dfFilt') = dffilt; st('peaks') = peaks;st('centroid_roi') = centroid_roi; st('dFshiftups') = df; 
end 