function [joystick_data, joystick_data_time, velocity, curvature] = read_joystick(joystick_file_name)
    
    joystick_tolerance = 0.0001;
    
    max_velocity = 3;
    kMaxTurnRate = 0.41708264;
    wb = 0.324;

    joystick_data = readmatrix(joystick_file_name, 'OutputType', 'string', 'Delimiter', ',');
    
    joystick_data_time = [];
    velocity = [];
    curvature = [];

    for i = 1:size(joystick_data, 1)
        buttons_value = convertStringsToChars(joystick_data(i, 9));
        buttons_value(1) = [];
        buttons_value(end) = [];
        buttons_value = strsplit(buttons_value, ',');
        in_joystick_mode = str2num(buttons_value{5});
        
        if in_joystick_mode == 1
        
            axes_value = convertStringsToChars(joystick_data(i, 8));
            axes_value(1) = [];
            axes_value(end) = [];
            axes_value = strsplit(axes_value, ',');
            steer_joystick = -str2num(axes_value{1}); % steer value is negative
            drive_joystick = -str2num(axes_value{5}); % drive value is negative
            if abs(steer_joystick) < joystick_tolerance
                steer_joystick = 0;
            end
            if abs(drive_joystick) < joystick_tolerance
                drive_joystick = 0;
            end
            
            joystick_data_time = [joystick_data_time; str2double(joystick_data(i, 1))/10^9];
            velocity = [velocity; drive_joystick * max_velocity];
            curvature = [curvature; tan(steer_joystick * kMaxTurnRate) / wb];
        end
        
    end

end

