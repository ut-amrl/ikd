function [imu_time_sync, imu_ws_sync] = sync_imu(system_latency, curvature_data_time, imu_time, imu_ws)

% take average imu values for accuracy

imu_time_sync = zeros(size(curvature_data_time, 1)-1, 1);
imu_ws_sync = zeros(size(curvature_data_time, 1)-1, 1);

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
    
    imu_window = imu_ws(ts:te);
    imu_time_sync(tc) = imu_time(ts);
    imu_ws_sync(tc) = mean(imu_window);
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
% imu_window = imu_ws(ts:te);
% if isempty(imu_window)
%     imu_time_sync(end) = imu_time_sync(end-1);
%     imu_ws_sync(end) = imu_ws_sync(end-1);
% else
%     imu_time_sync(end) = imu_time(ts);
%     imu_ws_sync(end) = mean(imu_window);
% end

end

