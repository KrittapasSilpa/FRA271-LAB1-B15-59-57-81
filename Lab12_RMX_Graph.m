% =========================================================================
% โค้ดพล็อตกราฟสรุปผล Lab 1.2: Magnetic Sensor (Final Report)
% =========================================================================

% 1. โหลดข้อมูล (ดึงจาก Workspace ถ้ามี หรือโหลดจาก Excel)
if exist('experiment_results', 'var')
    df = experiment_results;
elseif exist('Lab1_2_Magnetic_MasterResults.xlsx', 'file')
    df = readtable('Lab1_2_Magnetic_MasterResults.xlsx');
else
    error('❌ ไม่พบข้อมูล! กรุณาตรวจสอบว่ามีตัวแปร หรือไฟล์ Excel อยู่ในโฟลเดอร์');
end

% 2. กรองข้อมูล: เอาเฉพาะที่มีแม่เหล็ก (ตัดบรรทัด No Magnet ออก)
valid_idx = upper(string(df.Has_Magnet)) == "Y";
df_valid = df(valid_idx, :);

% 3. สร้างตัวแปรจัดกลุ่ม (ชื่อขั้ว + สถานะ Shield)
conditions = strcat(string(df_valid.Magnetic_Pole), " + ", string(df_valid.Shield_Status));
unique_conds = unique(conditions);
num_conds = length(unique_conds);

% ตั้งค่าสีและสัญลักษณ์จุด (Marker) ให้ดูเป็นมืออาชีพ
colors = [0 0.4470 0.7410;   % น้ำเงิน
          0.8500 0.3250 0.0980;   % ส้ม
          0.9290 0.6940 0.1250;   % เหลือง
          0.4940 0.1840 0.5560];  % ม่วง
markers = {'o', 's', '^', 'd'};

% =========================================================================
% รูปที่ 1: พล็อตรวม 4 เส้นในกราฟเดียว (Combined Plot)
% =========================================================================
figure('Name', 'Combined Plot: B vs Distance', 'Position', [100, 100, 800, 500]);
hold on; grid on;

for i = 1:num_conds
    % ดึงข้อมูลเฉพาะกลุ่มที่ i
    idx = (conditions == unique_conds(i));
    dist = df_valid.Distance_mm(idx);
    B_val = df_valid.B_mT(idx);
    
    % พล็อตเส้น
    plot(dist, B_val, '-', 'Marker', markers{i}, 'Color', colors(i,:), ...
         'MarkerFaceColor', colors(i,:), 'LineWidth', 2, 'MarkerSize', 6, ...
         'DisplayName', unique_conds(i));
end

% ตกแต่งกราฟรวม
title('เปรียบเทียบความเข้มสนามแม่เหล็ก (B) ทั้ง 4 เงื่อนไข', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('ระยะห่าง Distance (mm)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('ความเข้มสนามแม่เหล็ก B (mT)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
xlim([0 max(df_valid.Distance_mm)+2]); % ขยายขอบแกน X นิดหน่อยให้ดูสวย

% =========================================================================
% รูปที่ 2: พล็อตแยก 4 กราฟ (Separated Subplots)
% =========================================================================
figure('Name', 'Separated Plots: B vs Distance', 'Position', [150, 150, 1000, 600]);

for i = 1:num_conds
    idx = (conditions == unique_conds(i));
    dist = df_valid.Distance_mm(idx);
    B_val = df_valid.B_mT(idx);
    
    % สร้างหน้าต่างย่อย 2x2
    subplot(2, 2, i);
    plot(dist, B_val, '-', 'Marker', markers{i}, 'Color', colors(i,:), ...
         'MarkerFaceColor', colors(i,:), 'LineWidth', 2);
    grid on;
    
    % จัดชื่อกราฟย่อย (เอาคำว่า + ออก เปลี่ยนเป็นขึ้นบรรทัดใหม่)
    title_str = strrep(unique_conds(i), " + ", char(10));
    title(title_str, 'FontSize', 12);
    
    xlabel('Distance (mm)');
    ylabel('B (mT)');
    xlim([0 max(dist)+2]);
end

% ใส่หัวข้อใหญ่คลุมรูปที่ 2
sgtitle('กราฟแยกชุดข้อมูลความเข้มสนามแม่เหล็กตามเงื่อนไขการทดลอง', 'FontSize', 16, 'FontWeight', 'bold');
disp('พล็อตกราฟสำเร็จ! เปิดหน้าต่าง Figure เพื่อดูผลลัพธ์ได้เลยครับ');