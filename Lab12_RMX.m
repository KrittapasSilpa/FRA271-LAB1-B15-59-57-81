% =========================================================================
% โค้ด V6: Auto Trigger (ดึงข้อมูลอัตโนมัติตามจังหวะ Pulse Generator)
% =========================================================================

% 1. ดึงข้อมูลเวลาและค่าสัญญาณ (รองรับทั้งรูปแบบ Time/Data ตัวพิมพ์เล็กและใหญ่)
try
    t = sensor_data.Time;
    v_sensor = sensor_data.Data;  
    v_button = button_data.Data;  
catch
    t = sensor_data.time;
    v_sensor = sensor_data.data;  
    v_button = button_data.data;  
end

% 2. ให้โปรแกรมถามเงื่อนไขการทดลอง
disp('========== ตั้งค่าเงื่อนไขสำหรับการทดลองรอบนี้ ==========');
has_magnet = input('มีแม่เหล็กหรือไม่? (พิมพ์ Y = มี, N = ไม่มี): ', 's');

if upper(has_magnet) == 'Y'
    pole = input('ระบุขั้วแม่เหล็ก (พิมพ์ N = ขั้วเหนือ/North, S = ขั้วใต้/South): ', 's');
    shield = input('ใส่แผ่น Shield หรือไม่? (พิมพ์ Y = ใส่, N = ไม่ใส่): ', 's');
    start_dist = input('ระยะเริ่มต้น (mm) [เช่น 0]: ');
    step_size = input('ขยับทีละกี่มิลลิเมตร (mm) [เช่น 2]: '); 
    
    if upper(pole) == 'N', pole_str = 'North (N)'; else, pole_str = 'South (S)'; end
    if upper(shield) == 'Y', shield_str = 'With Shield'; else, shield_str = 'No Shield'; end
else
    pole_str = 'No Magnet'; shield_str = 'N/A'; start_dist = 0; step_size = 0;
end
disp('======================================================');

% 3. พารามิเตอร์เซนเซอร์ DRV5055
V_Q = 1603.16;       
Sensitivity = 60;    
S_TC = 0.0012;       
Temp_Factor = 1 + (S_TC * (25 - 25));

% 4. ระบบกวาดหาจังหวะจาก Pulse Generator
is_pressed = v_button > 2000; % มองหาจังหวะที่กราฟ Trigger เด้งเกิน 2000
edges = diff([0; is_pressed; 0]);
start_idx = find(edges == 1);
end_idx = find(edges == -1) - 1;

new_rows = [];
figure('Name', 'Auto Trigger Result', 'Position', [100, 100, 900, 400]);
hold on; grid on;
plot(t, v_sensor, 'Color', [0.8 0.8 0.8], 'DisplayName', 'Raw Data (A0)');
plot(t, v_button * (3000/4095), 'Color', [1 0.6 0.2], 'LineWidth', 1, 'DisplayName', 'Auto Trigger'); 

% 5. คำนวณค่าเฉพาะจุดที่ถูก Trigger
for i = 1:length(start_idx)
    idx = start_idx(i):end_idx(i);
    
    % ถ้า Trigger สั้นกว่า 1 วินาที ให้ข้าม (ป้องกัน Noise แหลมๆ)
    if (t(end_idx(i)) - t(start_idx(i))) > 1.0
        
        raw_mean = mean(v_sensor(idx));            
        V_out_mV = raw_mean * (3300 / 4095);        
        B_mT = (V_out_mV - V_Q) / (Sensitivity * Temp_Factor); 
        
        distance = start_dist + ((i - 1) * step_size); 
        mid_time = mean(t(idx));
        
        % พล็อตจุดสีน้ำเงินทับจังหวะที่ดึงข้อมูลมาคิด
        plot(t(idx), v_sensor(idx), 'b', 'LineWidth', 3, 'HandleVisibility', 'off');
        text(mid_time, raw_mean + 100, sprintf('%d mm', distance), 'HorizontalAlignment', 'center', 'FontSize', 9);
        
        row = table(string(has_magnet), string(pole_str), string(shield_str), ...
                    distance, raw_mean, V_out_mV, B_mT, ...
                    'VariableNames', {'Has_Magnet', 'Magnetic_Pole', 'Shield_Status', ...
                                      'Distance_mm', 'Raw_Signal', 'V_out_mV', 'B_mT'});
        new_rows = [new_rows; row];
    end
end
title('ผลลัพธ์การใช้ Auto Trigger (ขีดสีน้ำเงินคือช่วงที่ถูกดึงข้อมูล)');
xlabel('เวลา (วินาที)'); ylabel('Signal Level');
legend('Location', 'best');

% 6. บันทึกผลลง Excel
if exist('experiment_results', 'var')
    experiment_results = [experiment_results; new_rows]; 
else
    experiment_results = new_rows; 
end

disp('--- ข้อมูลที่ดึงมาจากจังหวะ Trigger ---');
disp(new_rows);
excel_filename = 'Lab1_2_Magnetic_MasterResults.xlsx';
writetable(experiment_results, excel_filename);
fprintf('>>> สกัดข้อมูลสำเร็จ บันทึกสะสมลงไฟล์ %s เรียบร้อยแล้ว\n', excel_filename);