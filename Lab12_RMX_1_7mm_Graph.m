% =========================================================================
% โค้ดสร้างรูปที่ 2.4: กราฟแสดงสภาวะอิ่มตัว (ขั้วเหนือ North - มี Shield)
% =========================================================================

% 1. โหลดข้อมูล
filename = 'Lab1_2_Magnetic_MasterResults.xlsx';
if ~exist(filename, 'file')
    error('❌ ไม่พบไฟล์ %s', filename);
end
df = readtable(filename);

% 2. กรองข้อมูลเอาเฉพาะ ขั้วเหนือ (North) และ ใส่ Shield 
% (ใช้ string() ป้องกัน Error จาก Cell Array)
idx = (string(df.Has_Magnet) == "Y") & contains(string(df.Magnetic_Pole), "North") & contains(string(df.Shield_Status), "With Shield");

dist = df.Distance_mm(idx);
B_val = df.B_mT(idx);

% 3. สร้างกราฟ
figure('Name', 'Saturation Region (North)', 'Position', [150, 150, 750, 450]);
hold on; grid on;

% 4. ไฮไลท์แถบสีแดงเพื่อชี้จุด Saturation (ระยะ 0 ถึง 7.5 mm)
if ~isempty(B_val)
    y_min = min(B_val) - 5; 
else
    y_min = -35; 
end
y_max = 5; % ตั้งเผื่อไว้เหนือ 0 นิดหน่อย
patch([0 7.5 7.5 0], [y_min y_min y_max y_max], [1 0.4 0.4], ...
      'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', 'ช่วงเซนเซอร์อิ่มตัว (Saturation)');

% 5. พล็อตเส้นกราฟข้อมูลจริง (ใช้สีส้มแดง)
plot(dist, B_val, '-o', 'Color', [0.8500 0.3250 0.0980], 'MarkerFaceColor', [0.8500 0.3250 0.0980], ...
     'LineWidth', 2.5, 'MarkerSize', 6, 'DisplayName', 'North (N) - With Shield');

% 6. เพิ่มลูกศรและข้อความชี้เป้าความแบนราบ
if ~isempty(B_val)
    x_flat = 4;
    y_flat = min(B_val); % ขั้วเหนือค่าจะติดลบมากที่สุดตอนอิ่มตัว
    text(x_flat, y_flat + 2.5, 'Sensor Saturation (กราฟแบนราบชนขีดจำกัดล่าง)', ...
        'FontSize', 11, 'Color', 'red', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end

% 7. ตกแต่งกราฟ
title('กราฟแสดงสภาวะอิ่มตัว (Saturation) ของเซนเซอร์ (ช่วงระยะ 1-7 mm)', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('ระยะห่าง Distance (mm)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('ความเข้มสนามแม่เหล็ก B (mT)', 'FontSize', 12, 'FontWeight', 'bold');

% จำกัดแกน X ให้โชว์แค่ถึงระยะ 22 mm 
xlim([0 22]);
ylim([y_min y_max]);
set(gca, 'FontSize', 11, 'LineWidth', 1.2);
legend('Location', 'southeast', 'FontSize', 11);
hold off;

disp('>>> สร้างรูปที่ 2.4 (เวอร์ชันขั้วเหนือ) เสร็จเรียบร้อย!');