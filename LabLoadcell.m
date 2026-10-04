% ========================================================
% MATLAB Script: Load Cell Analysis (Direct Weight Input)
% ========================================================
clc; close all;

% 1. กรอกค่าน้ำหนักจริงจากเครื่องชั่ง Digital (หน่วย: kg)
% สามารถพิมพ์ทศนิยมแก้ไขตัวเลขตรงนี้ได้ทันทีเมื่อเปลี่ยนน้ำหนัก
actual_weight = [0, 0.969, 1.939, 2.935, 3.925, 4.900, 5.960, 6.940, 7.980, 8.932, 9.780];

% 2. รวมค่าข้อมูลที่บันทึกอัตโนมัติจาก Workspace
adc_raw         = [a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10];
v_out           = [v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10];
measured_weight = [m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10];
%[a0, v0, m0] = deal(mean(adc_sim), mean(volt_sim), mean(weight_sim))
%คำสั่ง

% 3. คำนวณ % Error และ Linearity (R-squared)
percent_error = zeros(size(actual_weight));
for i = 1:length(actual_weight)
    if actual_weight(i) == 0
        percent_error(i) = 0;
    else
        percent_error(i) = abs((measured_weight(i) - actual_weight(i)) / actual_weight(i)) * 100;
    end
end

p = polyfit(actual_weight, measured_weight, 1);
y_fit = polyval(p, actual_weight);
SS_tot = sum((measured_weight - mean(measured_weight)).^2);
SS_res = sum((measured_weight - y_fit).^2);
R_squared = 1 - (SS_res / SS_tot);

% 4. แสดงตารางบันทึกผลการทดลองใน Command Window
ResultTable = table(actual_weight', v_out', adc_raw', measured_weight', percent_error', ...
    'VariableNames', {'Digital_kg', 'Voltage_V', 'ADC_Count', 'Simulink_kg', 'Percent_Error'});
disp('================ ตารางบันทึกผลการทดลอง (ฉบับสมบูรณ์) ================');
disp(ResultTable);
fprintf('ค่าความเชิงเส้น (R-squared / Linearity) = %.4f\n\n', R_squared);

% 5. พล็อตกราฟรายงานผลแล็บ
figure('Name', 'Load Cell Calibration Report', 'Color', [1 1 1]);

% --- กราฟด้านบน: Linearity ---
subplot(2,1,1);
plot(actual_weight, measured_weight, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'b'); hold on;
plot(actual_weight, actual_weight, 'r--', 'LineWidth', 1.5);
grid on; grid minor;
title(['Load Cell Calibration Curve (R^2 = ', num2str(R_squared, '%.4f'), ')'], 'FontSize', 12);
xlabel('Digital Scale Weight (kg)'); ylabel('Simulink Measured Weight (kg)');
legend('Measured Data', 'Ideal Line (1:1)', 'Location', 'northwest');

% --- กราฟด้านล่าง: % Error ---
subplot(2,1,2);
bar(actual_weight, percent_error, 'FaceColor', [0.2 0.6 0.8]);
grid on; grid minor;
title('Percentage Error vs Actual Weight', 'FontSize', 12);
xlabel('Digital Scale Weight (kg)'); ylabel('% Error');
