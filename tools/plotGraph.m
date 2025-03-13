function []=plotGraph(G,st)
%% plotGraph Function
% Plots a functionally connected neuronal graph. 
%
% Usage:
%   plotGraph(G, st);
%
% Inputs:
%   - G (graph object)     : A MATLAB graph object .
%   - st (containers.Map)  : A key-value data structure containing experimental 
%                             data, including neuron coordinates.
%
% Outputs:
%   - None (displays a figure).
%
% Example:
%   plotGraph(G, st);
%

% Unpacking variables 
centroid_roi = st('centroid_roi');
if numnodes(G) == st('nNeurons')
    %% Plot graph without stimulus node 
    figure('Position', [0, 0, 1000, 800]);
    hold on;
    
    % Display correlation image as background 
    imagesc(st('I_gray'));        
    axis square;
    cb = colorbar;
    ylabel(cb, '\textbf{Correlation between pixels across time}', ...
    'Interpreter', 'latex', 'FontSize', 20);  

    % Plot the functional connectivity graph
    p = plot(G, ...
        'XData', centroid_roi(1, 1:end-1), ...
        'YData', centroid_roi(2, 1:end-1));
    
    p.NodeColor = 'k';          % Set node color to black
    p.EdgeColor = 'w';          % Set edge color to white
    p.MarkerSize = 5;           % Increase marker size for nodes
    p.LineWidth = 4;            % Increase edge thickness        
    p.ArrowSize = 15;           % Increase arrow size 

    title(...
        strcat('\textbf{Functional Connectivity Graph}'), ...
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

    scale_length_pix = 68;      
    pixel_to_micron_ratio = 375/512;
    x_position = 20; y_position = 500;
    line([x_position, x_position + scale_length_pix], [y_position, y_position],...
        'Color', 'w', 'LineWidth', 3); 
    text(x_position + scale_length_pix/2, y_position - 10,...
        sprintf('%d µm', round(scale_length_pix * pixel_to_micron_ratio)),...
        'Color', 'w', 'FontSize', 12, 'HorizontalAlignment', 'center');

    set(gca, 'YDir', 'reverse', 'FontSize', 20, 'LineWidth', 1.5);
    set(gca, 'TickLabelInterpreter', 'latex');
    set(gcf, 'Color', 'w'); 
    
    hold off;
else 
    %% Plots graph with stimulus node 
    figure('Position', [0, 0, 1000, 800]);
    hold on;

    imagesc(st('I_gray'));        
    axis square;
    cb = colorbar;
    ylabel(cb, '\textbf{Correlation between pixels across time}', ...
    'Interpreter', 'latex', 'FontSize', 20); 

    p = plot(G, ...
        'XData', centroid_roi(1, 1:end), ...
        'YData', centroid_roi(2, 1:end));
    
    p.NodeColor = 'k';          % Set node color to black
    p.EdgeColor = 'w';          % Set edge color to white
    p.MarkerSize = 5;           % Increase marker size for nodes
    p.LineWidth = 4;            % Increase edge thickness        
    p.ArrowSize = 15;           % Increase arrow size 
    highlight(p, st('nNeurons')+1,'NodeColor','r');
    edgesFromStim = find(G.Edges.EndNodes(:,1) == st('nNeurons')+1 | G.Edges.EndNodes(:,2) == st('nNeurons')+1);
    highlight(p, 'Edges', edgesFromStim, 'EdgeColor', 'r');
    p.NodeLabel{st('nNeurons')+1} = 'Stimulus';

    title(...
        strcat('\textbf{Functional Connectivity Graph with Stimulus Node}'), ...
        'Interpreter', 'latex', 'FontSize', 18);
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
    
    scale_length_pix = 68;      
    pixel_to_micron_ratio = 375/512;
    x_position = 20; y_position = 500;
    line([x_position, x_position + scale_length_pix], [y_position, y_position],...
        'Color', 'w', 'LineWidth', 3); 
    text(x_position + scale_length_pix/2, y_position - 10,...
        sprintf('%d µm', round(scale_length_pix * pixel_to_micron_ratio)),...
        'Color', 'w', 'FontSize', 12, 'HorizontalAlignment', 'center');

    set(gca, 'YDir', 'reverse', 'FontSize', 20, 'LineWidth', 1.5);
    set(gca, 'TickLabelInterpreter', 'latex');
    set(gcf, 'Color', 'w'); 
    
    hold off;
end
