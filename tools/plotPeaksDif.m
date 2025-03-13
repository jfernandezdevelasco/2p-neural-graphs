function plotPeaksDif(lagsWithinStim,i,j,pks,ptt,st)
%% plotPeaksDif Function
% Plots the distribution of lags between functionally connected neuronal 
% traces and compares them to a uniform distribution. The function also plots the cell traces.
% The function uses statistical tests (Kolmogorov-Smirnov and t-test) to assess deviations from 
% uniformity and visualizes the results.
%
% Usage:
%   plotPeaksDif(lagsWithinStim, i, j, pks, ptt, st);
%
% Inputs:
%   - lagsWithinStim (vector)   : Lags between peak events of functionally 
%                                 connected neurons.
%   - i (integer)               : Index of the first neuron in the connection.
%   - j (integer)               : Index of the second neuron in the connection.
%   - pks (numeric)             : p-value from the Kolmogorov-Smirnov (KS) test 
%                                 for uniformity.
%   - ptt (numeric)             : p-value from the t-test.
%   - st (containers.Map)       : A key-value data structure containing experimental 
%                                 information, used for labeling and referencing data.
%
% Outputs:
%   - None (displays a figure).
%
% Processing Steps:
%   1. Computes and plots the histogram of `lagsWithinStim`, showing the distribution 
%      of lags between neuronal peaks.
%   2. Plots the cell traces that have an inffered connection.
%
% Example:
%   plotPeaksDif(lagsWithinStim, 5, 10, 0.03, 0.05, st);
%
%   % Interpretation:
%   % - If pks is small, the lag distribution significantly deviates from 
%   %   a uniform distribution.
%   % - If ptt is small, the mean of the distribution significantly differs 
%   %   from zero this means that one cells peaks are consistently before anothers.

% Unpacking variables 
df = st('dfFilt'); time = st('time'); tpuff = st('tpuff'); peaks = st('peaks'); 

% Establishing which cell "drives" the other.
if mean(lagsWithinStim) < 0
    dir = strcat(num2str(i), ' $\rightarrow$ ', num2str(j)); 
else
    dir = strcat(num2str(j), ' $\rightarrow$ ', num2str(i));
end

% Finding peak times for each cell. 
peakI = find(peaks(i, :) == 1); peakJ = find(peaks(j, :) == 1);

if st('plotDifPeaks')
    %% Plotting histogram of lags with uniform probability density function
    maxLag = st('maxLag');
    uniProbPDF = [-maxLag:maxLag; unifpdf(-maxLag:maxLag, -maxLag, maxLag)]'; % Uniform probability density function
    
    % Create the histogram 
    figure('Position', [0, 100, 2000, 1000]);
    % Plot histogram of lags
    bar = histogram(lagsWithinStim, -2:0.5:2, 'Normalization', 'pdf', ...
              'FaceColor', [0.3, 0.6, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    hold on;
    % Plot uniform pdf
    pdf = plot(uniProbPDF(:,1), uniProbPDF(:,2), 'r', 'LineWidth', 2);
    
    xlabel('\textbf{Lag Value (s)}', 'Interpreter', 'latex', 'FontSize', 15);
    ylabel('\textbf{Probability Density}', 'Interpreter', 'latex', 'FontSize', 15);
    title(strcat('\textbf{A Uniform PDF compared to a Normalized Histogram of Cells: }', ...
          num2str(i), '\textbf{ and }', num2str(j), ...
          '\textbf{ | KS test p-value: }', num2str(round(pks, 3,"decimals")), ...
          '\textbf{ | t test p-value: }', num2str(round(ptt, 3,"decimals"))), ...
          'Interpreter', 'latex', 'FontSize', 20);

    legend([bar,pdf],{'\textbf{Normalized Histogram}', '\textbf{Uniform PDF}'}, ...
           'Interpreter', 'latex', 'FontSize', 15, 'Location', 'northeast');
    set(gca, 'FontSize', 15, 'LineWidth', 1.5);
    set(gca, 'TickLabelInterpreter', 'latex');
    set(gcf, 'Color', 'w');  
    box on;
    grid on;
    xlim([-2, 2]);
    ylim([0, 2]);
    hold off;

    %% Plotting cell traces 
    figure('Position', [0, 100, 2000, 1000]);
    % Plots the cell: i
    plot(time, df(i, :), 'b', 'LineWidth', 1.2); 
    hold on;
    % Plots the cell: j 
    plot(time, 6 + df(j, :), 'k', 'LineWidth', 1.2); 

    % Plot peaks events for each cell
    for k = 1:length(peakJ)
        xline(time(peakJ(k)), 'k:', 'LineWidth', 0.7);
    end
    for q = 1:length(peakI)
        xline(time(peakI(q)), 'b:', 'LineWidth', 0.7);
    end

    xlabel('\textbf{Time (s)}', 'Interpreter', 'latex', 'FontSize', 15);
    ylabel('\boldmath$\Delta F/F$', 'Interpreter', 'latex', 'FontSize', 15);
    title(strcat('\boldmath$\Delta F/F$','\textbf{ of Cells: }', num2str(i), '\textbf{ and }', num2str(j), ...
          '\textbf{ | Direction: }', dir, '\textbf{ | KS test p-value: }', num2str(round(pks,3,"decimals")),'\textbf{ | t test p-value: }', num2str(round(ptt,3,"decimals"))), ...
          'Interpreter', 'latex', 'FontSize', 20);
    legend(strcat('\textbf{Cell: }', num2str(i)), strcat('\textbf{Cell: }', num2str(j)), ...
           'Interpreter', 'latex', 'FontSize', 15);

    xlim([0, time(end)]);
    set(gca, 'FontSize', 15, 'LineWidth', 1.5);
    set(gca, 'TickLabelInterpreter', 'latex');
    set(gcf, 'Color', 'w');  
    grid on;
    box on;
    hold off;
end