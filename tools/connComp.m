function [idx]=connComp(G,st)
%% connComp Function
% Identifies and extracts the largest connected component in a neural graph. 
% If a connected component exists, it is plotted for visualization.
%
% Usage:
%   idx = connComp(G, st);
%
% Inputs:
%   - G (graph object)     : A MATLAB graph object representing the functional 
%                             connectivity network of neurons.
%   - st (containers.Map)  : A key-value data structure containing experimental 
%                             data, including neuron coordinates for plotting.
%
% Outputs:
%   - idx (vector)         : Indices of neurons belonging to the largest 
%                             connected component.
%
% Processing Steps:
%   1. Computes the connected components of the graph `G`.
%   2. Identifies the largest connected component based on the number of nodes.
%   3. Extracts the indices of the neurons in the largest connected component.
%   4. Plots the subgraph of the largest connected component if it exists.
%
% Example:
%   idx = connComp(G, st);
%
%   % Access the largest connected component:
%   G_largest = subgraph(G, idx);
%   figure;
%   plot(G_largest);
%   title('Largest Connected Component of the Neural Graph');
%

% Unpacking variables 
nNeurons = st('nNeurons');centroid_roi = st('centroid_roi');
%% Connected components
[bin,binsize] = conncomp(G,'Type','weak');
% Dimension of largest connected component (Lcc)
lccDim = max(binsize);
% Proportion of Lcc
if lccDim == 1 ||  lccDim == 0
    idx = NaN;
    return 
else 
    idx = binsize(bin) == max(binsize); % The nodes in the largest connected component.
end 
%% Plot largest connected component
SG = subgraph(G,idx);
if st('plotLcc')
    figure('Position', [100, 100, 600, 600]);
    % Display correlation image as background 
    imagesc(st('I_gray'));  
    hold on 
    axis square;
    cb = colorbar;
    ylabel(cb, '\textbf{Correlation between pixels across time}', ...
    'Interpreter', 'latex', 'FontSize', 20);        
    % Plot the functional connectivity subgraph
    p = plot(SG,'XData',centroid_roi(1,idx==1),'YData',centroid_roi(2,idx==1));

    p.NodeColor = 'k';          % Set node color to black
    p.EdgeColor = 'w';          % Set edge color to white
    p.MarkerSize = 5;           % Increase marker size for nodes
    p.LineWidth = 4;            % Increase edge thickness        
    p.ArrowSize = 15;           % Increase arrow size 

    title(...
        strcat('\textbf{Largest Connected  Component Graph}'), ...
        'Interpreter', 'latex', 'FontSize', 20);
    tx = strcat('\textbf{State: }', st('state'),'\textbf{ Date: }', st('day'),'/',st('month'),'/','$20$','\textbf{ Cortical Depth: }', st('depth'));

    xlim([0 512]);
    ylim([0 512]);
    xlabel('\textbf{X Position (pixels)}', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('\textbf{Y Position (pixels)}', 'Interpreter', 'latex', 'FontSize', 20);
    annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
    'String', tx, ...
    'Interpreter', 'latex', ...
    'FontSize', 20, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');

    set(gca, 'YDir', 'reverse', 'FontSize', 20, 'LineWidth', 1.5);
    set(gca, 'TickLabelInterpreter', 'latex');
    set(gcf, 'Color', 'w');  
    hold off
end
end
