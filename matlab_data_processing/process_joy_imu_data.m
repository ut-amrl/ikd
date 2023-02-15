clear
clc
close all

SYSTEM_LATENCY = 0.08; % 0.24;
CURVATURE_UPPERBOUND = 3.0;
% INTERPOLATION_MULTIPLIER = 10;
% FIT_CURVE_LEN = 1;
VIDEO_FLAG = 0;
VIZ_FLAG = 1;
% TOLERANCE = 2.0;
HISTORY_WINDOW_SIZE = 100;

if VIDEO_FLAG == 1
    video = VideoWriter('offroad.avi');
    open(video)
    figure()
end


% data_name = ["1.0", "1.1", "1.2","1.3","1.4","1.5","1.6","1.7","1.8","1.9", "2.0", "2.1", "2.2","2.3","2.4","2.5","2.6","2.7","2.8","2.9", "3.0"];
% data_name = ["1.5","1.6","1.7","1.8","1.9", "2.0", "2.1", "2.2","2.3","2.4","2.5","2.6","2.7"];
data_averages = [];
% data_name = ["backyard_training/joystick/training_backyard_joy_imu_small"];
data_name = ["backyard_training/joystick/training_backyard_joy_imu_small", ... 
             "backyard_training/joystick/training_backyard_joy_imu_1", ... 
             "backyard_training/joystick/training_backyard_joy_imu_2", ... 
             "backyard_training/joystick/training_backyard_joy_imu_3", ... 
             "backyard_training/joystick/training_backyard_joy_imu_4", ... 
             "backyard_training/joystick/training_backyard_joy_imu_5", ... 
             "backyard_training/joystick/training_backyard_joy_imu_6", ... 
             "backyard_training/joystick/training_backyard_joy_imu_7", ... 
             "backyard_training/joystick/training_backyard_joy_imu_8", ... 
             "backyard_training/joystick/training_backyard_joy_imu_0117"];

all_data = [];

for i = 1:length(data_name)
    data_name(i)
    [joystick_data, curvature_data_time, velocities, curvatures] = read_joystick(strcat(data_name(i), "/_slash_joystick.csv"));
    [imu_time, imu_ws, imu_orientation, imu_angular_velocity, imu_linear_acceleration] = read_imu_all_channels(strcat(data_name(i), "/_slash_vectornav_slash_IMU.csv"));
    
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
        if abs(velocities(t, 1)) > 0.1 % if the car is moving 
            real_c = imu_ws_sync(t, 1)/velocities(t, 1); 
        else % if the car is not moving
            real_c = 0; 
        end
%         if abs(curr_v - str2num(data_name(i))) < TOLERANCE && ... 
%             curr_c ~=0 && ...
%             curr_c * real_c > 0 && ... 
%             abs(curr_c)<=CURVATURE_UPPERBOUND && ... 
%             abs(real_c)<=CURVATURE_UPPERBOUND
%         if  curr_c ~=0 && ...
%             curr_c * real_c > 0 && ... 
%             abs(curr_c)<=CURVATURE_UPPERBOUND && ... 
%             abs(real_c)<=CURVATURE_UPPERBOUND
%         if  abs(curr_c)<=CURVATURE_UPPERBOUND && ... 
%             abs(real_c)<=CURVATURE_UPPERBOUND
        if true
            commanded_curvatures = [commanded_curvatures; curr_c];
            commanded_velocities = [commanded_velocities; curr_v];
            real_curvatures = [real_curvatures; real_c];
            
            if VIDEO_FLAG == 1
                subplot(3, 1, 1)
                axis equal 
                hold on
                scatter_handle = scatter(future_traj_finer(:, 1), future_traj_finer(:, 2), 'ro', 'filled');
                circle_handle = circle(Par(1), Par(2), Par(3));
                xlim([-1, 3.5])
                ylim([-0.5, 4.5])
                
                subplot(3, 1, 2)
                hold on
                xlim([curvature_data_time(1, 1), curvature_data_time(end, 1)])
%                 ylim([-0.5, CURVATURE_UPPERBOUND])
                scatter(curvature_data_time(t, 1), curr_c, 'b', 'filled');
                scatter(curvature_data_time(t, 1), real_c, 'r', 'filled');
                
                subplot(3, 1, 3)
                hold on
                xlim([curvature_data_time(1, 1), curvature_data_time(end, 1)])
                ylim([0, 2.5])
                scatter(curvature_data_time(t, 1), curr_v, 'g', 'filled');
                
                frame = getframe(gcf);
%                 writeVideo(video,frame);
%                 clf
                delete(scatter_handle)
                delete(circle_handle)
            end
        end
    end
    
    % get IMU history of this file 
    history_IMU = get_history_IMU(all_ts_index, imu_orientation, imu_angular_velocity, imu_linear_acceleration, HISTORY_WINDOW_SIZE);
    
    current_data = [commanded_velocities, commanded_curvatures, real_curvatures, history_IMU];
    current_data = remove_curvature_outliers(current_data);
    diff = current_data(:, 2) - current_data(:, 3);
    data_averages = [data_averages, mean(diff, 'omitnan')];
    
    if VIZ_FLAG == 1
        figure(i)
        hold on
        xlim([1, size(current_data, 1)])
%         ylim([-0.5, CURVATURE_UPPERBOUND])
        scatter(1:size(current_data, 1), current_data(:, 2), 'b', 'filled')
        scatter(1:size(current_data, 1), current_data(:, 3), 'r', 'filled')
    end
    
    all_data = [all_data; current_data];
    
end

figure()
bar(data_averages)
xticks(1:size(data_averages, 2))
xticklabels(data_name)
if VIDEO_FLAG == 1
    close(video);
end

figure()
diff = abs(all_data(:,2)) - abs(all_data(:, 3));
histogram(diff)