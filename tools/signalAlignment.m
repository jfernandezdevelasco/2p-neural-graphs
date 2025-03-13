function [st]=signalAlignment(st)
%% signalAlignment Function
% Aligns the calcium signals by upsampling them to analogFs (1000 Hz) 
% to match the sampling rate of the air-puff signal and the two-photon 
% microscope shutter signal. The function then aligns the calcium signals 
% with the two-photon shutter signal and the air-puff timing to ensure 
% precise temporal synchronization of neuronal activity with stimulus events.
%
% Usage:
%   st = signalAlignment(st);
%
% Inputs:
%   - st (containers.Map) : A key-value data structure containing experimental 
%                            data, including calcium signals and stimulus signals.
%
% Outputs:
%   - st (containers.Map) : The updated structure with aligned calcium signals.
%
% Processing Steps:
%   1. Upsamples the calcium fluorescence signal (`F_dff`) to analogFs (1000 Hz).
%   2. Aligns the upsampled calcium signal with the two-photon microscope 
%      shutter signal.
%   3. Ensures synchronization with the air-puff stimulus signal.
%
% Stored Information in 'st' (Updated):
%   - 'dFshiftups'  : The upsampled and aligned calcium signals.
%   - 'time'        : The new time vector at analogFs (1000 Hz).
%
% Example:
%   st = signalAlignment(st);
%
%   % Access aligned calcium signal
%   dFshiftups = st('dFshiftups');

% Unpacking variables
adc4 = st('adc4');adc5 = st('adc5'); %'adc4': Analog-to-digital airpuff signal. 'adc5': Analog-to-digital 2p shutter signal.
analogFs = st('analogFs');fs = st('fs'); % 'analogFs': Two photon shutter and air-puff signals sampleing rate. 'fs': calcium traces sampleing rate.
nNeurons = st('nNeurons');
%% Calcium signal shift and upsample.
ROI=st('F_dff')'; % Neuron calcium signals 

frames=(1:1:size(ROI,1))'; % Number of frames
timeCal=(0:1/analogFs:size(ROI,1)/fs)'; % Calcium signal time vector
time=(0:1/analogFs:((size(adc5,1)-1)/analogFs))'; % Time vector for upsampled calcium signal 

% Upsample
dFups=interp1(frames/fs,ROI,timeCal,'linear','extrap'); % Upsampled calcium signals

[~,locs] = findpeaks(adc5,'MinPeakHeigh',2.5,'MinPeakDistance',20); % Finding 2p image acquisition times
shift=locs(1);

dFshiftups=zeros(length(adc5),nNeurons); 
dFshiftups(shift :shift+size(dFups,1)-1,:) = dFups; dFshiftups = dFshiftups'; % Aligning calcium signals to airpuff times
% Stimulus detection 
[~,tpuff] = findpeaks(adc4,analogFs,'MinPeakDistance',5,'MinPeakHeight',3.5); % Find airpuff times
% Updating data
st('dFshiftups') = dFshiftups; st('time') = time; st("tpuff") = tpuff;
end