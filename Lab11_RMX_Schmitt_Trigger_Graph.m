% =========================================================================
% โค้ดสร้างรูปที่ 1.4: กราฟเปรียบเทียบสัญญาณ Analog และ Digital (Schmitt Trigger)
% อ้างอิงไฟเลี้ยง 0 - 3.3V และตั้งค่า Upper = 2.2V, Lower = 1.1V
% =========================================================================

% 1. สร้างแกนเวลา (Time) ตั้งแต่ 0 ถึง 10 วินาที
t = 0:0.01:10; 

% 2. สร้างสัญญาณ Analog ขาเข้า (จำลองการหมุน Potentiometer พร้อมสัญญาณรบกวน)
% ให้ระดับแรงดันสวิงเต็มที่ แต่ไม่เกินไฟเลี้ยง 0 - 3.3V
base_signal = 1.65 + 1.8 * sin(2*pi*0.2*t); % สร้างคลื่น Sine ให้ทะลุขอบเขตเล็กน้อย
noise = 0.15 * randn(size(t));              % เพิ่มสัญญาณรบกวน (Noise)
analog_signal = base_signal + noise;

% *** จำกัดแรงดันไม่ให้ต่ำกว่า 0V และไม่ให้เกิน 3.3V (เหมือนการทำงานจริงของบอร์ด) ***
analog_signal = max(0, min(3.3, analog_signal)); 

% 3. กำหนดค่าขอบเขต (Threshold) สำหรับ Schmitt Trigger
Upper_Threshold = 2.2; % ขีดจำกัดบน (V)
Lower_Threshold = 1.1; % ขีดจำกัดล่าง (V)

% 4. จำลองการทำงานของบล็อก Schmitt Trigger (Hysteresis Logic)
digital_signal = zeros(size(t));
current_state = 0; % สมมติให้เริ่มต้นที่สถานะ LOW (0V)

for i = 1:length(t)
    if analog_signal(i) >= Upper_Threshold
        current_state = 3.3; % เปลี่ยนเป็นสถานะ HIGH (3.3V)
    elseif analog_signal(i) <= Lower_Threshold
        current_state = 0;   % เปลี่ยนเป็นสถานะ LOW (0V)
    end
    digital_signal(i) = current_state; % บันทึกค่า
end

% =========================================================================
% 5. พล็อตกราฟเปรียบเทียบ
% =========================================================================
figure('Name', 'Schmitt Trigger Response (0-3.3V)', 'Position', [150, 150, 900, 500]);
hold on; grid on;

% 5.1 พล็อตสัญญาณ Analog (เส้นสีน้ำเงิน มีความโปร่งใสเล็กน้อย)
% ใช้ Color แบบ RGB + Alpha (0.7 คือความโปร่งใส)
plot(t, analog_signal, 'Color', [0 0.4470 0.7410 0.7], 'LineWidth', 1.5, ...
    'DisplayName', 'Analog Input (สัญญาณแรงดันดิบ 0-3.3V)');

% 5.2 พล็อตสัญญาณ Digital ขาออก (เส้นหนาสีส้ม)
plot(t, digital_signal, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.5, ...
    'DisplayName', 'Digital Output (คลื่นสี่เหลี่ยมหลังผ่าน Schmitt Trigger)');

% 5.3 พล็อตเส้นอ้างอิง Threshold (เส้นประ)
yline(Upper_Threshold, 'k--', 'Upper Threshold (2.2V)', 'LineWidth', 1.5, ...
    'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off', 'FontSize', 11);
yline(Lower_Threshold, '--', 'Lower Threshold (1.1V)', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5, ...
    'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off', 'FontSize', 11);

% 6. ตกแต่งกราฟให้สมบูรณ์สำหรับใส่รายงาน
title('รูปที่ 1.4 กราฟเปรียบเทียบสัญญาณ Analog ขาเข้าและสัญญาณ Digital ขาออกจาก Schmitt Trigger', ...
      'FontSize', 14, 'FontWeight', 'bold');
xlabel('เวลา Time (วินาที)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('แรงดันไฟฟ้า Voltage (V)', 'FontSize', 12, 'FontWeight', 'bold');

% ปรับขอบเขตแกน Y ให้มีพื้นที่ว่างด้านบนและล่างเล็กน้อย เพื่อให้เห็นขอบ 0V และ 3.3V ชัดๆ
ylim([-0.5 4.0]); 
set(gca, 'FontSize', 11, 'LineWidth', 1.2);

% จัดวางกล่องคำอธิบาย (Legend) ไว้มุมขวาบน
legend('Location', 'northeast', 'FontSize', 11);
hold off;

disp('>>> สร้างกราฟ Schmitt Trigger แบบอ้างอิงไฟเลี้ยง 3.3V สำเร็จ!');