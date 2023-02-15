function [curvature_drive_data,curvature_data_time, velocity, curvature] = read_curvature_drive(curvature_drive_file_name)
    
    curvature_drive_data = readmatrix(curvature_drive_file_name);
    curvature_data_time = curvature_drive_data(:, 1)/10^9;
    velocity = curvature_drive_data(:, 8);
    curvature = curvature_drive_data(:, 9);

end

