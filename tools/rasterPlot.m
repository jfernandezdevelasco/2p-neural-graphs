function rasterPlot(st)
%% rasterPlot Function
% Generates a raster plot to visualize neuronal peak activity over time. 
% Each row represents a neuron, and each bar corresponds to a peak event.
%
% Usage:
%   rasterPlot(st);
%
% Inputs:
%   - st (containers.Map) : A key-value data structure containing:
%       * 'peaks'         : Cell array where each entry contains peak timestamps for a neuron.
%       * 'state'         : String indicating the experimental condition (e.g., 'Awake' or 'Anesthetized').
%       * 'depth'         : String representing the cortical depth of the recording.
%       * 'day', 'month'  : Strings specifying the recording date.
%
% Outputs:
%   - A raster plot displaying calcium peak events for each neuron over time.
%
% Processing Steps:
%   1. Extracts peak time data from the `st` structure.
%   2. Plots peak times as bars in a raster format.
%
% Example:
%   % Generate the raster plot:
%   rasterPlot(st);
%

% Unpacking variables
nNeurons = st('nNeurons'); time = st('time'); tpuff = st('tpuff'); peaks = st('peaks');
%% Create rasterplot figure 
figure('Position', [200, 200, 1000, 700]);
hold on;

tx = strcat('\textbf{State: }', st('state'),'\textbf{ Date: }', st('day'),'/',st('month'),'/','$20$','\textbf{ Cortical Depth: }', st('depth'));
% Plot peaks for each neuron as vertical black lines
for neuron = 1:nNeurons
    spike_times = find(peaks(neuron, :) == 1);  % Extract peak times
    for t = spike_times
        bar = plot([time(t), time(t)], [neuron - 0.4, neuron + 0.4], 'k', 'LineWidth', 1); 
    end
end
annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
    'String', tx, ...
    'Interpreter', 'latex', ...
    'FontSize', 15, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center');
% Mark air-puff times with red dashed vertical lines
for i = 1:length(tpuff)
    xl = xline(tpuff(i), 'r:', 'LineWidth', 1);
end

title(strcat('\textbf{Raster Plot of Detected Events.}'), ...
    'Interpreter', 'latex', 'FontSize', 30);


xlabel('\textbf{Time (s)}', 'Interpreter', 'latex', 'FontSize', 15);
ylabel('\textbf{Neuron Index}', 'Interpreter', 'latex', 'FontSize', 15);

xlim([0, time(end)]);
ylim([0.5, nNeurons + 0.5]);

legend([xl,bar],{'\textbf{Stimulus (red dashed line)}', '\textbf{Spike events (black bars)}'}, ...
    'Interpreter', 'latex', 'FontSize', 15, 'Location', 'northeast');
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 15, 'LineWidth', 1.5);
set(gcf, 'Color', 'w');  
grid on;  
hold off;

