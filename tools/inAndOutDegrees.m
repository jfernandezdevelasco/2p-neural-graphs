function [st]=inAndOutDegrees(G,st)
%% inAndOutDegrees Function
% Computes the in-degree and out-degree of each neuron in a functional 
% connectivity graph. The in-degree represents the number of incoming 
% connections to a neuron, while the out-degree represents the number 
% of outgoing connections.
%
% Usage:
%   st = inAndOutDegrees(G);
%
% Inputs:
%   - G (graph object)     : A MATLAB graph object representing the functional 
%                             connectivity network of neurons.
%
% Outputs:
%   - st (containers.Map)  : A key-value data structure containing:
%       * 'degree_in'  : Vector of in-degrees for all neurons.
%       * 'degree_out' : Vector of out-degrees for all neurons.
%
% Processing Steps:
%   1. Extracts in-degree and out-degree values from the graph object `G`.
%   2. Stores the computed degrees in the `st` structure.
%
% Stored Information in 'st' (Updated):
%   - 'degree_in'  : In-degree of each neuron (number of incoming connections).
%   - 'degree_out' : Out-degree of each neuron (number of outgoing connections).
%
% Example:
%   st = inAndOutDegrees(G);
%
%   % Access computed degrees:
%   inDeg  = st('degree_in');
%   outDeg = st('degree_out');
%

st('degree_in') = indegree(G);
st('degree_out') = outdegree(G); 
end
