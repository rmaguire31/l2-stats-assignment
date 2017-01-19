function cer_stats()
%CER_STATS Electricity consumption statistics assignmnet
%   Code submission by: Z0966990

%% Preallocate variables for results.
n = nan(3, 1);
est_mean = nan(3, 1);
est_std = nan(3, 1);
ci90 = nan(3, 2);
ci95 = nan(3, 2);
n_out = nan(3, 1);

DAY200 = 1;
DAY1 = 2;
DAY1R = 3; % Day 1 Revised

%% Load the data from this directory.
data = load('CER_smartmeters.mat');
power{DAY200} = data.day200_meter'; % kW
power{DAY1} = data.day1_meter'; % kW

% Integrate half hourly power demand to find total energy consumption.
% Assume power consumption is constant over each half hour interval.
dt = 0.5; % h
energy = cellfun(@(P) sum(P)*dt, power, 'UniformOutput', false); % kWh

% Elminate consumption values of 0 as they suggest either meter is faulty
% or the consumer was not using the premises.
energy = cellfun(@(E) E(E > 0), energy, 'UniformOutput', false);

%% Analyse means
d = [DAY200, DAY1];
n(d) = cellfun(@length, energy(d));
est_mean(d) = cellfun(@mean, energy(d));
est_std(d) = cellfun(@std, energy(d));
ci90(d, :) = est_mean(d) + est_std(d)*norminv([0.05, 0.95])./sqrt(n(d));
ci95(d, :) = est_mean(d) + est_std(d)*norminv([0.025, 0.975])./sqrt(n(d));

%% Analyse outliers.
% Mask data for DAY1 below the upper limit in the 95% confidence interval.
m = energy{DAY1} <= ci95(DAY1, 2);
                        
% Compute 95% confidence interval for revised data.
n(DAY1R) = length(energy{DAY1}(m));
est_mean(DAY1R) = mean(energy{DAY1}(m));
est_std(DAY1R) = std(energy{DAY1}(m));
ci95(DAY1R, :) = est_mean(DAY1R) + ...
    est_std(DAY1R)*norminv([0.025, 0.975])./sqrt(n(DAY1R));

% Count number of outliers before and after masking.
m_out = ~(energy{DAY1} >= ci95(DAY1R, 1) & m);
n_out(DAY1) = sum(m_out);
mm_out = ~(energy{DAY1}(m) >= ci95(DAY1R, 1) &...
           energy{DAY1}(m) <= ci95(DAY1R, 2));
n_out(DAY1R) = sum(mm_out);

%% Plot Graphs
figure();
plot_distrib(axes(), energy{DAY200}, 'Day 200 (Winter)');
figure();
plot_distrib(axes(), energy{DAY1}, 'Day 1 (Summer)');
figure();
plot_distrib(axes(), energy{DAY1}(m), 'Day 1 (Summer)---Revised');

%% Generate Table
disp(table(est_mean, ci90, ci95, n_out,...
    'RowNames', {'Winter', 'Summer', 'Summer Revised'}));

    function plot_distrib(ax, data, name)
    %%
    histogram(ax, data, 50);
    xlabel('Total Consumption / kWh');
    ylabel('Frequency');
    title(name);
    end
end
