function all_data = remove_curvature_outliers(all_data)
% if the difference between real and commanded curvature is
% unreaslistically huge (due to small velocity), remove it as outlier

% also remove imu w NaN

outlier_threashold = 0.2; % 0.2 works well

remove_idx = [];

for i = 1:size(all_data, 1)
%     if all_data(i, 1) < 0.1 || all_data(i, 2) * all_data(i, 3) < 0 || abs(all_data(i, 2)) - abs(all_data(i, 3)) < 0 || abs(all_data(i, 2) - all_data(i, 3)) >  outlier_threashold || isnan(all_data(i, 2)) || isnan(all_data(i, 3))
    if all_data(i, 1) < 0.1 || all_data(i, 2) * all_data(i, 3) < 0 || abs(all_data(i, 2)) - abs(all_data(i, 3)) < 0 || abs(all_data(i, 2) - all_data(i, 3)) >  outlier_threashold || isnan(all_data(i, 2)) || isnan(all_data(i, 3))
        remove_idx = [remove_idx; i];
    end
end

all_data(remove_idx, :) = [];

end

