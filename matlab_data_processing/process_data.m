clear
clc
close all

SYSTEM_LATENCY = 0.0; % 0.24;
CURVATURE_UPPERBOUND = 2.0;
INTERPOLATION_MULTIPLIER = 10;
FIT_CURVE_LEN = 20;
VIDEO_FLAG = 0;
VIZ_FLAG = 0;
TOLERANCE = 0.1;

video = VideoWriter('offroad.avi');
if VIDEO_FLAG == 1
    open(video)
    figure()
end


% data_name = ["1.0", "1.1", "1.2","1.3","1.4","1.5","1.6","1.7","1.8","1.9", "2.0", "2.1", "2.2","2.3","2.4","2.5","2.6","2.7","2.8","2.9", "3.0"];
data_name = ["1.0", "1.1", "1.2","1.3","1.4","1.5","1.6","1.7","1.8","1.9", "2.0", "2.1", "2.2","2.3","2.4"];
data_averages = [];
% data_name = ["1.1"];

all_data = [];

for i = 1:length(data_name)
    [curvature_drive_data,curvature_data_time, velocities, curvatures] = read_curvature_drive(strcat(data_name(i), "/_slash_ackermann_curvature_drive.csv"));
    [autonomy_enabler_data, autonomy_enabler_time, autonomies] = read_autonomy_enabler(strcat(data_name(i), "/_slash_autonomy_enabler.csv"));
    [cmd_vel_time, cmd_vel_vs, cmd_vel_ws] = read_cmd_vel(strcat(data_name(i), "/_slash_navigation_slash_cmd_vel.csv"));
    [odom_time, odom_vs, odom_ws] = read_odom(strcat(data_name(i), "/_slash_odom.csv"));
    [loc_time, loc_xs, loc_ys, loc_thetas] = read_localization(strcat(data_name(i), "/_slash_localization.csv"));
    
    % sync
    [odom_time_sync, odom_vs_sync, odom_ws_sync] = sync_odom(SYSTEM_LATENCY, curvature_data_time, odom_time, odom_vs, odom_ws);
    [loc_time_sync, loc_xs_sync, loc_ys_sync, loc_thetas_sync] = sync_loc(SYSTEM_LATENCY, curvature_data_time, loc_time, loc_xs, loc_ys, loc_thetas);    
    
    if VIDEO_FLAG == 1
        subplot(3, 1, 1)
        plot(loc_xs, loc_ys)
    end
    diff = [];
    real_curvatures = [];
    commanded_curvatures = [];
    commanded_velocities = [];
    for t = 1:size(curvature_data_time, 1)-FIT_CURVE_LEN+1
        curr_v = velocities(t, 1);
        curr_c = curvatures(t, 1);
        if abs(curr_v - str2num(data_name(i))) < TOLERANCE
%         if curr_v ~= 0
            future_traj = [loc_xs_sync(t:t+FIT_CURVE_LEN-1, 1), loc_ys_sync(t:t+FIT_CURVE_LEN-1, 1), loc_thetas_sync(t:t+FIT_CURVE_LEN-1, 1)];
            future_traj_finer = generate_finer_traj(future_traj, INTERPOLATION_MULTIPLIER);
%             future_traj_finer = future_traj;
            Par = CircleFitByPratt(future_traj_finer(:, 1:2));
            real_c = 1/Par(1, 3);
            if abs(curr_c)>CURVATURE_UPPERBOUND
                curr_c = 0;
            end
            if abs(real_c)>CURVATURE_UPPERBOUND
                real_c = 0;
            end
            commanded_curvatures = [commanded_curvatures; curr_c];
            commanded_velocities = [commanded_velocities; curr_v];
            real_curvatures = [real_curvatures; real_c];
            diff = [diff; curr_c - real_c];
            
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
                ylim([-0.5, CURVATURE_UPPERBOUND])
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
    
    data_averages = [data_averages, mean(diff, 'omitnan')];
    all_data = [all_data; commanded_velocities, commanded_curvatures, real_curvatures];
    
    if VIZ_FLAG == 1
        figure(i)
        hold on
        xlim([1, size(commanded_curvatures, 1)])
        ylim([-0.5, CURVATURE_UPPERBOUND])
        scatter(1:size(commanded_curvatures, 1), commanded_curvatures, 'b', 'filled')
        scatter(1:size(real_curvatures, 1), real_curvatures, 'r', 'filled')
    end
    
end

figure()
bar(data_averages)
xticks(1:size(data_averages, 2))
xticklabels(data_name)
if VIDEO_FLAG == 1
    close(video);
end