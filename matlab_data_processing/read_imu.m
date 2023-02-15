function [imu_time, imu_ws] = read_imu(imu_file_name)
    
    imu_data = readmatrix(imu_file_name, 'OutputType', 'string', 'Delimiter', ',');
    
    imu_time = zeros(size(imu_data, 1), 1);
    imu_ws = zeros(size(imu_data, 1), 1);
    
    for i = 1:size(imu_data, 1)
        imu_time(i) = str2double(imu_data(i, 1))/10^9;
        imu_ws(i) = str2double(imu_data(i, 17));
    end
   
end

