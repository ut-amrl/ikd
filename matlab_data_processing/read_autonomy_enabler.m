function [autonomy_enabler_data, autonomy_enabler_time, autonomy] = read_autonomy_enabler(autonomy_enabler_file_name)

    autonomy_enabler_data = readmatrix(autonomy_enabler_file_name, 'OutputType', 'string');
    autonomy_enabler_time = zeros(size(autonomy_enabler_data, 1), 1);
    autonomy = zeros(size(autonomy_enabler_data, 1), 1);
    
    for i = 1:size(autonomy_enabler_data, 1)
        autonomy_enabler_time(i) = str2double(autonomy_enabler_data(i, 1))/10^9;
        if autonomy_enabler_data(i, 2) == "True"
            autonomy(i) = 1;
        else
            autonomy(i) = 0;
        end
    end
end

