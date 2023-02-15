clear
clc
close all

MarkerFaceAlpha = 0.2;

MAX_Vs = ["1.6", "1.7", "1.8", "1.9", "2.0", "2.1", "2.2", "2.3", "2.4", "2.5"];
% MAX_Vs = ["2.5"];
results_line_number = [1 2 3 4 5 6 7 8 9 10];
% MAX_Vs = ["2.5"];
% results_line_number = [10];
% MAX_Vs = ["1.6"];
% results_line_number = [1];
% MAX_Vs = ["2.1"];
% results_line_number = [6];

default_results = [0 0 0 0 0 9 10 0;
                   0 2 0 0 0 10 10 0;
                   0 8 0 0 0 10 10 0;
                   0 9 1 6 2 10 10 0;
                   0 10 1 7 9 10 10 0;
                   0 5 0 10 7 10 10 0;
                   0 6 0 10 10 10 10 0;
                   0 5 1 10 10 10 10 0;
                   0 7 0 10 8 9 10 1;
                   0 7 1 10 10 9 10 1]; % line is velocity, column is corner index
               
ablation_results = [0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0;
                    0 0 0 0 0 6 0 0;
                    0 0 0 0 0 7 1 0;
                    0 0 0 0 0 8 0 0;
                    0 0 0 1 0 4 1 0;
                    0 0 0 3 1 7 0 0;
                    0 0 0 10 1 10 6 1;
                    0 0 0 10 3 8 7 2;
                    0 2 1 10 4 10 10 3];
                
learned_results = [0 0 0 0 0 0 0 0;
                   0 0 0 0 0 0 0 0;
                   0 0 0 0 0 2 0 0;
                   0 0 0 0 0 1 0 0;
                   0 0 0 0 0 1 1 2;
                   0 0 0 5 0 2 1 1;
                   0 0 0 1 0 5 3 2;
                   0 0 0 7 0 8 9 1;
                   0 0 0 8 0 6 8 0;
                   0 2 0 9 3 8 5 4];
               
               
%% plot success rate each method each velocity
% all_default_success = zeros(size(MAX_Vs, 1), 1);
% all_ablation_success = zeros(size(MAX_Vs, 1), 1);
% all_learned_success = zeros(size(MAX_Vs, 1), 1);
% for v_iter = 1:length(MAX_Vs)
%     all_default_success(v_iter, 1) = (1 - sum(default_results(v_iter, :)) / (10*8))*100;
%     all_ablation_success(v_iter, 1) = (1 - sum(ablation_results(v_iter, :)) / (10*8))*100;
%     all_learned_success(v_iter, 1) = (1 - sum(learned_results(v_iter, :)) / (10*8))*100;
% end
% 
% all_success = [all_default_success all_ablation_success all_learned_success];
% figure()
% set(gcf, 'WindowState', 'maximized');
% hold on
% set(gca, 'XTickLabel', {'1.6m/s','1.7m/s','1.8 m/s','1.9m/s','2.0m/s','2.1m/s','2.2m/s','2.3m/s','2.4m/s','2.5m/s'}, 'FontWeight', 'bold', 'FontSize', 27)
% title("Failure Turn Rate per Speed (%)", 'FontWeight', 'bold', 'FontSize', 55)
% all_failure = 100 - all_success;
% b = bar(all_failure,'FaceColor','flat');
% bar_colors = [1 0 0; 0 0 1; 0 1 0;];
% for k = 1:size(all_success,2)
%     b(k).CData = bar_colors(k, :);
% end
% legend('Baseline','Ablation','Learning', 'location', 'best', 'FontSize', 40)
% success_rate = mean(all_success, 1)

%% plot success rate each method each turn
% all_default_success = zeros(1, 8);
% all_ablation_success = zeros(1, 8);
% all_learned_success = zeros(1, 8);
% for turn_iter = 1:8
%     all_default_success(1, turn_iter) = (1 - sum(default_results(:, turn_iter)) / (length(MAX_Vs)*10))*100;
%     all_ablation_success(1, turn_iter) = (1 - sum(ablation_results(:, turn_iter)) / (length(MAX_Vs)*10))*100;
%     all_learned_success(1, turn_iter) = (1 - sum(learned_results(:, turn_iter)) / (length(MAX_Vs)*10))*100;
% end
% 
% all_success = [all_default_success' all_ablation_success' all_learned_success'];
% figure()
% set(gcf, 'WindowState', 'maximized');
% hold on
% set(gca, 'XTickLabel', {'T1','T2','T3','T4','T5','T6','T7','T8'}, 'FontWeight', 'bold', 'FontSize', 30)
% title("Failure Turn Rate per Turn (%)", 'FontWeight', 'bold', 'FontSize', 55)
% all_failure = 100 - all_success;
% b = bar(all_failure,'FaceColor','flat');
% bar_colors = [1 0 0; 0 0 1; 0 1 0;];
% for k = 1:size(all_success,2)
%     b(k).CData = bar_colors(k, :);
% end
% legend('Baseline','Ablation','Learning', 'location', 'best', 'FontSize', 40)
% success_rate = mean(all_success, 1)


hausdorff_default = zeros(size(MAX_Vs));
hausdorff_ablation = zeros(size(MAX_Vs));
hausdorff_learned = zeros(size(MAX_Vs));




for v_iter = 1:length(MAX_Vs)
    figure(v_iter+2)
    set(gcf, 'WindowState', 'maximized');
%     subplottight(2, 5, v_iter)
    hold on
    axis equal
    xlim([-2, 7.7])
    ylim([-1.1, 6])
    
    %% plot map and path
    vectors = readmatrix("/home/xuesu/amrl_libraries/amrl_maps/xx_backyard/xx_backyard.vectormap.txt");
    for vector_idx = 1:size(vectors, 1)
        plot([vectors(vector_idx, 1), vectors(vector_idx, 3)], [vectors(vector_idx, 2), vectors(vector_idx, 4)], 'Color', [0.5,0.5,0.5], 'LineWidth', 10)
    end
    nav_nodes = [-0.29971083998680115, 0.04511776193976402;
                 1.7434791326522827, 0.7412203550338745;
                 4.612898349761963, 0.6757991909980774;
                 6.215074062347412, 0.04555955529212952;
                 6.936432361602783, 1.1465805768966675;
                 6.553923606872559, 4.049590110778809;
                 5.478966236114502, 4.88450813293457;
                 4.247462272644043, 4.018280506134033;
                 4.122224807739258, 2.5884833335876465;
                 -0.960338830947876, 1.565708875656128;
                 -0.9916481971740723, 0.636862576007843;
                 2.9950852394104004, -0.2815472483634949;
                 1.369392991065979, 4.540770530700684;
                 1.2708436250686646, 2.6806514263153076;
                 0.014339262619614601, 5.329165458679199;
                 -0.9341983199119568, 4.6023640632629395;
                 2.7924931049346924, 2.379026174545288];
    nav_edges = [0 1;
                 1 11;
                 11 2;
                 2 3;
                 3 4;
                 4 5;
                 5 6;
                 6 7;
                 7 8;
                 13 12;
                 12 14;
                 14 15
                 15 9;
                 9 10;
                 10 0;
                 13 16;
                 16 8];
    for edge_idx = 1:size(nav_edges, 1)
        plot([nav_nodes(nav_edges(edge_idx, 1)+1, 1), nav_nodes(nav_edges(edge_idx, 2)+1, 1)], [nav_nodes(nav_edges(edge_idx, 1)+1, 2), nav_nodes(nav_edges(edge_idx, 2)+1, 2)], 'Color', [0,0,0], 'LineWidth', 4)
    end
    
    
    %% default
    default_folder_name = strcat("final_experiments/experiments/default/", MAX_Vs(v_iter));
    files = dir(default_folder_name);
    dir_flags = [files.isdir];
    sub_folders = files(dir_flags);
    sub_folders(ismember( {sub_folders.name}, {'.', '..'})) = [];  %remove . and ..
    
    all_xs_default = [];
    all_ys_default = [];
    
    for sub_folder_iter = 1:size(sub_folders, 1)
        localization_file_name = strcat(default_folder_name, "/", sub_folders(sub_folder_iter, 1).name, "/_slash_localization.csv");
        [time, xs, ys, thetas] = read_experiments_localization(localization_file_name);
        all_xs_default = [all_xs_default; xs];
        all_ys_default = [all_ys_default; ys];
    end
    scatter(all_xs_default, all_ys_default, 'filled', 'r', 'MarkerFaceAlpha', MarkerFaceAlpha)
    
    %% ablation
    ablation_folder_name = strcat("final_experiments/experiments/ablation/", MAX_Vs(v_iter));
    files = dir(ablation_folder_name);
    dir_flags = [files.isdir];
    sub_folders = files(dir_flags);
    sub_folders(ismember( {sub_folders.name}, {'.', '..'})) = [];  %remove . and ..
    
    all_xs_ablation = [];
    all_ys_ablation = [];
    
    for sub_folder_iter = 1:size(sub_folders, 1)
        localization_file_name = strcat(ablation_folder_name, "/", sub_folders(sub_folder_iter, 1).name, "/_slash_localization.csv");
        [time, xs, ys, thetas] = read_experiments_localization(localization_file_name);
        all_xs_ablation = [all_xs_ablation; xs];
        all_ys_ablation = [all_ys_ablation; ys];
    end
    scatter(all_xs_ablation, all_ys_ablation, 'filled', 'b', 'MarkerFaceAlpha', MarkerFaceAlpha)
    
    %% learned
    learned_folder_name = strcat("final_experiments/experiments/learned/", MAX_Vs(v_iter));
    files = dir(learned_folder_name);
    dir_flags = [files.isdir];
    sub_folders = files(dir_flags);
    sub_folders(ismember( {sub_folders.name}, {'.', '..'})) = [];  %remove . and ..
    
    all_xs_learned = [];
    all_ys_learned = [];
    
    for sub_folder_iter = 1:size(sub_folders, 1)
        localization_file_name = strcat(learned_folder_name, "/", sub_folders(sub_folder_iter, 1).name, "/_slash_localization.csv");
        [time, xs, ys, thetas] = read_experiments_localization(localization_file_name);
        all_xs_learned = [all_xs_learned; xs];
        all_ys_learned = [all_ys_learned; ys];
    end
    scatter(all_xs_learned, all_ys_learned, 'filled', 'g', 'MarkerFaceAlpha', MarkerFaceAlpha)
    
    %% corner results
    turn_coordinates = [1.6 1.05;
                        2.5, -0.15;
                        4.2 1;
                        6.6 0.05;
                        6.7 5.0
                        4.45 2.2
                        1.8 5.3
                        -1.3 0.1];
    for turn_idx = 1:size(turn_coordinates, 1)
        scatter_scale = 200;
        dot_offset_x = 0.72;
        dot_offset_y = 0.55;
        text(turn_coordinates(turn_idx, 1), turn_coordinates(turn_idx, 2), strcat("T", num2str(turn_idx)), 'FontWeight', 'bold', 'FontSize', 60, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
        if default_results(results_line_number(v_iter), turn_idx) ~= 0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2), scatter_scale*default_results(results_line_number(v_iter), turn_idx), 'r', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
        if ablation_results(results_line_number(v_iter), turn_idx) ~=0
            scatter(turn_coordinates(turn_idx, 1), turn_coordinates(turn_idx, 2)-dot_offset_y, scatter_scale*ablation_results(results_line_number(v_iter), turn_idx), 'b', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
        if learned_results(results_line_number(v_iter), turn_idx) ~=0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2)-dot_offset_y, scatter_scale*learned_results(results_line_number(v_iter), turn_idx), 'g', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
    end

    %% video 
    video_name = strcat("video_", MAX_Vs(v_iter));
    video = VideoWriter(video_name);
    open(video)
    VIDEO_STEP = int16(50 * str2num(MAX_Vs(v_iter)));
    video_rect = [380 80 1140 850];
    
    frame = getframe(gcf,video_rect);
    writeVideo(video,frame);
    
    clf;
    
    hold on
    axis equal
    xlim([-2, 7.7])
    ylim([-1.1, 6])
    
    vectors = readmatrix("/home/xuesu/amrl_libraries/amrl_maps/xx_backyard/xx_backyard.vectormap.txt");
    for vector_idx = 1:size(vectors, 1)
        plot([vectors(vector_idx, 1), vectors(vector_idx, 3)], [vectors(vector_idx, 2), vectors(vector_idx, 4)], 'Color', [0.5,0.5,0.5], 'LineWidth', 10)
    end
    nav_nodes = [-0.29971083998680115, 0.04511776193976402;
                 1.7434791326522827, 0.7412203550338745;
                 4.612898349761963, 0.6757991909980774;
                 6.215074062347412, 0.04555955529212952;
                 6.936432361602783, 1.1465805768966675;
                 6.553923606872559, 4.049590110778809;
                 5.478966236114502, 4.88450813293457;
                 4.247462272644043, 4.018280506134033;
                 4.122224807739258, 2.5884833335876465;
                 -0.960338830947876, 1.565708875656128;
                 -0.9916481971740723, 0.636862576007843;
                 2.9950852394104004, -0.2815472483634949;
                 1.369392991065979, 4.540770530700684;
                 1.2708436250686646, 2.6806514263153076;
                 0.014339262619614601, 5.329165458679199;
                 -0.9341983199119568, 4.6023640632629395;
                 2.7924931049346924, 2.379026174545288];
    nav_edges = [0 1;
                 1 11;
                 11 2;
                 2 3;
                 3 4;
                 4 5;
                 5 6;
                 6 7;
                 7 8;
                 13 12;
                 12 14;
                 14 15
                 15 9;
                 9 10;
                 10 0;
                 13 16;
                 16 8];
    for edge_idx = 1:size(nav_edges, 1)
        plot([nav_nodes(nav_edges(edge_idx, 1)+1, 1), nav_nodes(nav_edges(edge_idx, 2)+1, 1)], [nav_nodes(nav_edges(edge_idx, 1)+1, 2), nav_nodes(nav_edges(edge_idx, 2)+1, 2)], 'Color', [0,0,0], 'LineWidth', 4)
    end
    
    frame = getframe(gcf,video_rect);
    writeVideo(video,frame);
    
    for video_frame_idx = 1:VIDEO_STEP:(size(all_xs_default, 1)-VIDEO_STEP)
        fig = scatter(all_xs_default(video_frame_idx:video_frame_idx+VIDEO_STEP), all_ys_default(video_frame_idx:video_frame_idx+VIDEO_STEP), 'filled', 'r', 'MarkerFaceAlpha', MarkerFaceAlpha);
        frame = getframe(gcf,video_rect);
        writeVideo(video,frame);
    end
    
    for video_frame_idx = 1:VIDEO_STEP:(size(all_xs_ablation, 1)-VIDEO_STEP)
        fig = scatter(all_xs_ablation((video_frame_idx:video_frame_idx+VIDEO_STEP)), all_ys_ablation((video_frame_idx:video_frame_idx+VIDEO_STEP)), 'filled', 'b', 'MarkerFaceAlpha', MarkerFaceAlpha);
        frame = getframe(gcf,video_rect);
        writeVideo(video,frame);
    end
    
    for video_frame_idx = 1:VIDEO_STEP:(size(all_xs_learned, 1)-VIDEO_STEP)
        fig = scatter(all_xs_learned(video_frame_idx:video_frame_idx+VIDEO_STEP), all_ys_learned(video_frame_idx:video_frame_idx+VIDEO_STEP), 'filled', 'g', 'MarkerFaceAlpha', MarkerFaceAlpha);
        frame = getframe(gcf,video_rect);
        writeVideo(video,frame);
    end
    
    turn_coordinates = [1.6 1.05;
                        2.5, -0.15;
                        4.2 1;
                        6.6 0.05;
                        6.7 5.0
                        4.45 2.2
                        1.8 5.3
                        -1.3 0.1];
    for turn_idx = 1:size(turn_coordinates, 1)
        scatter_scale = 200;
        dot_offset_x = 0.72;
        dot_offset_y = 0.55;
        text(turn_coordinates(turn_idx, 1), turn_coordinates(turn_idx, 2), strcat("T", num2str(turn_idx)), 'FontWeight', 'bold', 'FontSize', 60, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
        if default_results(results_line_number(v_iter), turn_idx) ~= 0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2), scatter_scale*default_results(results_line_number(v_iter), turn_idx), 'r', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
        if ablation_results(results_line_number(v_iter), turn_idx) ~=0
            scatter(turn_coordinates(turn_idx, 1), turn_coordinates(turn_idx, 2)-dot_offset_y, scatter_scale*ablation_results(results_line_number(v_iter), turn_idx), 'b', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
        if learned_results(results_line_number(v_iter), turn_idx) ~=0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2)-dot_offset_y, scatter_scale*learned_results(results_line_number(v_iter), turn_idx), 'g', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
    end
    
    frame = getframe(gcf,video_rect);
    writeVideo(video,frame);
    close(video)

    
end

