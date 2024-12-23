function [N_pizza, N_dishes, T_pizza, T_dishes, completion_times_pizza, completion_times_dishes, wait_times_pizza, wait_times_dishes] = madrest2(lambda_pizza, lambda_drinks, lambda_dishes, lambda_pizza_dishes, mu_pizza, mu_dishes, endtime)
    % Initialize variables
    t = 0; % Current time
    currcustomers_pizza = 0;
    currcustomers_dishes = 0;

    servers_pizza = 1;
    servers_dishes = 2;

    % Initialize event times
    event = zeros(1, 5);
    event(1) = exprnd(60 / lambda_pizza); % Next pizza-only arrival
    event(2) = exprnd(60 / lambda_dishes); % Next dishes-only arrival
    event(3) = inf; % Next pizza service completion
    event(4) = inf; % Next dishes service completion
    event(5) = exprnd(60 / lambda_pizza_dishes); % Next mixed arrival

    nbrdeparted_pizza = 0;
    nbrdeparted_dishes = 0;
    nbrarrived_pizza = 0;
    nbrarrived_dishes = 0;

    % Timekeeping arrays
    arrivedtime_pizza = [];
    arrivedtime_dishes = [];
    start_service_time_pizza = [];
    start_service_time_dishes = [];
    completion_times_pizza = [];
    completion_times_dishes = [];
    wait_times_pizza = [];
    wait_times_dishes = [];

    % Server status over time
    server_status = [];

    % Queues
    queue_pizza = [];
    queue_dishes = [];

    while t < endtime
        [t_next, nextevent] = min(event);
        t = t_next;

        % Record server status
        server_status = [server_status; t, servers_pizza, servers_dishes];

        if nextevent == 1 % Pizza-only arrival
            nbrarrived_pizza = nbrarrived_pizza + 1;
            arrivedtime_pizza(nbrarrived_pizza) = t;
            queue_pizza = [queue_pizza, nbrarrived_pizza];

            % Schedule next pizza-only arrival
            event(1) = exprnd(60 / lambda_pizza) + t;

            % Adjust servers if needed
            if length(queue_pizza) > 2 && servers_dishes > 1
                servers_pizza = servers_pizza + 1;
                servers_dishes = servers_dishes - 1;
            end

            % Start service if possible
            if length(queue_pizza) <= servers_pizza && event(3) == inf
                service_time = exprnd(60 / (servers_pizza * mu_pizza));
                event(3) = t + service_time;
                start_service_time_pizza(queue_pizza(1)) = t;
            end

        elseif nextevent == 2 % Dishes-only arrival
            nbrarrived_dishes = nbrarrived_dishes + 1;
            arrivedtime_dishes(nbrarrived_dishes) = t;
            queue_dishes = [queue_dishes, nbrarrived_dishes];

            % Schedule next dishes-only arrival
            event(2) = exprnd(60 / lambda_dishes) + t;

            % Adjust servers if needed
            if length(queue_dishes) > 2 && servers_pizza > 1
                servers_dishes = servers_dishes + 1;
                servers_pizza = servers_pizza - 1;
            end

            % Start service if possible
            if length(queue_dishes) <= servers_dishes && event(4) == inf
                service_time = exprnd(60 / (servers_dishes * mu_dishes));
                event(4) = t + service_time;
                start_service_time_dishes(queue_dishes(1)) = t;
            end

        elseif nextevent == 5 % Mixed arrival
            % Pizza part
            nbrarrived_pizza = nbrarrived_pizza + 1;
            arrivedtime_pizza(nbrarrived_pizza) = t;
            queue_pizza = [queue_pizza, nbrarrived_pizza];

            % Dishes part
            nbrarrived_dishes = nbrarrived_dishes + 1;
            arrivedtime_dishes(nbrarrived_dishes) = t;
            queue_dishes = [queue_dishes, nbrarrived_dishes];

            % Schedule next mixed arrival
            event(5) = exprnd(60 / lambda_pizza_dishes) + t;

            % Adjust servers if needed
            if length(queue_pizza) > 2 && servers_dishes > 1
                servers_pizza = servers_pizza + 1;
                servers_dishes = servers_dishes - 1;
            end
            if length(queue_dishes) > 2 && servers_pizza > 1
                servers_dishes = servers_dishes + 1;
                servers_pizza = servers_pizza - 1;
            end

            % Start service for pizza if possible
            if length(queue_pizza) <= servers_pizza && event(3) == inf
                service_time = exprnd(60 / (servers_pizza * mu_pizza));
                event(3) = t + service_time;
                start_service_time_pizza(queue_pizza(1)) = t;
            end

            % Start service for dishes if possible
            if length(queue_dishes) <= servers_dishes && event(4) == inf
                service_time = exprnd(60 / (servers_dishes * mu_dishes));
                event(4) = t + service_time;
                start_service_time_dishes(queue_dishes(1)) = t;
            end

        elseif nextevent == 3 % Pizza service completion
            nbrdeparted_pizza = nbrdeparted_pizza + 1;
            customer_index = queue_pizza(1);
            queue_pizza(1) = [];

            completion_times_pizza(nbrdeparted_pizza) = t;
            time_in_system = t - arrivedtime_pizza(customer_index);
            T_pizza(nbrdeparted_pizza) = time_in_system;
            wait_time = start_service_time_pizza(customer_index) - arrivedtime_pizza(customer_index);
            wait_times_pizza(nbrdeparted_pizza) = wait_time;

            % Adjust servers back if needed
            if length(queue_pizza) <= 2 && servers_pizza > 1
                servers_pizza = servers_pizza - 1;
                servers_dishes = servers_dishes + 1;
            end

            % Start next service if queue is not empty
            if ~isempty(queue_pizza)
                service_time = exprnd(60 / (servers_pizza * mu_pizza));
                event(3) = t + service_time;
                start_service_time_pizza(queue_pizza(1)) = t;
            else
                event(3) = inf;
            end

        elseif nextevent == 4 % Dishes service completion
            nbrdeparted_dishes = nbrdeparted_dishes + 1;
            customer_index = queue_dishes(1);
            queue_dishes(1) = [];

            completion_times_dishes(nbrdeparted_dishes) = t;
            time_in_system = t - arrivedtime_dishes(customer_index);
            T_dishes(nbrdeparted_dishes) = time_in_system;
            wait_time = start_service_time_dishes(customer_index) - arrivedtime_dishes(customer_index);
            wait_times_dishes(nbrdeparted_dishes) = wait_time;

            % Adjust servers back if needed
            if length(queue_dishes) <= 2 && servers_dishes > 2
                servers_dishes = servers_dishes - 1;
                servers_pizza = servers_pizza + 1;
            end

            % Start next service if queue is not empty
            if ~isempty(queue_dishes)
                service_time = exprnd(60 / (servers_dishes * mu_dishes));
                event(4) = t + service_time;
                start_service_time_dishes(queue_dishes(1)) = t;
            else
                event(4) = inf;
            end
        end
    end

    % Total number of completed customers
    N_pizza = nbrdeparted_pizza;
    N_dishes = nbrdeparted_dishes;
end
