function [loc_time, loc_x, loc_y, loc_theta] = read_localization(localization_file_name)

    localization_data = readmatrix(localization_file_name);
    loc_time = localization_data(:, 1)/10^9;
    loc_x = localization_data(:, 9);
    loc_y = localization_data(:, 10);
    loc_theta = localization_data(:, 11);

end

