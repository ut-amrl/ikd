clear
clc
close all

MarkerFaceAlpha = 0.2;

MAX_Vs = ["2.4", "2.5", "2.6", "2.7", "2.8"];
% MAX_Vs = ["2.8"];
results_line_number = [1 2 3 4 5];

default_results = [10 0 4 1;
                   10 0 6 3;
                   8 0 7 0;
                   8 0 10 5;
                   10 0 10 9;]; % line is velocity, column is corner index
               
learned_results = [0 0 0 1;
                   1 0 0 3;
                   2 1 2 1;
                   2 2 2 1;
                   1 1 6 0];

               
               
%% plot success rate each method each velocity
% all_default_success = zeros(size(MAX_Vs, 1), 1);
% all_learned_success = zeros(size(MAX_Vs, 1), 1);
% for v_iter = 1:length(MAX_Vs)
%     all_default_success(v_iter, 1) = (1 - sum(default_results(v_iter, :)) / (10*4))*100;
%     all_learned_success(v_iter, 1) = (1 - sum(learned_results(v_iter, :)) / (10*4))*100;
% end
% 
% all_success = [all_default_success all_learned_success];
% figure()
% set(gcf, 'WindowState', 'maximized');
% hold on
% all_failure = 100 - all_success;
% b = bar(all_failure,'FaceColor','flat');
% set(gca, 'XTickLabel', {'2.4m/s',' ', '2.5m/s',' ','2.6 m/s',' ','2.7m/s',' ','2.8m/s',' '}, 'FontWeight', 'bold', 'FontSize', 27)
% title({'Failure Turn Rate per Speed (%)', '(Unseen Terrain)'}, 'FontWeight', 'bold', 'FontSize', 55)
% bar_colors = [1 0 0; 0 1 0;];
% for k = 1:size(all_success,2)
%     b(k).CData = bar_colors(k, :);
% end
% legend('Baseline', 'Learning', 'location', 'best', 'FontSize', 40)
% success_rate = mean(all_success, 1)

%% plot success rate each method each turn
% all_default_success = zeros(1, 4);
% all_learned_success = zeros(1, 4);
% for turn_iter = 1:4
%     all_default_success(1, turn_iter) = (1 - sum(default_results(:, turn_iter)) / (length(MAX_Vs)*10))*100;
%     all_learned_success(1, turn_iter) = (1 - sum(learned_results(:, turn_iter)) / (length(MAX_Vs)*10))*100;
% end
% 
% all_success = [all_default_success' all_learned_success'];
% figure()
% set(gcf, 'WindowState', 'maximized');
% hold on
% set(gca, 'XTickLabel', {'T1',' ','T2' '','T3',' ','T4',' '}, 'FontWeight', 'bold', 'FontSize', 30)
% title({'Failure Turn Rate per Turn (%)', '(Unseen Terrain)'}, 'FontWeight', 'bold', 'FontSize', 55)
% all_failure = 100 - all_success;
% b = bar(all_failure,'FaceColor','flat');
% bar_colors = [1 0 0; 0 1 0;];
% for k = 1:size(all_success,2)
%     b(k).CData = bar_colors(k, :);
% end
% legend('Baseline', 'Learning', 'location', 'best', 'FontSize', 40)
% success_rate = mean(all_success, 1)


hausdorff_default = zeros(size(MAX_Vs));
hausdorff_learned = zeros(size(MAX_Vs));
for v_iter = 1:length(MAX_Vs)
    figure(v_iter+2)
    set(gcf, 'WindowState', 'maximized');
%     subplottight(2, 5, v_iter)
    hold on
    axis equal
    xlim([-2.1, 3.3])
    ylim([-0.9, 6.1])
    
    %% plot map and path
    vectors = readmatrix("/home/xuesu/amrl_libraries/amrl_maps/xx_living_room/xx_living_room.vectormap.txt");
    for vector_idx = 1:size(vectors, 1)
        plot([vectors(vector_idx, 1), vectors(vector_idx, 3)], [vectors(vector_idx, 2), vectors(vector_idx, 4)], 'Color', [0.5,0.5,0.5], 'LineWidth', 10)
    end
    nav_nodes = [-0.46561530232429504, 0.007218841928988695;
                 1.7072560787200928, 0.01443768385797739;
                 2.486891031265259, 0.8806987404823303;
                 2.5485949516296387, 3.0473697185516357;
                 1.2193843126296997, 4.216158390045166;
                 -0.4001137912273407, 4.666867733001709;
                 -1.1716670989990234, 3.650861978530884;
                 -1.018884301185608, 0.8167399764060974];
    nav_edges = [0 1;
                 1 2;
                 2 3;
                 3 4;
                 4 5;
                 5 6;
                 6 7;
                 7 0];
    for edge_idx = 1:size(nav_edges, 1)
        plot([nav_nodes(nav_edges(edge_idx, 1)+1, 1), nav_nodes(nav_edges(edge_idx, 2)+1, 1)], [nav_nodes(nav_edges(edge_idx, 1)+1, 2), nav_nodes(nav_edges(edge_idx, 2)+1, 2)], 'Color', [0,0,0], 'LineWidth', 4)
    end
    
    %% default
    default_folder_name = strcat("generalizability_test/generalizability_default/default_", MAX_Vs(v_iter), "_1");
    
    localization_file_name = strcat(default_folder_name, "/_slash_localization.csv");
    [time, all_xs_default, all_ys_default, thetas] = read_experiments_localization(localization_file_name);
    scatter(all_xs_default, all_ys_default, 'filled', 'r', 'MarkerFaceAlpha', MarkerFaceAlpha)
%     hausdorff_default(v_iter) = compute_hausdorff(all_xs_default, all_ys_default, nav_nodes, nav_edges);
    
    %% learned
    learned_folder_name = strcat("generalizability_test/generalizability_learned/learned_", MAX_Vs(v_iter), "_1");
    
    localization_file_name = strcat(learned_folder_name, "/_slash_localization.csv");
    [time, all_xs_learned, all_ys_learned, thetas] = read_experiments_localization(localization_file_name);
        
    scatter(all_xs_learned, all_ys_learned, 'filled', 'g', 'MarkerFaceAlpha', MarkerFaceAlpha)
%     hausdorff_learned(v_iter) = compute_hausdorff(all_xs_learned, all_ys_learned, nav_nodes, nav_edges);
    
    %% corner results
    turn_coordinates = [1.2 1.1;
                        1.2 2.8;
                        -0.4 3.2;
                        -0.4 1.3
                        ];
    for turn_idx = 1:size(turn_coordinates, 1)
        scatter_scale = 200;
        dot_offset_x = 0.72;
        dot_offset_y = 0.55;
        text(turn_coordinates(turn_idx, 1), turn_coordinates(turn_idx, 2), strcat("T", num2str(turn_idx)), 'FontWeight', 'bold', 'FontSize', 60, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
        if default_results(results_line_number(v_iter), turn_idx) ~= 0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2), scatter_scale*default_results(results_line_number(v_iter), turn_idx), 'r', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
        if learned_results(results_line_number(v_iter), turn_idx) ~=0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2)-dot_offset_y, scatter_scale*learned_results(results_line_number(v_iter), turn_idx), 'g', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
    end

%% video 
    video_name = strcat("video_generalizability_", MAX_Vs(v_iter));
    video = VideoWriter(video_name);
    open(video)
    VIDEO_STEP = int16(50 * str2num(MAX_Vs(v_iter)));
    video_rect = [620 80 670 850];
    
    frame = getframe(gcf,video_rect);
    writeVideo(video,frame);
    
    clf;
    
    hold on
    axis equal
    xlim([-2.1, 3.3])
    ylim([-0.9, 6.1])
    
    vectors = readmatrix("/home/xuesu/amrl_libraries/amrl_maps/xx_living_room/xx_living_room.vectormap.txt");
    for vector_idx = 1:size(vectors, 1)
        plot([vectors(vector_idx, 1), vectors(vector_idx, 3)], [vectors(vector_idx, 2), vectors(vector_idx, 4)], 'Color', [0.5,0.5,0.5], 'LineWidth', 10)
    end
    nav_nodes = [-0.46561530232429504, 0.007218841928988695;
                 1.7072560787200928, 0.01443768385797739;
                 2.486891031265259, 0.8806987404823303;
                 2.5485949516296387, 3.0473697185516357;
                 1.2193843126296997, 4.216158390045166;
                 -0.4001137912273407, 4.666867733001709;
                 -1.1716670989990234, 3.650861978530884;
                 -1.018884301185608, 0.8167399764060974];
    nav_edges = [0 1;
                 1 2;
                 2 3;
                 3 4;
                 4 5;
                 5 6;
                 6 7;
                 7 0];
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
    
    for video_frame_idx = 1:VIDEO_STEP:(size(all_xs_learned, 1)-VIDEO_STEP)
        fig = scatter(all_xs_learned(video_frame_idx:video_frame_idx+VIDEO_STEP), all_ys_learned(video_frame_idx:video_frame_idx+VIDEO_STEP), 'filled', 'g', 'MarkerFaceAlpha', MarkerFaceAlpha);
        frame = getframe(gcf,video_rect);
        writeVideo(video,frame);
    end
    
    turn_coordinates = [1.2 1.1;
                        1.2 2.8;
                        -0.4 3.2;
                        -0.4 1.3
                        ];
    for turn_idx = 1:size(turn_coordinates, 1)
        scatter_scale = 200;
        dot_offset_x = 0.72;
        dot_offset_y = 0.55;
        text(turn_coordinates(turn_idx, 1), turn_coordinates(turn_idx, 2), strcat("T", num2str(turn_idx)), 'FontWeight', 'bold', 'FontSize', 60, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
        if default_results(results_line_number(v_iter), turn_idx) ~= 0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2), scatter_scale*default_results(results_line_number(v_iter), turn_idx), 'r', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
        if learned_results(results_line_number(v_iter), turn_idx) ~=0
            scatter(turn_coordinates(turn_idx, 1)+dot_offset_x, turn_coordinates(turn_idx, 2)-dot_offset_y, scatter_scale*learned_results(results_line_number(v_iter), turn_idx), 'g', 'filled', 'MarkerEdgeColor',[0 0 0], 'LineWidth', 2)
        end
    end
    
    frame = getframe(gcf,video_rect);
    writeVideo(video,frame);
    close(video)
    
end
