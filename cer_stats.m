function cer_stats()
%CER_STATS Electricity consumption statistics assignmnet
%   Code submission by: Z0966990


%% Load the data from this directory
data = load('CER_smartmeters.mat');
day1 = struct();
day200 = struct();
day1.meter = data.day1_meter;
day200.meter = data.day200_meter;
clear('data');

% Analyse each day.
day1 = analyse(day1);
day200 = analyse(day200);
[day1, day1central95] = remove_outliers_and_analyse(day1);

%% Plot Graphs
figure();
plot_distrib(axes(), day1.totals, 'Day 1 (Summer)');
figure();
plot_distrib(axes(), day200.totals, 'Day 200 (Winter)');
figure();
plot_distrib(axes(), day1central95.totals, 'Day 1 (Summer) - Central 95\%');

%% Generate Tables
mean       = [day1.mean;          day200.mean];
ci90_lower = [day1.ci90limits(1); day200.ci90limits(1)];
ci90_upper = [day1.ci90limits(2); day200.ci90limits(2)];
ci95_lower = [day1.ci95limits(1); day200.ci95limits(1)];
ci95_upper = [day1.ci95limits(2); day200.ci95limits(2)];
disp(table(mean, ci90_lower, ci90_upper, ci95_lower, ci95_upper,...
    'RowNames', {'Summer', 'Winter'}));

ci95_lower   = [day1.ci95limits(1); day1central95.ci95limits(1)];
mean         = [day1.mean;          day1central95.mean];
ci95_upper   = [day1.ci95limits(2); day1central95.ci95limits(2)];
num_outliers = [day1.n95;           day1central95.n95];
disp(table(mean, ci95_lower, ci95_upper, num_outliers,...
    'RowNames', {'100%', '95%'}));
end

function data = analyse(data)
%%

% Calculate daily total for each customer.
data.totals = sum(data.meter, 2);

% Confidence intervals.
data.mean = mean(data.totals);
data.std = std(data.totals);
z_95 = norminv(0.95);
data.ci90limits = data.mean + [-z_95, z_95]*data.std;
z_975 = norminv(0.975);
data.ci95limits = data.mean + [-z_975, z_975]*data.std;
end

function [data, new_data] = remove_outliers_and_analyse(data)
%%

% Remove outliers.
new_data = struct();
new_data.totals = data.totals(data.totals <= data.ci95limits(2));

% Confidence intervals.
new_data.mean = mean(new_data.totals);
new_data.std = std(new_data.totals);
z_975 = norminv(0.975);
new_data.ci95limits = new_data.mean + [-z_975, z_975]*new_data.std;

% Count outliers.
data.n95 = sum((data.totals < data.ci95limits(1)) |...
               (data.totals > data.ci95limits(2)));
new_data.n95 = sum((new_data.totals < new_data.ci95limits(1)) |...
                   (new_data.totals > new_data.ci95limits(2)));
end

function plot_distrib(ax, data, titletxt)
%%
histogram(ax, data, 50);
xlabel('Total Consumption', 'Interpreter', 'latex', 'FontSize', 34);
ylabel('Frequency', 'Interpreter', 'latex', 'FontSize', 34);
title(titletxt, 'Interpreter', 'latex', 'FontSize', 36);
ax.FontSize = 30;
ax.TickLabelInterpreter = 'latex';
end

