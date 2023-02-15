function [time, xs, ys, thetas] = read_experiments_localization(localization_file_name)
    
    localization_data = readmatrix(localization_file_name, 'OutputType', 'string', 'Delimiter', ',');
    
    time = zeros(size(localization_data, 1), 1);
    xs = zeros(size(localization_data, 1), 1);
    ys = zeros(size(localization_data, 1), 1);
    thetas = zeros(size(localization_data, 1), 1);
    
    for i = 1:size(localization_data, 1)
        time(i) = str2double(localization_data(i, 1))/10^9;
        xs(i) = str2double(localization_data(i, 9));
        ys(i) = str2double(localization_data(i, 10));
        thetas(i) = str2double(localization_data(i, 11));
        
    end
   
end

