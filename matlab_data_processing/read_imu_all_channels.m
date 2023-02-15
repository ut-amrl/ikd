function [imu_time, imu_ws, imu_orientation, imu_angular_velocity, imu_linear_acceleration] = read_imu_all_channels(imu_file_name)
    
    imu_data = readmatrix(imu_file_name, 'OutputType', 'string', 'Delimiter', ',');
    
    imu_time = zeros(size(imu_data, 1), 1);
    imu_orientation = zeros(size(imu_data, 1), 4);
    imu_angular_velocity = zeros(size(imu_data, 1), 3);
    imu_linear_acceleration = zeros(size(imu_data, 1), 3);
    
    imu_ws = zeros(size(imu_data, 1), 1);
    
    for i = 1:size(imu_data, 1)
        imu_time(i) = str2double(imu_data(i, 1))/10^9;
        imu_orientation(i, :) = str2double(imu_data(i, 9:12));
        imu_angular_velocity(i, :) = str2double(imu_data(i, 15:17));
        imu_linear_acceleration(i, :) = str2double(imu_data(i, 20:22));
        
        imu_ws(i) = str2double(imu_data(i, 17));
    end
   
end

