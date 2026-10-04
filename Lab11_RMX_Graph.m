% =========================================================================
% โค้ดวิเคราะห์ข้อมูล Lab 1.1: พล็อตกราฟ + แสดงผลใน Command Window (แบบดั้งเดิม)
% =========================================================================

filename = 'Lab1_1_Potentiometer_Results.xlsx';

if ~isfile(filename)
    error('❌ ไม่พบไฟล์ %s กรุณาเช็คว่าไฟล์อยู่ใน Current Folder', filename);
end
T = readtable(filename);
sensors = unique(T.Sensor_Type);
num_sensors = length(sensors);


% --- ส่วนที่ 1: วิเคราะห์ พล็อตกราฟเดี่ยว และแสดงผลแบบข้อความ ---
for i = 1:num_sensors
    current_sensor = sensors{i};
    sensor_data = T(strcmp(T.Sensor_Type, current_sensor), :);
    
    x = sensor_data.Scale_Value;
    y = sensor_data.V_out_V;
    
    % หาสมการเส้นตรง y = mx + c
    p = polyfit(x, y, 1);
    m = p(1); c = p(2);
    x_fit = linspace(min(x), max(x), 100);
    y_fit = polyval(p, x_fit);
    
    % คำนวณค่าความคลาดเคลื่อนสูงสุด (% Max Linearity Error)
    y_ideal = polyval(p, x); 
    errors = abs(y - y_ideal) / 3.3 * 100; 
    max_err = max(errors);
    
    % สร้างหน้าต่างกราฟเดี่ยว
    figure('Name', ['Single: ', char(current_sensor)], 'Position', [50+i*20, 50+i*20, 600, 450]);
    plot(x, y, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 6); hold on;
    plot(x_fit, y_fit, 'r-', 'LineWidth', 2);
    grid on;
    title(['Linearity Analysis: ', char(current_sensor)], 'FontSize', 12, 'Interpreter', 'none');
    
    if contains(current_sensor, 'mm')
        xlabel('Displacement (mm)');
    else
        xlabel('Scale (%)');
    end
    ylabel('Output Voltage (V)');
    
    eq_str = sprintf('y = %.4fx + %.4f', m, c);
    legend('Actual Data', ['Linear Fit (', eq_str, ')'], 'Location', 'northwest');
    hold off;
    
    % แสดงผลใน Command Window แบบพิมพ์ทีละบรรทัด (แบบเดิม)
    disp('--------------------------------------------------');
    disp(['Sensor: ', char(current_sensor)]);
    disp(['Equation: ', eq_str]);
    disp(['Sensitivity (Slope) = ', num2str(m, '%.4f')]);
    disp(['Offset (Zero Error) = ', num2str(c, '%.4f'), ' V']);
    disp(['Max Linearity Error = ', num2str(max_err, '%.4f'), ' %']);
end
disp('--------------------------------------------------');

% --- ส่วนที่ 2: พล็อตกราฟรวม (แยก Rotary กับ Linear) ---
is_linear = contains(sensors, 'mm');
rotary_sensors = sensors(~is_linear);
linear_sensors = sensors(is_linear);
colors = lines(max(length(rotary_sensors), length(linear_sensors))); 

if ~isempty(rotary_sensors)
    figure('Name', 'Combined: Rotary Sensors', 'Position', [700, 100, 700, 500]); hold on; leg_str = {};
    for i = 1:length(rotary_sensors)
        s = rotary_sensors{i};
        data_s = T(strcmp(T.Sensor_Type, s), :);
        x = data_s.Scale_Value; y = data_s.V_out_V;
        p = polyfit(x, y, 1);
        x_fit = linspace(min(x), max(x), 100); y_fit = polyval(p, x_fit);
        plot(x, y, 'o', 'MarkerFaceColor', colors(i,:), 'Color', colors(i,:));
        plot(x_fit, y_fit, '-', 'Color', colors(i,:), 'LineWidth', 1.5);
        leg_str{end+1} = [char(s), ' (Data)']; leg_str{end+1} = [char(s), sprintf(' Eq: y=%.4fx+%.4f', p(1), p(2))];
    end
    grid on; title('Combined Linearity: All Rotary Potentiometers', 'FontSize', 14);
    xlabel('Scale (%)', 'FontSize', 12); ylabel('Output Voltage (V)', 'FontSize', 12);
    legend(leg_str, 'Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none'); hold off;
end

if ~isempty(linear_sensors)
    figure('Name', 'Combined: Linear Sensors', 'Position', [750, 150, 700, 500]); hold on; leg_str = {};
    for i = 1:length(linear_sensors)
        s = linear_sensors{i};
        data_s = T(strcmp(T.Sensor_Type, s), :);
        x = data_s.Scale_Value; y = data_s.V_out_V;
        p = polyfit(x, y, 1);
        x_fit = linspace(min(x), max(x), 100); y_fit = polyval(p, x_fit);
        plot(x, y, '^', 'MarkerFaceColor', colors(i,:), 'Color', colors(i,:));
        plot(x_fit, y_fit, '-', 'Color', colors(i,:), 'LineWidth', 1.5);
        leg_str{end+1} = [char(s), ' (Data)']; leg_str{end+1} = [char(s), sprintf(' Eq: y=%.4fx+%.4f', p(1), p(2))];
    end
    grid on; title('Combined Linearity: All Linear Potentiometers', 'FontSize', 14);
    xlabel('Displacement (mm)', 'FontSize', 12); ylabel('Output Voltage (V)', 'FontSize', 12);
    legend(leg_str, 'Location', 'northwest', 'FontSize', 9, 'Interpreter', 'none'); hold off;
end
