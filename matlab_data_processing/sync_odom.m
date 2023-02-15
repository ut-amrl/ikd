function [odom_time_sync, odom_vs_sync, odom_ws_sync] = sync_odom(system_latency, curvature_data_time, odom_time, odom_vs, odom_ws)

odom_time_sync = zeros(size(curvature_data_time, 1), 1);
odom_vs_sync = zeros(size(curvature_data_time, 1), 1);
odom_ws_sync = zeros(size(curvature_data_time, 1), 1);

for tc = 1:size(curvature_data_time, 1)
    for to = 1:size(odom_time)
        if odom_time(to, 1) > curvature_data_time(tc, 1)+system_latency
            if to > 1
                odom_time_sync(tc, 1) = odom_time(to-1, 1);
                odom_vs_sync(tc, 1) = odom_vs(to-1, 1);
                odom_ws_sync(tc, 1) = odom_ws(to-1, 1);
            else
                odom_time_sync(tc, 1) = odom_time(to, 1);
                odom_vs_sync(tc, 1) = odom_vs(to, 1);
                odom_ws_sync(tc, 1) = odom_ws(to, 1);
            end
            break
        end
    end
end

end

