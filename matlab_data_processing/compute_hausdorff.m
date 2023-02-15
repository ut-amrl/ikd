function [hausdorff_distance] = compute_hausdorff(all_xs_default, all_ys_default, nav_nodes, nav_edges)

clip_value = 1;

dist = 100*ones(size(all_xs_default));
for i = 1:length(all_xs_default)
    pt = [all_xs_default(i) all_ys_default(i)];
    for edge_idx = 1:size(nav_edges, 1)
        v1 = [nav_nodes(nav_edges(edge_idx, 1)+1, 1), nav_nodes(nav_edges(edge_idx, 1)+1, 2)];
        v2 = [nav_nodes(nav_edges(edge_idx, 2)+1, 1), nav_nodes(nav_edges(edge_idx, 2)+1, 2)];
        d = point_to_line_distance(pt, v1, v2);
        if dist(i) > d
            dist(i) = d;
        end
    end
end

dist(dist>clip_value) = clip_value;

hausdorff_distance = mean(dist);

