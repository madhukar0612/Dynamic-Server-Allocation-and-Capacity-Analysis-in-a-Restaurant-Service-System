% Main script for simulating the restaurant system with dynamic server allocation

% Initialize RNG for variability
%rng('shuffle'); % Use a different random seed each time

% Simulation parameters
lambda_pizza = 2;          % Arrival rate of pizza-only customers (per minute)5
lambda_drinks = 4;         % Arrival rate of drinks-only customers (per minute) [Not used in madrest2]
lambda_dishes = 2;         % Arrival rate of dishes-only customers (per minute)6
lambda_pizza_dishes = 3;   % Arrival rate of customers ordering both pizza and dishes (per minute) 5
mu_pizza = 4;              % Service rate of pizza servers (per minute)
mu_dishes = 4;             % Service rate of dishes servers (per minute)
endtime = 1000;            % Simulation end time (in seconds)

% Call the updated simulation function
[N_pizza, N_dishes, T_pizza, T_dishes, ...
 completion_times_pizza, completion_times_dishes, ...
 wait_times_pizza, wait_times_dishes] = madrest2(...
    lambda_pizza, lambda_drinks, lambda_dishes, ...
    lambda_pizza_dishes, mu_pizza, mu_dishes, endtime);

% Calculate average time for pizza and dishes customers
avg_time_pizza = mean(T_pizza);
avg_time_dishes = mean(T_dishes);

fprintf('Average time for pizza customers: %.2f seconds\n', avg_time_pizza);
fprintf('Average time for dishes customers: %.2f seconds\n', avg_time_dishes);

% Calculate the total number of pizzas, dishes, and drinks served
total_pizzas_served = N_pizza;
total_dishes_served = N_dishes;
simulation_time_minutes = endtime / 60;
total_drinks_served = (lambda_drinks + lambda_pizza_dishes) * simulation_time_minutes; % Including drinks from mixed orders

%% Plot 1: Total Number of Pizzas, Dishes, and Drinks Served During Simulation
figure;
bar_data = [total_pizzas_served, total_dishes_served, total_drinks_served];
bar_labels = {'Pizzas', 'Dishes', 'Drinks'};
bar(bar_data);
set(gca, 'XTickLabel', bar_labels);
xlabel('Item Type');
ylabel('Total Number Served');
title('Total Number of Pizzas, Dishes, and Drinks Served During Simulation');
grid on;

%% Plot 2: Histogram of Pizza Customers' Waiting Times
figure;
histogram(wait_times_pizza, 'BinWidth', 5);
xlabel('Waiting Time (seconds)');
ylabel('Number of Customers');
title('Histogram of Pizza Customers'' Waiting Times');
grid on;

%% Plot 3: Histogram of Dishes Customers' Waiting Times
figure;
histogram(wait_times_dishes, 'BinWidth', 5);
xlabel('Waiting Time (seconds)');
ylabel('Number of Customers');
title('Histogram of Dishes Customers'' Waiting Times');
grid on;

%% Plot 4: Histogram of Sojourn Times for Pizza Customers
figure;
histogram(T_pizza, 'BinWidth', 10);
xlabel('Sojourn Time (seconds)');
ylabel('Number of Customers');
title('Histogram of Pizza Customers'' Sojourn Times');
grid on;

%% Plot 5: Histogram of Sojourn Times for Dishes Customers
figure;
histogram(T_dishes, 'BinWidth', 10);
xlabel('Sojourn Time (seconds)');
ylabel('Number of Customers');
title('Histogram of Dishes Customers'' Sojourn Times');
grid on;

%% Plot 6: Cumulative Number of Orders Served Over Time
% Combine completion times and types
if ~isempty(completion_times_pizza) || ~isempty(completion_times_dishes)
    completion_times_all = [completion_times_pizza(:); completion_times_dishes(:)];
    order_types = [repmat({'Pizza'}, length(completion_times_pizza), 1); ...
                  repmat({'Dishes'}, length(completion_times_dishes), 1)];

    % Create a table to sort completion times
    orders_table = table(completion_times_all, order_types, ...
                         'VariableNames', {'CompletionTime', 'OrderType'});
    orders_table = sortrows(orders_table, 'CompletionTime');

    % Calculate cumulative orders
    cumulative_orders = (1:height(orders_table))';

    % Plot cumulative orders over time
    figure;
    stairs(orders_table.CompletionTime, cumulative_orders, 'LineWidth', 2);
    xlabel('Time (seconds)');
    ylabel('Cumulative Number of Orders Served');
    title('Cumulative Number of Orders Served Over Time');
    grid on;
else
    fprintf('No orders were completed during the simulation to plot cumulative orders.\n');
end
