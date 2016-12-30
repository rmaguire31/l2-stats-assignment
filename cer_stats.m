function cer_stats()
%CER_STATS Electricity consumption statistics assignmnet
%   Code submission by: Z0966990

%% Load the data from this directory.
% Convert data into totals for each customer.
data = load('CER_smartmeters.mat');

%% Preallocate variables for results.
est_mean = nan(3, 1);
est_std = nan(3, 1);
ci90 = nan(3, 2);
ci95 = nan(3, 2);
n_out = nan(3, 1);

DAY1 = 1;
DAY200 = 2;
MDAY1 = 3;

% Compute totals for both days. Leave last column blank for outlier data.
totals = [sum(data.day1_meter, 2), sum(data.day200_meter, 2)];

%% Analyse means
d = [DAY1, DAY200];
est_mean(d) = mean(totals);
est_std(d) = std(totals);
ci90(d, :) = est_mean(d) + est_std(d)*norminv([0.05, 0.95]);
ci95(d, :) = est_mean(d) + est_std(d)*norminv([0.025, 0.975]);

%% Analyse outliers.
% Mask central 95% of data for DAY1.
m = totals(:, DAY1) >= ci95(DAY1, 1) & totals(:, DAY1) <= ci95(DAY1, 2);
                        
% Compute 95% confidence interval for masked data.
est_mean(MDAY1) = mean(totals(m, DAY1));
est_std(MDAY1) = std(totals(m, DAY1));
ci95(MDAY1, :) = est_mean(MDAY1) + norminv([0.025; 0.975])*est_std(MDAY1);

% Count number of outliers before and after masking.
n_out(DAY1) = sum(~m);
mm = totals(m, DAY1) >= ci95(MDAY1, 1) & totals(m, DAY1) <= ci95(MDAY1, 2);
n_out(MDAY1) = sum(~mm);

%% Plot Graphs
get(0, 'ScreenSize')
figure('OuterPosition', get(0, 'ScreenSize')*0.9);
plot_distrib(axes(), totals(:, DAY1), 'Day 1 (Summer)');
figure('OuterPosition', get(0, 'ScreenSize')*0.9);
plot_distrib(axes(), totals(:, DAY200), 'Day 200 (Winter)');
figure('OuterPosition', get(0, 'ScreenSize')*0.9);
plot_distrib(axes(), totals(m, DAY1), 'Day 200 (Summer) -- Central 95\%');

%% Generate Table
% Rename confidence interval variables.
ci90_1 = ci90(:, 1);
ci90_2 = ci90(:, 2);
ci95_1 = ci95(:, 1);
ci95_2 = ci95(:, 2);
disp(table(est_mean, ci90_1, ci90_2, ci95_1, ci95_2, n_out,...
    'RowNames', {'Summer', 'Winter', 'Summer 95%'}));

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


