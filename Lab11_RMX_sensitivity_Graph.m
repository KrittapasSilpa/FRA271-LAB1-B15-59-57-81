% =========================================================================
% โค้ดวิเคราะห์การตอบสนอง (Response Analysis) แบบแยกกราฟรายตัว
% สำหรับ Potentiometer ทั้ง 5 ตัว
% =========================================================================

filename = 'Lab1_1_Potentiometer_Results.xlsx';

if ~isfile(filename)
    error('❌ ไม่พบไฟล์ %s กรุณาเช็คว่าไฟล์อยู่ใน Current Folder', filename);
end
T = readtable(filename);

% รายชื่อเซนเซอร์ทั้ง 5 ตัว
sensors = ["Rotary1_A0", "Rotary2_A1", "Rotary3_A2", "Linear1_A0 (mm)", "Linear2_A1 (mm)"];
titles = ["Rotary A0 (A Series: Logarithmic)", ...
          "Rotary A1 (B Series: Linear)", ...
          "Rotary A2 (C Series: Anti-Log)", ...
          "Linear A0 (A Series: Logarithmic)", ...
          "Linear A1 (B Series: Linear)"];

disp('>>> กำลังสร้างกราฟวิเคราะห์แยกรายตัว ...');

for i = 1:length(sensors)
    current_sensor = sensors(i);
    idx = strcmp(T.Sensor_Type, current_sensor);
    
    if any(idx)
        x_raw = T.Scale_Value(idx); 
        y = T.V_out_V(idx);
        
        % แปลงระยะสไลด์ (0-60mm) ให้เป็น 0-100% เพื่อใช้สเกลเดียวกัน
        if contains(current_sensor, 'mm')
            x = (x_raw / 60) * 100;
        else
            x = x_raw;
        end
        
        % คำนวณ Sensitivity และ Offset
        sens = gradient(y) ./ gradient(x);
        p = polyfit(x, y, 1);
        offset = p(2);
        
        % สร้างหน้าต่างแยกสำหรับแต่ละเซนเซอร์
        figure('Name', char(current_sensor), 'Position', [50+i*30, 200, 1000, 450]);
        
        % --- กราฟซ้าย: Voltage Response ---
        subplot(1, 2, 1); hold on; grid on; grid minor;
        plot([0 100], [0 3.3], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear Response');
        plot(x, y, '-o', 'Color', 'b', 'MarkerFaceColor', 'b', 'LineWidth', 2, 'DisplayName', 'Actual Data');
        
        title(['Voltage Response: ', char(titles(i))], 'FontSize', 12);
        xlabel('Travel Distance / Rotation (%)', 'FontSize', 11);
        ylabel('Output Voltage (V)', 'FontSize', 11);
        legend('Location', 'northwest', 'FontSize', 10);
        xlim([0 100]); ylim([0 3.5]);
        
        % --- กราฟขวา: Sensitivity & Offset ---
        subplot(1, 2, 2); hold on; grid on; grid minor;
        yline(0.033, 'k--', 'Ideal Sensitivity (0.033 V/%)', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'center');
        plot(x, sens, '-s', 'Color', '#D95319', 'MarkerFaceColor', '#D95319', 'LineWidth', 2);
        
        title(sprintf('Sensitivity (Offset = %.4f V)', offset), 'FontSize', 12);
        xlabel('Travel Distance / Rotation (%)', 'FontSize', 11);
        ylabel('Sensitivity (V / %)', 'FontSize', 11);
        xlim([0 100]);
        
        % ปรับสเกลแกน Y ของ Sensitivity ให้เห็นการแกว่งชัดเจน
        if max(sens) > 0.05
            ylim([0 max(sens)*1.2]);
        else
            ylim([0 0.05]);
        end
    end
end
