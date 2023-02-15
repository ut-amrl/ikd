function [cmd_vel_time, cmd_vel_vs, cmd_vel_ws] = read_cmd_vel(cmd_vel_file_name)

    cmd_vel_data = readmatrix(cmd_vel_file_name);
    cmd_vel_time = cmd_vel_data(:, 1)/10^9;
    cmd_vel_vs = cmd_vel_data(:, 3);
    cmd_vel_ws = cmd_vel_data(:, 9);


end

