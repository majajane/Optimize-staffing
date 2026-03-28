% LIBRARY STAFFING ANALYSIS
clear; clc; close all;

%% load and process data
folder = 'C:\Users\Maja\Downloads\MM\'; 
sept_file = [folder 'SEPT.csv']; 
nov_file = [folder 'NOV.csv'];

areas = {'Ground Floor', 'Ipad Area', 'Relaxation Room', ...
         'Individual Study Room', 'Laptop Area', 'Smart Device  Zone'};

sept_raw = readtable(sept_file, 'VariableNamingRule', 'preserve');
nov_raw = readtable(nov_file, 'VariableNamingRule', 'preserve');

%% get time-in only
time_out_sept = find(contains(sept_raw{:,1}, 'TIME-OUT'), 1);
if ~isempty(time_out_sept)
    sept_timein = sept_raw(1:time_out_sept-1, :);
else
    sept_timein = sept_raw;
end

time_out_nov = find(contains(nov_raw{:,1}, 'TIME-OUT'), 1);
if ~isempty(time_out_nov)
    nov_timein = nov_raw(1:time_out_nov-1, :);
else
    nov_timein = nov_raw;
end

%% extract dates and area rows
sept_date_rows = find(contains(sept_timein{:,1}, 'September'));
sept_dates_list = [];
sept_data = [];

for d = 1:length(sept_date_rows)
    date_row = sept_date_rows(d);
    start_row = date_row + 2;
    end_row = start_row + 5;
    
    if end_row <= size(sept_timein, 1)
        date_str = sept_timein{date_row, 1};
        date_num = extractBetween(date_str, 'September ', ',');
        if ~isempty(date_num)
            sept_dates_list = [sept_dates_list; str2double(date_num{1})];
            data_block = sept_timein{start_row:end_row, 2:13};
            if istable(data_block)
                data_block = table2array(data_block);
            end
            data_block(isnan(data_block)) = 0;
            sept_data = [sept_data; data_block];
        end
    end
end

nov_date_rows = find(contains(nov_timein{:,1}, 'November'));
nov_dates_list = [];
nov_data = [];

for d = 1:length(nov_date_rows)
    date_row = nov_date_rows(d);
    start_row = date_row + 2;
    end_row = start_row + 5;
    
    if end_row <= size(nov_timein, 1)
        date_str = nov_timein{date_row, 1};
        date_num = extractBetween(date_str, 'November ', ',');
        if ~isempty(date_num)
            nov_dates_list = [nov_dates_list; str2double(date_num{1})];
            data_block = nov_timein{start_row:end_row, 2:13};
            if istable(data_block)
                data_block = table2array(data_block);
            end
            data_block(isnan(data_block)) = 0;
            nov_data = [nov_data; data_block];
        end
    end
end

days_sept = length(sept_dates_list);
days_nov = length(nov_dates_list);


%% reshape to [days, areas, hours]
sept_3d = reshape(sept_data, [6, days_sept, 12]);
sept_3d = permute(sept_3d, [2, 1, 3]);

nov_3d = reshape(nov_data, [6, days_nov, 12]);
nov_3d = permute(nov_3d, [2, 1, 3]);

% total occupancy per hour
sept_hourly = squeeze(sum(sept_3d, 2));
nov_hourly = squeeze(sum(nov_3d, 2));

% create dates
sept_dates = datetime(2025, 9, sept_dates_list)';
nov_dates = datetime(2025, 11, nov_dates_list)';

hours = 7:18;
hour_labels = {'7:00','8:00','9:00','10:00','11:00','12:00',...
               '13:00','14:00','15:00','16:00','17:00','18:00'};

hour_ranges = {'7:00-8:00', '8:00-9:00', '9:00-10:00', '10:00-11:00', ...
               '11:00-12:00', '12:00-13:00', '13:00-14:00', '14:00-15:00', ...
               '15:00-16:00', '16:00-17:00', '17:00-18:00', '18:00-19:00'};

%% [FIG1] Daily Totals
figure(1);
sept_daily = sum(sept_hourly, 2); % total daily occupancy for sept
nov_daily = sum(nov_hourly, 2); % total daily occupancy for nov

subplot(2,1,1);
plot(1:days_sept, sept_daily, 'm-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('Date'); ylabel('Daily Occupancy');
title('September Daily Occupancy'); grid on; xlim([0.5, days_sept + 0.5]);

sept_date_strings = cell(1, days_sept);
for i = 1:days_sept
    sept_date_strings{i} = datestr(sept_dates(i), 'mm/dd');
end
set(gca, 'XTick', 1:days_sept, 'XTickLabel', sept_date_strings);
xtickangle(45);

subplot(2,1,2);
plot(1:days_nov, nov_daily, 'g-s', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('Date'); ylabel('Daily Occupancy');
title('November Daily Occupancy'); grid on; xlim([0.5, days_nov + 0.5]);

nov_date_strings = cell(1, days_nov);
for i = 1:days_nov
    nov_date_strings{i} = datestr(nov_dates(i), 'mm/dd');
end
set(gca, 'XTick', 1:days_nov, 'XTickLabel', nov_date_strings);
xtickangle(45);

%% [FIG2] Average Hourly Pattern + Moving Average
figure(2);
sept_avg = mean(sept_hourly, 1); % average occupancy per hour for sept
nov_avg = mean(nov_hourly, 1); % average occupancy per hour for nov

k = 3; % moving average window size (3 hours)
MA_sept = zeros(size(sept_avg)); % initialize moving average array
for i = 1:12 % loop through each hour
    start_idx = max(1, i-k+1);  %start index for moving average
    MA_sept(i) = mean(sept_avg(start_idx:i)); % get moving average
end

plot(hours, sept_avg, 'm-o', 'LineWidth', 1.5);
hold on;
plot(hours, nov_avg, 'g-s', 'LineWidth', 1.5);
plot(hours, MA_sept, 'r--', 'LineWidth', 1.5);
xlabel('Hour'); ylabel('Average Occupancy');
title('Average Hourly Occupancy Pattern');
legend('September', 'November', 'Moving Avg (Sept)', 'Location', 'best');
grid on; xticks(hours); xticklabels(hour_labels);

%% [FIG3] Rate of Change
figure(3);
delta_sept = diff([0, sept_avg]); % rate of change for sept
delta_nov = diff([0, nov_avg]); % rate of change for nov

subplot(2,1,1);
bar(hours, delta_sept, 'm');
xlabel('Hour'); ylabel('Change in Occupancy');
title('September: Rate of Change \Delta N_t');
grid on; xticks(hours); xticklabels(hour_labels);
yline(0, 'k--'); % horizontal line at zero

subplot(2,1,2);
bar(hours, delta_nov, 'g');
xlabel('Hour'); ylabel('Change in Occupancy');
title('November: Rate of Change \Delta N_t');
grid on; xticks(hours); xticklabels(hour_labels);
yline(0, 'k--'); % horizontal line at zero

%% [FIG4] Heatmaps
figure(4);
subplot(1,2,1);
imagesc(sept_hourly'); % heatmap of sept hourly occupancy
colormap('hot'); colorbar;
xlabel('Date'); ylabel('Hour');
title('September Hourly Occupancy');
set(gca, 'YTick', 1:12, 'YTickLabel', hour_labels);
set(gca, 'XTick', 1:days_sept, 'XTickLabel', sept_date_strings);
xtickangle(45);

subplot(1,2,2);
imagesc(nov_hourly'); % heatmap of nov hourly occupancy
colormap('hot'); colorbar;
xlabel('Date'); ylabel('Hour');
title('November Hourly Occupancy');
set(gca, 'YTick', 1:12, 'YTickLabel', hour_labels);
set(gca, 'XTick', 1:days_nov, 'XTickLabel', nov_date_strings);
xtickangle(45);

%% STAFFING REQUIREMENTS (based on actual floors)
staff_required = zeros(5, 12);
for hour = 1:12
    if hour <= 2
        staff_required(1, hour) = 2;
        staff_required(2, hour) = 1;
        staff_required(3, hour) = 1;
        staff_required(4, hour) = 1;
        staff_required(5, hour) = 2;
    elseif hour >= 10
        staff_required(1, hour) = 2;
        staff_required(2, hour) = 1;
        staff_required(3, hour) = 1;
        staff_required(4, hour) = 1;
        staff_required(5, hour) = 2;
    else
        staff_required(1, hour) = 4;
        staff_required(2, hour) = 1;
        staff_required(3, hour) = 2;
        staff_required(4, hour) = 1;
        staff_required(5, hour) = 3;
    end
end

required_total = sum(staff_required, 1); % sum all floors = total staff required per hour
 
%% CURRENT STAFF (sched-based)
ground_staff = [3, 4, 5, 6, 6, 6, 6, 6, 6, 3, 2, 1];
floor2_staff = [1, 2, 3, 3, 3, 3, 3, 3, 3, 2, 1, 0];
floor3_staff = [1, 2, 3, 3, 3, 3, 3, 3, 3, 2, 1, 0];
floor4_staff = [1, 2, 3, 3, 3, 3, 3, 3, 3, 2, 1, 0];
floor6_staff = [1, 3, 3, 3, 3, 3, 3, 3, 3, 2, 0, 0];

current_total = ground_staff + floor2_staff + floor3_staff + floor4_staff + floor6_staff; % total current staff

shortage = max(0, required_total - current_total);
excess = max(0, current_total - required_total);

% LP
f = ones(1, 12);
A = -eye(12);
b = -required_total';
lb = zeros(1, 12);
options = optimoptions('linprog', 'Display', 'off');
[optimal_staff, ~, exitflag] = linprog(f, A, b, [], [], lb, [], options);

if exitflag == 1
    optimal_staff = ceil(optimal_staff);
else
    optimal_staff = required_total;
end

%% [FIG5] Staffing Comparison
figure(5); 
bar(hours, required_total, 'FaceColor', [0.5, 0, 0.5], 'EdgeColor', 'k', 'FaceAlpha', 0.6); % required staff
hold on;
bar(hours, optimal_staff, 'FaceColor', [0, 0.6, 0.2], 'EdgeColor', 'k', 'FaceAlpha', 0.5); % optimal staff
bar(hours, current_total, 'FaceColor', [1, 0.8, 0], 'EdgeColor', 'k', 'FaceAlpha', 0.7); % current staff

xlabel('Hour'); ylabel('Number of Staff'); 
title('Staffing Analysis: Current vs Required vs LP Optimized'); 
legend('Current Staff', 'LP Optimized', 'Required Staff', 'Location', 'best');
grid on; xticks(hours); xticklabels(hour_labels);
xline([8.5, 16.5], 'k--', {'Peak Starts', 'Closing Starts'}); % broken vertical lines at shift changes

%% [FIG6] Shortage Analysis
figure(6); 
subplot(2,1,1);
bar(hours, shortage, 'r');
xlabel('Hour'); ylabel('Staff Shortage'); 
title('Additional staff required'); 
grid on; xticks(hours); xticklabels(hour_labels); 

subplot(2,1,2);
bar(hours, excess, 'g'); 
xlabel('Hour'); ylabel('Staff Excess'); 
title('Staff that can be reallocated'); 
grid on; xticks(hours); xticklabels(hour_labels); 

%% [FIG7] Cumulative Occupancy
figure(7); 
cumulative_sept = cumsum(sept_avg);
cumulative_nov = cumsum(nov_avg);

plot(hours, cumulative_sept, 'm-o', 'LineWidth', 1.5); % sept cumulative occupancy
hold on;
plot(hours, cumulative_nov, 'g-s', 'LineWidth', 1.5); % nov cumulative occupancy
xlabel('Hour'); ylabel('Cumulative Occupancy'); 
title('Cumulative Occupancy Throughout the Day');
legend('September', 'November', 'Location', 'best'); 
grid on; xticks(hours); xticklabels(hour_labels);

%% TABLES
% current staff per floor table
current_floor_table = table(hour_ranges', ground_staff', floor2_staff', floor3_staff', floor4_staff', floor6_staff', ...
    'VariableNames', {'Hour', 'GF', '2F', '3F', '4F', '6F'});

% required staff per floor table
required_floor_table = table(hour_ranges', staff_required(1,:)', staff_required(2,:)', staff_required(3,:)', staff_required(4,:)', staff_required(5,:)', ...
    'VariableNames', {'Hour', 'GF', '2F', '3F', '4F', '6F'});

% shortage per floor table
shortage_GF = max(0, staff_required(1,:) - ground_staff);
shortage_2F = max(0, staff_required(2,:) - floor2_staff);
shortage_3F = max(0, staff_required(3,:) - floor3_staff);
shortage_4F = max(0, staff_required(4,:) - floor4_staff);
shortage_6F = max(0, staff_required(5,:) - floor6_staff);

shortage_table = table(hour_ranges', shortage_GF', shortage_2F', shortage_3F', shortage_4F', shortage_6F', ...
    'VariableNames', {'Hour', 'GF', '2F', '3F', '4F', '6F'});

% excess per floor table
excess_GF = max(0, ground_staff - staff_required(1,:));
excess_2F = max(0, floor2_staff - staff_required(2,:));
excess_3F = max(0, floor3_staff - staff_required(3,:));
excess_4F = max(0, floor4_staff - staff_required(4,:));
excess_6F = max(0, floor6_staff - staff_required(5,:));

excess_table = table(hour_ranges', excess_GF', excess_2F', excess_3F', excess_4F', excess_6F', ...
    'VariableNames', {'Hour', 'GF', '2F', '3F', '4F', '6F'});

%% DISPLAY
disp('For checking');
disp(' ')
fprintf('September: %d days\n', days_sept);
disp('September dates found:');
disp(sept_dates');

fprintf('November: %d days\n', days_nov);
disp('November dates found:');
disp(nov_dates');

disp('CURRENT STAFF PER FLOOR (PER HOUR):');
disp(current_floor_table);

disp(' ');
disp('REQUIRED STAFF PER FLOOR (PER HOUR):');
disp(required_floor_table);

disp(' ');
disp('SHORTAGE:');
disp(shortage_table);

disp(' ');
disp('EXCESS:');
disp(excess_table);


disp(' ')
fprintf('LP OPTIMIZATION RESULTS\n');
fprintf('Exit flag: %d (optimal solution found)\n', exitflag);

fprintf('\nHour-by-Hour Comparison of Staffing:\n');
fprintf('Hour\tCurrent\tRequired\tLP Optimal\tDifference\n');
for h = 1:12
    diff_opt = optimal_staff(h) - current_total(h);
    if diff_opt > 0
        sign_opt = '+';
    else
        sign_opt = '';
    end
    fprintf('%s\t%.0f\t%.0f\t\t%.0f\t\t%s%.0f\n', ...
        hour_labels{h}, current_total(h), required_total(h), optimal_staff(h), sign_opt, diff_opt);
end

fprintf('\nTotal staff-hours per day:\n');
fprintf('  Current: %.0f\n', sum(current_total));
fprintf('  Required: %.0f\n', sum(required_total));
fprintf('  LP Optimal: %.0f\n', sum(optimal_staff));

if sum(optimal_staff) < sum(current_total)
    savings = sum(current_total) - sum(optimal_staff);
    fprintf('\nPotential savings: %.0f staff-hours/day (%.1f%% reduction)\n', savings, savings/sum(current_total)*100);
elseif sum(optimal_staff) > sum(current_total)
    fprintf('\nYou need %.0f additional staff-hours per day.\n', sum(optimal_staff) - sum(current_total));
else
    fprintf('\nCurrent staffing is optimal.\n');
end

