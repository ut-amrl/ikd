function [imu_time_sync, imu_ws_sync, imu_orientation_sync, imu_angular_velocity_sync, imu_linear_acceleration_sync, all_ts_index] = sync_imu_all_channels(system_latency, curvature_data_time, imu_time, imu_ws, imu_orientation, imu_angular_velocity, imu_linear_acceleration)

% take average imu values for accuracy

all_ts_index = zeros(size(curvature_data_time, 1)-1, 1);

imu_time_sync = zeros(size(curvature_data_time, 1)-1, 1);
imu_ws_sync = zeros(size(curvature_data_time, 1)-1, 1);
imu_orientation_sync = zeros(size(curvature_data_time, 1)-1, 4);
imu_angular_velocity_sync = zeros(size(curvature_data_time, 1)-1, 3);
imu_linear_acceleration_sync = zeros(size(curvature_data_time, 1)-1, 3);

for tc = 1:size(curvature_data_time, 1)-1
    
    % find start imu time
    for ti = 1:size(imu_time)
        if imu_time(ti, 1) > curvature_data_time(tc, 1)+system_latency
            ts = ti;
            break
        end
    end
    
    % find end imu time
    for ti = ts:size(imu_time)
        if imu_time(ti, 1) > curvature_data_time(tc+1, 1)+system_latency
            if ti > 1
                te = ti-1;
            else
                te = 1;
            end
            break
        end
    end
    
    imu_ws_window = imu_ws(ts:te);
    imu_orientation_window = imu_orientation(ts:te, :);
    imu_angular_velocity_window = imu_angular_velocity(ts:te, :);
    imu_linear_acceleration_window = imu_linear_acceleration(ts:te, :);
    
    all_ts_index(tc) = ts;
    
    imu_time_sync(tc) = imu_time(ts);
    imu_ws_sync(tc) = mean(imu_ws_window);
%     imu_ws_sync(tc) = imu_ws_window(1);
    imu_orientation_sync(tc, :) = mean(imu_orientation_window);
    imu_angular_velocity_sync(tc, :) = mean(imu_angular_velocity_window);
    imu_linear_acceleration_sync(tc, :) = mean(imu_linear_acceleration_window);
end

% these are all wrong, forget the last curvature
% % special case for the last curvature value
% tc = size(curvature_data_time, 1);
% for ti = size(imu_time):1
%     if ti < tc
%         ts = ti+1;
%         te = size(imu_time);
%     end
% end
% imu_ws_window = imu_ws(ts:te);
% if isempty(imu_ws_window)
%     imu_time_sync(end) = imu_time_sync(end-1);
%     imu_ws_sync(end) = imu_ws_sync(end-1);
% else
%     imu_time_sync(end) = imu_time(ts);
%     imu_ws_sync(end) = mean(imu_ws_window);
% end

end

