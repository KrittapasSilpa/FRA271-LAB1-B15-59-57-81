% =========================================================================
% โค้ดสร้างกราฟ Taper Characteristics สำหรับกลุ่ม Linear (A0, A1)
% แบบแยกหน้าต่าง เพื่อพิสูจน์พฤติกรรม
% =========================================================================

filename = 'Lab1_1_Potentiometer_Results.xlsx';

if ~isfile(filename)
    error('❌ ไม่พบไฟล์ %s กรุณาเช็คว่าไฟล์อยู่ใน Current Folder', filename);
end
T = readtable(filename);

% ระบุชื่อเซนเซอร์กลุ่ม Linear ตามที่บันทึกไว้ในตาราง
sensors = ["Linear1_A0 (mm)", "Linear2_A1 (mm)"];
colors = ['r', 'b'];
titles = ["Linear Sensor: A0 Characteristics", ...
    "Linear Sensor: A1 Characteristics"];

disp('>>> กำลังสร้างกราฟสำหรับกลุ่ม Linear ...');

for i = 1:length(sensors)
    current_sensor = sensors(i);

    idx = strcmp(T.Sensor_Type, current_sensor);
    if any(idx)
        % ดึงระยะทางจริง (0-60 mm) แล้วแปลงเป็นเปอร์เซ็นต์ (0-100%) ของระยะทางสูงสุด
        dist_mm = T.Scale_Value(idx); 
        x = (dist_mm / 60) * 100; 

        % ดึงค่าโวลต์ แล้วแปลงเป็นเปอร์เซ็นต์ (0-100%) ของแรงดันสูงสุด 3.3V
        v_out = T.V_out_V(idx);
        y = (v_out / 3.3) * 100; 

        % สร้างหน้าต่าง Figure ใหม่
        figure('Name', char(current_sensor), 'Position', [100+i*50, 400, 600, 450]);
        hold on;

        % พล็อตเส้นประอุดมคติ (Ideal Linear 0-100%)
        plot([0 100], [0 100], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear');

        % พล็อตข้อมูลจริง
        plot(x, y, '-^', 'Color', colors(i), 'MarkerFaceColor', colors(i), ...
            'LineWidth', 2, 'MarkerSize', 6, 'DisplayName', 'Actual Data');

        % ตกแต่งกราฟ
        grid on; grid minor;
        title(titles(i), 'FontSize', 14, 'Interpreter', 'none');
        xlabel('Slide Travel (%)', 'FontSize', 12);
        ylabel('Output Voltage (%)', 'FontSize', 12);

        xlim([0 100]);
        ylim([0 100]);
        set(gca, 'FontSize', 11, 'LineWidth', 1.2);
        legend('Location', 'northwest', 'FontSize', 11);
        hold off;
    end
end