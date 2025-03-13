function []= plotMulti2pNetworkMetrics(data,degree)
%% Degree Distribution and Network Comparison Analysis
% This script analyzes the degree distributions of neurons in different
% states and compares key network properties.
%
% Processing Steps:
%   1. Calls `plotDegree` to visualize the degree distributions.
%   2. Performs statistical comparisons of network properties (neurons & edges).
%   3. Generates boxplots to compare awake vs. anesthetized conditions.
%
% Usage:
%   Run the script after loading `data`, `degree`, and `plotDegree.m`.
%
% Inputs:
%   - data (struct)          : Contains neuronal and edge count data for different states.
%       * data.nNeuron       : Map of neuron counts ('an' for anesthetized, 'aw' for awake).
%       * data.edge          : Map of edge counts ('an' for anesthetized, 'aw' for awake).
%   - degree (struct)        : Stores in-degree and out-degree values for each field.
%       * degree.in          : Map of in-degree distributions per recording.
%       * degree.out         : Map of out-degree distributions per recording.
%
% Outputs:
%   - Figures:
%       1. In-degree and out-degree distributions per recording depth.
%       2. Boxplot comparing neuron counts in anesthetized vs. awake states.
%       3. Boxplot comparing edge counts in anesthetized vs. awake states.
%   - Statistical results:
%       * Wilcoxon rank-sum test (p-values) comparing neuron and edge counts.
%
% Example:
%       plotMulti2pNetworkMetrics(data,degree)


% Multi experiment case
rt = containers.Map(); rt('plotDegree')= true; 

%% Ploting degree distribution
fields = data.nNeuron.keys; possibleStates = [];
for g = 1:length(fields)
    temp1 = fields{g};
    if length(temp1)~=sum(isletter(temp1))
        rt('degree_in') = degree.in(fields{g}) ;rt('degree_out') = degree.out(fields{g}); 
        rt('depth') = temp1(isstrprop(temp1, 'digit')); rt('state') = temp1(isletter(temp1));
        plotDegree(rt,true) % Multi experiment case
    else 
        possibleStates = [possibleStates fields{g} ' '];
    end
end

possibleStates = split(possibleStates, ' '); possibleStates(end) = []; % The possible states
%% Box plot 
fn = 15; % Size of font 
% Number of neurons in awake and anesthitized states
temp1 = data.nNeuron(possibleStates{1});temp2 = data.nNeuron(possibleStates{2});
dataNeuron = [[temp1(temp1~=0)' 0]' temp2(temp2~=0)]; 

% Number of edges in awake and anesthitized states 
temp1 = data.edge(possibleStates{1});temp2 = data.edge(possibleStates{2});
dataEdge = [[temp1' 0]' temp2]; 

% Statistical test
p_n = ranksum(dataNeuron(:,1),dataNeuron(:,2)); 
p_e = ranksum(dataEdge(:,1),dataEdge(:,2)); 
%% Box-plot
figure('Position', [100, 100, 600, 600]); 

% Subplot 1: Boxplot for number of neurons
subplot('Position', [0.1, 0.15, 0.33, 0.7]);  
boxplot(dataNeuron, 'Labels', {['\textbf{',possibleStates{1},'}'], ['\textbf{',possibleStates{2},'}']}, 'Whisker', 1.5);
hold on
ax1 = gca;
set(ax1, 'TickLabelInterpreter', 'latex', 'FontSize', fn, 'LineWidth', 2);
title('\textbf{Number of Neurons}', 'Interpreter', 'latex', 'FontSize', fn);
xlabel('\textbf{State}', 'Interpreter', 'latex', 'FontSize', fn);
ylabel('\textbf{Number of Neurons}', 'Interpreter', 'latex', 'FontSize', fn);

% Subplot 2: Boxplot for number of edges
subplot('Position', [0.55, 0.15, 0.33, 0.7]);  
boxplot(dataEdge, 'Labels', {['\textbf{',possibleStates{1},'}'], ['\textbf{',possibleStates{2},'}']}, 'Whisker', 1.5);

ax2 = gca;
set(ax2, 'TickLabelInterpreter', 'latex', 'FontSize', fn, 'LineWidth', 2);
title('\textbf{Number of Edges}', 'Interpreter', 'latex', 'FontSize',fn);
xlabel('\textbf{State}', 'Interpreter', 'latex', 'FontSize', fn);
ylabel('\textbf{Number of Edges}', 'Interpreter', 'latex', 'FontSize', fn);
hold off 
set(gcf, 'Color', 'w'); 