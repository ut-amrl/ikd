function [history_IMU] = get_history_IMU(all_ts_index, imu_orientation, imu_angular_velocity, imu_linear_acceleration, HISTORY_WINDOW_SIZE)

history_IMU = zeros(size(all_ts_index, 1), (3+3)*HISTORY_WINDOW_SIZE);

for i = 1:size(all_ts_index, 1)
    
    history_start_idx = all_ts_index(i)-HISTORY_WINDOW_SIZE;
    history_end_idx = all_ts_index(i)-1;
    
    if history_start_idx > 0
        angular_velocity_history = imu_angular_velocity(history_start_idx:history_end_idx, :)'; % transpose to flatten for row
        linear_acceleration_hisotry = imu_linear_acceleration(history_start_idx:history_end_idx, :)';
    else % not sufficient history in data
        duplicate = -(history_start_idx-1);
        angular_velocity_history = imu_angular_velocity([ones(1, duplicate), 1:history_end_idx], :)'; 
        linear_acceleration_hisotry = imu_linear_acceleration([ones(1, duplicate), 1:history_end_idx], :)';
    end
    angular_velocity_history = angular_velocity_history(:)';
    linear_acceleration_hisotry = linear_acceleration_hisotry(:)';
    
    history_IMU(i, :) = [angular_velocity_history, linear_acceleration_hisotry];
    
end

end

