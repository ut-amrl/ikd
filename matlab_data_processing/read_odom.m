function [odom_time, odom_vs, odom_ws] = read_odom(odom_file_name)
    
    odom_data = readmatrix(odom_file_name, 'OutputType', 'string', 'Delimiter', ',');
    
    odom_time = zeros(size(odom_data, 1), 1);
    odom_vs = zeros(size(odom_data, 1), 1);
    odom_ws = zeros(size(odom_data, 1), 1);
    
    for i = 1:size(odom_data, 1)
        odom_time(i) = str2double(odom_data(i, 1))/10^9;
        odom_vs(i) = str2double(odom_data(i, 24));
        odom_ws(i) = str2double(odom_data(i, 30));
    end
   
end

