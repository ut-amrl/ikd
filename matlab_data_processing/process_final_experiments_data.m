clear
clc
close all

SYSTEM_LATENCY = 0.08; % 0.24;
CURVATURE_UPPERBOUND = 2.0;
% INTERPOLATION_MULTIPLIER = 10;
% FIT_CURVE_LEN = 20;
VIDEO_FLAG = 0;
VIZ_FLAG = 1;
% TOLERANCE = 2.0;
HISTORY_WINDOW_SIZE = 100;

video = VideoWriter('offroad.avi');
if VIDEO_FLAG == 1
    open(video)
    figure()
end

MAX_Vs = ["1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2", "2.3", "2.4", "2.5"];

all_data = [];

for v_iter = 1:length(MAX_Vs)
    
    MAX_Vs(v_iter)
    
    %% default ablation learned 
    default_folder_name = strcat("final_experiments/experiments/learned/", MAX_Vs(v_iter));
    files = dir(default_folder_name);
    dir_flags = [files.isdir];
    sub_folders = files(dir_flags);
    sub_folders(ismember( {sub_folders.name}, {'.', '..'})) = [];  %remove . and ..
      
    current_velocity_data = [];
    
    for sub_folder_iter = 1:size(sub_folders, 1)
        imu_file_name = strcat(default_folder_name, "/", sub_folders(sub_folder_iter, 1).name, "/_slash_vectornav_slash_IMU.csv");
        ackermann_file_name = strcat(default_folder_name, "/", sub_folders(sub_folder_iter, 1).name, "/_slash_ackermann_curvature_drive.csv");
        
        [curvature_drive_data,curvature_data_time, velocities, curvatures] = read_curvature_drive(ackermann_file_name);
        [imu_time, imu_ws, imu_orientation, imu_angular_velocity, imu_linear_acceleration] = read_imu_all_channels(imu_file_name);

        % sync
        [imu_time_sync, imu_ws_sync, imu_orientation_sync, imu_angular_velocity_sync, imu_linear_acceleration_sync, all_ts_index] = sync_imu_all_channels(SYSTEM_LATENCY, curvature_data_time, imu_time, imu_ws, imu_orientation, imu_angular_velocity, imu_linear_acceleration);   
        velocities(end) = []; curvatures(end) = []; curvature_data_time(end) = []; % remove last one
        if VIDEO_FLAG == 1
            subplot(3, 1, 1)
            plot(loc_xs, loc_ys)
        end
        real_curvatures = [];
        commanded_curvatures = [];
        commanded_velocities = [];
        for t = 1:size(curvature_data_time, 1)
            curr_v = velocities(t, 1);
            curr_c = curvatures(t, 1);
            if abs(curr_c) > 2 % ackermann drive has outlier of 1000 curvature
                curr_c = 0;
            end
            if abs(velocities(t, 1)) > 0.2 % if the car is moving 
                real_c = imu_ws_sync(t, 1)/velocities(t, 1); 
            else % if the car is not moving
                real_c = 0; 
            end

            commanded_curvatures = [commanded_curvatures; curr_c];
            commanded_velocities = [commanded_velocities; curr_v];
            real_curvatures = [real_curvatures; real_c];

        end

        % get IMU history of this file 
        history_IMU = get_history_IMU(all_ts_index, imu_orientation, imu_angular_velocity, imu_linear_acceleration, HISTORY_WINDOW_SIZE);

        current_data = [commanded_velocities, commanded_curvatures, real_curvatures, history_IMU];
        current_data = remove_curvature_outliers(current_data);
%         diff = current_data(:, 2) - current_data(:, 3);
%         data_averages = [data_averages, mean(diff, 'omitnan')];

        current_velocity_data = [current_velocity_data; current_data];
        
    end
    
    if VIZ_FLAG == 1
            figure()
            hold on
            xlim([1, size(current_velocity_data, 1)])
    %         ylim([-0.5, CURVATURE_UPPERBOUND])
            scatter(1:size(current_velocity_data, 1), current_velocity_data(:, 2), 'b', 'filled')
            scatter(1:size(current_velocity_data, 1), current_velocity_data(:, 3), 'r', 'filled')
    end
    
    all_data = [all_data; current_velocity_data];
    
end

% figure()
% bar(data_averages)
% xticks(1:size(data_averages, 2))
% xticklabels(data_name)
% if VIDEO_FLAG == 1
%     close(video);
% end

% figure()
% diff = abs(all_data(:,2)) - abs(all_data(:, 3));
% histogram(diff)