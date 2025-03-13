function[st] = neuralGraphNetworkMetrics(adj,st)
%% neuralGraphNetworkMetrics
% Computes and visualizes key network metrics from a functional connectivity 
% graph, including betweenness centrality and modularity. The function also 
% generates visualizations of these metrics overlaid on the network graph.
%
% Usage:
%   st = neuralGraphNetworkMetrics(adj, st);
%
% Inputs:
%   - adj (matrix)          : Adjacency matrix representing the connectivity between neurons.
%   - st (containers.Map)   : A key-value data structure containing:
%       * 'centroid_roi'    : 2D coordinates of neuron centroids for plotting.
%       * 'state'           : Experimental condition (e.g., 'Awake', 'Anesthetized').
%       * 'depth'           : Cortical depth of the recording.
%       * 'day', 'month'    : Recording date information.
%
% Outputs:
%   - st (containers.Map)  : Updated structure containing:
%       * 'graphCentrality' : Vector of betweenness centrality values.
%       * 'graphModularity' : Vector of modularity community assignments.
%
% Processing Steps:
%   1. Constructs a directed graph from the adjacency matrix.
%   2. Computes betweenness centrality using `betweenness_bin`.
%   3. Visualizes the graph with nodes color-coded by centrality.
%   4. Calculates modularity using `modularity_dir`.
%   5. Visualizes the graph with nodes color-coded by community structure.
%   6. Updates the `st` structure with calculated metrics.
%
% Example:
%   % Compute and visualize metrics
%   st = neuralGraphNetworkMetrics(adj, st);
%
% Notes:
%   - The graph visualizations highlight network topology with node size and 
%     color reflecting centrality or modularity values.
%   - The modularity resolution parameter (`gamma`) can be adjusted for 
%     different levels of community detection granularity.
%

% Un-packing variables 
centroid_roi = st('centroid_roi');
G = digraph(adj(1:end-1,1:end-1));
%% Centrailty
BC = betweenness_bin(adj(1:end-1,1:end-1)); % Betweenness centrality for each node
%% Plot centrality graph
fn = 20;
figure('Position', [100, 100, 800, 800]);
hold on;
p=plot(G,'XData',centroid_roi(1,1:end-1),'YData',centroid_roi(2,1:end-1));

p.NodeCData = BC;
p.MarkerSize = 5 + 10 * (BC / (max(BC)+1));
p.EdgeColor = 'k';                         
p.LineWidth = 2;          
p.ArrowSize = 7;
colormap jet
colorbar

title(strcat('\textbf{Functional Connectivity Graph showing Betweenness Centrality}'),'Interpreter', 'latex', 'FontSize', fn);   
tx = strcat('\textbf{State: }', st('state'),'\textbf{ Date: }', st('day'),'/',st('month'),'/','$20$','\textbf{ Cortical Depth: }', st('depth'));
annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
'String', tx, ...
'Interpreter', 'latex', ...
'FontSize', 20, ...
'EdgeColor', 'none', ...
'HorizontalAlignment', 'center');

xlim([0 512]);
ylim([0 512]);
xlabel('\textbf{X Position (pixels)}', 'Interpreter', 'latex', 'FontSize', fn);
ylabel('\textbf{Y Position (pixels)}', 'Interpreter', 'latex', 'FontSize', fn);
set(gca, 'YDir', 'reverse', 'FontSize', fn, 'LineWidth', 1.5);
set(gca, 'TickLabelInterpreter', 'latex');
set(gcf, 'Color', 'w');  
hold off;
%% Modularity ploting graph metrics
% Convert to adjacency matrix
adjMatrix = full(adjacency(G));
% Calculate modularity using BCT
gamma = 1; % Resolution parameter
[community, ~] = modularity_dir(adjMatrix, gamma);
%% Plot Modularity graph
figure('Position', [100, 100, 800, 800]);
hold on;
p=plot(G,'XData',centroid_roi(1,1:end-1),'YData',centroid_roi(2,1:end-1));

p.NodeCData = community;
p.MarkerSize = 5 + 10 * (community / max(community));
p.EdgeColor = 'k';         
p.LineWidth = 2;          
p.ArrowSize = 7;
colormap jet
colorbar

title(strcat('\textbf{Functional Connectivity Graph showing Modularity}'),'Interpreter', 'latex', 'FontSize', fn); 
tx = strcat('\textbf{State: }', st('state'),'\textbf{ Date: }', st('day'),'/',st('month'),'/','$20$','\textbf{ Cortical Depth: }', st('depth'));
annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
'String', tx, ...
'Interpreter', 'latex', ...
'FontSize', 20, ...
'EdgeColor', 'none', ...
'HorizontalAlignment', 'center');

xlim([0 512]);
ylim([0 512]);
xlabel('\textbf{X Position (pixels)}', 'Interpreter', 'latex', 'FontSize', fn);
ylabel('\textbf{Y Position (pixels)}', 'Interpreter', 'latex', 'FontSize', fn);
set(gca, 'YDir', 'reverse', 'FontSize', fn, 'LineWidth', 1.5);
set(gca, 'TickLabelInterpreter', 'latex');
set(gcf, 'Color', 'w');  
hold off;

st('graphCentrality') = BC; st('graphModularity') = community;
end