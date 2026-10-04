% =========================================================================
% โค้ดสร้างกราฟ Taper Characteristics (แบบรวม 3 เส้นในหน้าต่างเดียว)
% =========================================================================
filename = 'Lab1_1_Potentiometer_Results.xlsx';
if ~isfile(filename)
    error('❌ ไม่พบไฟล์ %s กรุณาเช็คว่าไฟล์อยู่ใน Current Folder', filename);
end
T = readtable(filename);

% ระบุข้อมูลเพื่อใช้พล็อตกราฟ
sensors = ["Rotary1_A0", "Rotary2_A1", "Rotary3_A2"];
colors = ['r', 'b', 'g'];
legend_names = ["Sensor A", "Sensor B", "Sensor C"];

disp('>>> กำลังสร้างกราฟรวม 3 เส้นในหน้าต่างเดียว ...');

% 1. สร้างหน้าต่าง Figure กรอบใหญ่ขึ้นมาแค่ 1 อัน (ก่อนเข้าลูป)
figure('Name', 'Combined Taper Characteristics', 'Position', [150, 150, 700, 500]);
hold on; 
grid on; grid minor;

% 2. พล็อตเส้นประอุดมคติ (Linear Reference) พล็อตแค่ครั้งเดียว
plot([0 100], [0 100], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear');

% 3. วนลูปดึงข้อมูลทั้ง 3 ตัวมาพล็อตทับลงไปในหน้าต่างเดียวกัน
for i = 1:length(sensors)
    current_sensor = sensors(i);
    
    idx = strcmp(T.Sensor_Type, current_sensor);
    if any(idx)
        x = T.Scale_Value(idx); 
        v_out = T.V_out_V(idx);
        
        % แปลงแกน Y เป็นเปอร์เซ็นต์
        y = (v_out / 3.3) * 100; 
        
        % พล็อตข้อมูลจริงลงไป
        plot(x, y, '-o', 'Color', colors(i), 'MarkerFaceColor', colors(i), ...
             'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', legend_names(i));
    end
end

% 4. ตกแต่งกราฟโดยรวม
title('เปรียบเทียบคุณสมบัติของ Potentiometer (Taper Characteristics)', 'FontSize', 14);
xlabel('Rotational Travel (%)', 'FontSize', 12);
ylabel('Output Voltage (%)', 'FontSize', 12);

xlim([0 100]);
ylim([0 100]);
set(gca, 'FontSize', 11, 'LineWidth', 1.2);

% ใส่ Legend ไว้มุมบนซ้าย จะได้ไม่บังเส้นกราฟ
legend('Location', 'northwest', 'FontSize', 11);
hold off;