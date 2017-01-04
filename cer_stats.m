function cer_stats()
%CER_STATS Electricity consumption statistics assignmnet
%   Code submission by: Z0966990

%% Load the data from this directory.
% Convert data into totals for each customer.
data = load('CER_smartmeters.mat');

%% Preallocate variables for results.
est_mean = nan(3, 1);
est_std = nan(3, 1);
n = nan(3, 1);
ci90 = nan(3, 2);
ci95 = nan(3, 2);
n_out = nan(3, 1);

DAY200 = 1;
DAY1 = 2;
DAY1R = 3; % Day 1 Revised

% Compute totals for both days. Elminate consumption values of 0 as they
% suggest either meter is faulty or customer was not at home.
totals = {sum(data.day200_meter, 2), sum(data.day1_meter, 2)};
totals = cellfun(@(total)total(total>0), totals, 'UniformOutput', false);

%% Analyse means
d = [DAY200, DAY1];
n(d) = cellfun(@length, totals);
est_mean(d) = cellfun(@mean, totals);
est_std(d) = cellfun(@mean, totals);
ci90(d, :) = est_mean(d) + est_std(d)*norminv([0.05, 0.95])./sqrt(n(d));
ci95(d, :) = est_mean(d) + est_std(d)*norminv([0.025, 0.975])./sqrt(n(d));

%% Analyse outliers.
% Mask data for DAY1 below the upper limit in the 95% confidence interval.
m = totals{DAY1} <= ci95(DAY1, 2);
                        
% Compute 95% confidence interval for revised data.
n(DAY1R) = length(totals{DAY1}(m));
est_mean(DAY1R) = mean(totals{DAY1}(m));
est_std(DAY1R) = std(totals{DAY1}(m));
ci95(DAY1R, :) = est_mean(DAY1R) + ...
    est_std(DAY1R)*norminv([0.025, 0.975])./sqrt(n(DAY1R));

% Count number of outliers before and after masking.
m_out = ~(totals{DAY1} >= ci95(DAY1R, 1) & m);
n_out(DAY1) = sum(m_out);
mm_out = ~(totals{DAY1}(m) >= ci95(DAY1R, 1) &...
           totals{DAY1}(m) <= ci95(DAY1R, 2));
n_out(DAY1R) = sum(mm_out);

%% Plot Graphs
figure('OuterPosition', get(0, 'ScreenSize')*0.9);
plot_distrib(axes(), totals{DAY200}, 'Day 1 (Winter)');
figure('OuterPosition', get(0, 'ScreenSize')*0.9);
plot_distrib(axes(), totals{DAY1}, 'Day 200 (Summer)');
figure('OuterPosition', get(0, 'ScreenSize')*0.9);
plot_distrib(axes(), totals{DAY1}(m), 'Day 1 (Summer)---Revised');

%% Generate Table
disp(table(est_mean, ci90, ci95, n_out,...
    'RowNames', {'Winter', 'Summer', 'Summer Revised'}));

    function plot_distrib(ax, data, name)
    %%
    histogram(ax, data, 50);
    xlabel('Total Consumption', 'Interpreter', 'latex', 'FontSize', 34);
    ylabel('Frequency', 'Interpreter', 'latex', 'FontSize', 34);
    title(name, 'Interpreter', 'latex', 'FontSize', 36);
    ax.FontSize = 30;
    ax.TickLabelInterpreter = 'latex';
    end
end


