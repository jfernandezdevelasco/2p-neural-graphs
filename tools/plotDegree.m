function [] = plotDegree(st,multi)
%% plotDegree Function
% Visualizes the in-degree and out-degree distributions of a functional 
% connectivity graph. The function generates histograms and fits a power-law 
% model to the degree distributions, displaying both linear and log-log plots.
%
% Usage:
%   plotDegree(st, multi);
%
% Inputs:
%   - st (containers.Map)   : A key-value data structure containing:
%       * 'degree_in'       : Vector of in-degrees for all neurons.
%       * 'degree_out'      : Vector of out-degrees for all neurons.
%       * 'plotDegree'      : Boolean flag indicating whether to generate plots.
%       * 'state'           : Experiment state (e.g., awake, anesthetized).
%       * 'day', 'month'    : Date of the experiment.
%       * 'depth'           : Cortical depth of the recording.
%   - multi (logical)       : If true, the function labels the plots as part 
%                           of a multi-experiment comparison.
%
% Outputs:
%   - None (generates and displays plots).
%
% Processing Steps:
%   1. Extracts in-degree and out-degree values from `st`.
%   2. Generates histograms of the in-degree and out-degree distributions.
%   3. Computes and fits a power-law model to both distributions.
%   4. Plots the fitted power-law model on linear and log-log scales.
%
% Example:
%   plotDegree(st, false);
%
% Figures:
%   1. Histogram of in-degree and out-degree distributions.
%   2. In-degree distribution: histogram, power-law fit, and log-log plot.
%   3. Out-degree distribution: histogram, power-law fit, and log-log plot.

% Unpacking variables
degree_in = st('degree_in'); degree_out = st('degree_out'); 
if length(unique(degree_in))>2 && length(unique(degree_out))>2
    if st('plotDegree')
        %% Plot histogram 
        figure('Position', [100, 100, 600, 600], 'Color', 'w'); 
        hold on;
        
        % Subplot for in-degree histogram
        subplot(2, 1, 1);
        histogram(degree_in, 'Normalization', 'probability', ...
                  'NumBins', 10, 'BinEdges', -0.5:1:max(degree_in)+5.5, ...
                  'FaceColor', 'k', 'EdgeColor', 'w', 'LineWidth', 1.5);
        title(strcat('\textbf{In-degree Distribution}'), ...
                    'Interpreter', 'latex', 'FontSize', 16);
        xlabel('\textbf{In-degree}', 'Interpreter', 'latex', 'FontSize', 14);
        ylabel('\textbf{Frequency}', 'Interpreter', 'latex', 'FontSize', 14);
        set(gca, 'FontSize', 14, 'LineWidth', 1.5, 'TickLabelInterpreter', 'latex');
        box off;
        
        % Subplot for out-degree histogram
        subplot(2, 1, 2);
        histogram(degree_out, 'Normalization', 'probability', ...
                  'NumBins', 10, 'BinEdges', -0.5:1:max(degree_out)+5.5, ...
                  'FaceColor', 'k', 'EdgeColor', 'w', 'LineWidth', 1.5);
        title('\textbf{Out-degree Distribution}', 'Interpreter', 'latex', 'FontSize', 16);
        xlabel('\textbf{Out-degree}', 'Interpreter', 'latex', 'FontSize', 14);
        ylabel('\textbf{Frequency}', 'Interpreter', 'latex', 'FontSize', 14);
        set(gca, 'FontSize', 14, 'LineWidth', 1.5, 'TickLabelInterpreter', 'latex');
        box off;
        if ~multi % If considering multi-experiment
            tx = strcat('\textbf{State: }', st('state'),'\textbf{ Date: }', st('day'),'/',st('month'),'/','$20$','\textbf{ Cortical depth: }', st('depth'));
        else
            tx = strcat('\textbf{Multi experiment}','\textbf{ -State: }', st('state'),'\textbf{ -Cortical depth: }', st('depth'));
        end
        annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
        'String', tx, ...
        'Interpreter', 'latex', ...
        'FontSize', 15, ...
        'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
    
        hold off;
        %% In-degree distribution
        if length(unique(degree_in))>3 && length(unique(degree_out))>3
            %% Compute in-degree distribution
            tbl = tabulate(degree_in);
            t_in = array2table(tbl, 'VariableNames', {'Value', 'Count', 'Percent'});
            t_in(1, :) = []; % Remove zero-degree entries
            
            % Fit power law
            f_in = fit(t_in.Value, t_in.Percent / 100, 'power1'); 
            b_in = f_in.b;
            x_plot = linspace(min(t_in.Value), max(t_in.Value), 100); % 100 points in the valid range
    
            %% In-degree 
            figure('Position', [100, 100, 900, 600], 'Color', 'w');
            
            % Subplot 1: Histogram of in-degree
            subplot(1, 3, 1);
            bar(t_in.Value, t_in.Percent / 100, 'FaceColor', 'k', 'EdgeColor', 'w', 'LineWidth', 1.5);
            title(strcat('\textbf{In-degree Distribution }'), ...
                  'Interpreter', 'latex', 'FontSize', 16);
            ylabel('\textbf{Frequency}', 'Interpreter', 'latex', 'FontSize', 14);
            xlabel('\textbf{In-degree}', 'Interpreter', 'latex', 'FontSize', 14);
            set(gca, 'FontSize', 14, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.5);
            box off;
            
            % Subplot 2: Power-law fit
            subplot(1, 3, 2);
            p1= plot(t_in.Value, t_in.Percent / 100, '*k', 'MarkerSize', 8); 
            hold on;
            f1 = plot(f_in, x_plot, f_in(x_plot));
            hold off;
            ylim([0, 1]);
            xlim([1, t_in.Value(end)]);
            title('\textbf{Power-law Fit:} $f(x) = ax^b$', 'Interpreter', 'latex', 'FontSize', 16);
            ylabel('\textbf{Frequency}', 'Interpreter', 'latex', 'FontSize', 14);
            xlabel('\textbf{In-degree}', 'Interpreter', 'latex', 'FontSize', 14);
            legend({'\textbf{Data}', '\textbf{Fitted curve}'},'Interpreter', 'latex', 'FontSize', 14, 'Location', 'northeast');
            set(gca, 'FontSize', 14, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.5);
            grid on;
            box off;
            
            % Subplot 3: Log-log power-law fit
            subplot(1, 3, 3);
            plot(t_in.Value, t_in.Percent / 100, '*k', 'MarkerSize', 8); hold on;
            plot(f_in, x_plot, f_in(x_plot));
            ylim([0, 1]);
            xlim([1, t_in.Value(end)]);
            title('\textbf{Log-Log Power-law Fit:} $f(x) = ax^b$', 'Interpreter', 'latex', 'FontSize', 16);
            ylabel('\textbf{Log(Frequency)}', 'Interpreter', 'latex', 'FontSize', 14);
            xlabel('\textbf{Log(In-degree)}', 'Interpreter', 'latex', 'FontSize', 14);
            legend({'\textbf{Data}', '\textbf{Fitted curve}'},'Interpreter', 'latex', 'FontSize', 14, 'Location', 'northeast');
            if ~multi % If considering multi-experiment
                tx = strcat('\textbf{State: }', st('state'),'\textbf{ Date: }', st('day'),'/',st('month'),'/','$20$','\textbf{ Cortical depth: }', st('depth'));
            else
                tx = strcat('\textbf{Multi experiment}','\textbf{ -State: }', st('state'),'\textbf{ -Cortical depth: }', st('depth'));
            end        
            annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
            'String', tx, ...
            'Interpreter', 'latex', ...
            'FontSize', 15, ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
            set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 14, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.5);
            grid on;
            box off;
            hold off;
            
            %% Out-degree 
            tbl = tabulate(degree_out);
            t_out = array2table(tbl, 'VariableNames', {'Value', 'Count', 'Percent'});
            t_out(1, :) = []; % Remove zero-degree entries
            
            % Fit power law
            f_out = fit(t_out.Value(t_out.Value>0), t_out.Percent / 100, 'power1'); 
            b_out = f_out.b;
            x_plot = linspace(min(t_out.Value), max(t_out.Value), 100); % 100 points in the valid range
    
            
            figure('Position', [100, 100, 900, 600], 'Color', 'w');
            
            % Subplot 1: Histogram of out-degree
            subplot(1, 3, 1);
            bar(t_out.Value, t_out.Percent / 100, 'FaceColor', 'k', 'EdgeColor', 'w', 'LineWidth', 1.5);
            title(strcat('\textbf{Out-degree Distribution}'), ...
                  'Interpreter', 'latex', 'FontSize', 16);
            ylabel('\textbf{Frequency}', 'Interpreter', 'latex', 'FontSize', 14);
            xlabel('\textbf{Out-degree}', 'Interpreter', 'latex', 'FontSize', 14);
            set(gca, 'FontSize', 14, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.5);
            box off;
            
            % Subplot 2: Power-law fit
            subplot(1, 3, 2);
            plot(t_out.Value, t_out.Percent / 100, '*k', 'MarkerSize', 8); 
            hold on;
            plot(f_out, x_plot, f_out(x_plot));
            hold off;
            ylim([0, 1]);
            xlim([1, t_out.Value(end)]);
            xlim([1 t_out.Value(end)])
            title('\textbf{Power-law Fit:} $f(x) = ax^b$', 'Interpreter', 'latex', 'FontSize', 16);
            ylabel('\textbf{Frequency}', 'Interpreter', 'latex', 'FontSize', 14);
            xlabel('\textbf{Out-degree}', 'Interpreter', 'latex', 'FontSize', 14);
            legend({'\textbf{Data}', '\textbf{Fitted curve}'},'Interpreter', 'latex', 'FontSize', 14, 'Location', 'northeast');
            set(gca, 'FontSize', 14, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.5);
            grid on;
            box off;
            
            % Subplot 3: Log-log power-law fit
            subplot(1, 3, 3);
            plot(t_out.Value, t_out.Percent / 100, '*k', 'MarkerSize', 8); 
            hold on;
            plot(f_out, x_plot, f_out(x_plot));
            ylim([0, 1]);
            xlim([1, t_out.Value(end)]);
            title('\textbf{Log-Log Power-law Fit:} $f(x) = ax^b$', 'Interpreter', 'latex', 'FontSize', 16);
            ylabel('\textbf{Log(Frequency)}', 'Interpreter', 'latex', 'FontSize', 14);
            xlabel('\textbf{Log(Out-degree)}', 'Interpreter', 'latex', 'FontSize', 14);
            legend({'\textbf{Data}', '\textbf{Fitted curve}'},'Interpreter', 'latex', 'FontSize', 14, 'Location', 'northeast');
            if ~multi % If considering multi-experiment
                tx = strcat('\textbf{State: }', st('state'),'\textbf{ Date: }', st('day'),'/',st('month'),'/','$20$','\textbf{ Cortical depth: }', st('depth'));
            else
                tx = strcat('\textbf{Multi experiment}','\textbf{ -State: }', st('state'),'\textbf{ -Cortical depth: }', st('depth'));
            end        
            annotation('textbox', [0.1, 0.0, 0.8, 0.05], ...
            'String', tx, ...
            'Interpreter', 'latex', ...
            'FontSize', 15, ...
            'EdgeColor', 'none', ...
            'HorizontalAlignment', 'center');
            set(gca, 'YScale', 'log', 'XScale', 'log', 'FontSize', 14, 'TickLabelInterpreter', 'latex', 'LineWidth', 1.5);
            grid on;
            box off;
            hold off;
        end
    end
end
end
