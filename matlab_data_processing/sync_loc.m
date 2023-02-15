function [loc_time_sync, loc_xs_sync, loc_ys_sync, loc_thetas_sync] = sync_loc(system_latency, curvature_data_time, loc_time, loc_xs, loc_ys, loc_thetas)

loc_time_sync = zeros(size(curvature_data_time, 1), 1);
loc_xs_sync = zeros(size(curvature_data_time, 1), 1);
loc_ys_sync = zeros(size(curvature_data_time, 1), 1);
loc_thetas_sync = zeros(size(curvature_data_time, 1), 1);

for tc = 1:size(curvature_data_time, 1)
    for to = 1:size(loc_time)
        if loc_time(to, 1) > curvature_data_time(tc, 1)+system_latency
            if to > 1
                loc_time_sync(tc, 1) = loc_time(to-1, 1);
                loc_xs_sync(tc, 1) = loc_xs(to-1, 1);
                loc_ys_sync(tc, 1) = loc_ys(to-1, 1);
                loc_thetas_sync(tc, 1) = loc_thetas(to-1, 1);
            else
                loc_time_sync(tc, 1) = loc_time(to, 1);
                loc_xs_sync(tc, 1) = loc_xs(to, 1);
                loc_ys_sync(tc, 1) = loc_ys(to, 1);
                loc_thetas_sync(tc, 1) = loc_thetas(to, 1);
            end
            break
        end
    end
end

end

