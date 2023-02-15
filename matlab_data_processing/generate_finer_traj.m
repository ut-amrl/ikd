function [future_traj_finer] = generate_finer_traj(future_traj, INTERPOLATION_MULTIPLIER)
    
    X = future_traj(:, 1);
    Y = future_traj(:, 2);
    THETA = future_traj(:, 3);

    idx = 1:size(future_traj, 1);
    idx_finer = 1:(1/INTERPOLATION_MULTIPLIER):size(future_traj, 1);
    X_finer = spline(idx, X, idx_finer);
    Y_finer = spline(idx, Y, idx_finer);
    THETA_finer = spline(idx, THETA, idx_finer);
    
    future_traj_finer(:, 1) = X_finer';
    future_traj_finer(:, 2) = Y_finer';
    future_traj_finer(:, 3) = THETA_finer';


end

