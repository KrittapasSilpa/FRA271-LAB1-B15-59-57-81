% =========================================================================
% MASTER SCRIPT V4: โชว์กราฟบนจอ + เซฟกราฟรวม + เซฟกราฟแยก + Backup .mat
% =========================================================================
clc;
disp('--- เริ่มต้นประมวลผล Lab 1.3 ---');
disp('1: AMT103-V (รุ่นอุตสาหกรรม)');
disp('2: BOURNS (รุ่นลูกบิด)');
enc_choice = input('👉 เลือกรุ่น Encoder (พิมพ์เลข 1 หรือ 2): ');
if enc_choice == 1
    Encoder_Name = 'AMT103';
elseif enc_choice == 2
    Encoder_Name = 'BOURNS';
else
    error('เลือกตัวเลขไม่ถูกต้อง กรุณารันใหม่ครับ');
end
mode_choice = input('👉 พิมพ์โหมดที่ใช้ (เช่น X1, X2, X4): ', 's');
Read_Mode = upper(strtrim(mode_choice)); 
prefix = sprintf('%s_%s', Encoder_Name, Read_Mode);

% =========================================================================
% 2. ดึงข้อมูลทุกเส้น
Time_Full = data.get('A0').Values.Time;
PhaseA = data.get('A0').Values.Data;
PhaseB = data.get('A1').Values.Data;

% 👉 อัปเกรด: ให้โค้ดประกอบชื่อเส้นอัตโนมัติตามโหมดที่พิมพ์ (เช่น 'Encoder' + 'X2' = 'EncoderX2')
Count_Name = ['Encoder' Read_Mode]; 
Count = data.get(Count_Name).Values.Data; 

% ค้นหาเส้น Pulse อัตโนมัติ (ข้ามเส้น A0, A1 และ EncoderX?)
all_names = data.getElementNames;
pulse_idx = find(~ismember(all_names, {'A0', 'A1', Count_Name}));
Pulse = data.get(pulse_idx(1)).Values.Data;     
% =========================================================================

% 3. ค้นหา Pulse อัตโนมัติ
pulse_threshold = 2000; 
pulse_on = Pulse > pulse_threshold;
edge_detect = diff([0; pulse_on]); 
start_idx = find(edge_detect == 1); 
end_idx = find(edge_detect == -1);  
if length(start_idx) < 4
    error('หา Pulse ไม่ครบ 4 ลูก! รบกวนเช็กว่าข้อมูล data เป็นของการรันครบ 4 สเต็ปหรือไม่');
end

% 4. ฟังก์ชันหั่นข้อมูล
slice_t = @(i) Time_Full(start_idx(i):end_idx(i));
slice_y = @(sig, i) sig(start_idx(i):end_idx(i));
disp(['กำลังสร้างกราฟของ ' prefix '...']);

% ---------------------------------------------------------
% 🌟 NEW: หั่นส่วนพิเศษ สร้าง "กราฟรวม (Overview)" 
% ---------------------------------------------------------
fig0 = figure('Name', [prefix ' - 0: Combined Overview'], 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]); 
subplot(2,1,1); hold on; grid on;
plot(Time_Full, PhaseA + 0.1, 'LineWidth', 1.5);
plot(Time_Full, PhaseB, '--', 'LineWidth', 1.5);
title([prefix ' : กราฟรวมสัญญาณ Phase A และ B (ตลอดการทดลอง)']);
legend('Phase A', 'Phase B', 'Location', 'best');

subplot(2,1,2); hold on; grid on;
plot(Time_Full, Count, 'g', 'LineWidth', 1.5);
title([prefix ' : กราฟรวมการนับพัลส์สะสม (ตลอดการทดลอง)']);
legend('Pulse Count', 'Location', 'best');
savefig(fig0, [prefix '_0_CombinedAll.fig']); % เซฟกราฟรวม

% ---------------------------------------------------------
% 5. หั่นส่วนที่ 1: หมุน CW
fig1 = figure('Name', [prefix ' - Step 1: CW']); hold on; grid on;
plot(slice_t(1), slice_y(PhaseA, 1) + 0.1, 'LineWidth', 2);
plot(slice_t(1), slice_y(PhaseB, 1), '--', 'LineWidth', 2);
title([prefix ' : ทิศทาง CW (A นำ B)']);
savefig(fig1, [prefix '_1_PhaseCW.fig']); 

% ---------------------------------------------------------
% 6. หั่นส่วนที่ 2: หมุน CCW
fig2 = figure('Name', [prefix ' - Step 2: CCW']); hold on; grid on;
plot(slice_t(2), slice_y(PhaseA, 2) + 0.1, 'LineWidth', 2);
plot(slice_t(2), slice_y(PhaseB, 2), '--', 'LineWidth', 2);
title([prefix ' : ทิศทาง CCW (B นำ A)']);
savefig(fig2, [prefix '_2_PhaseCCW.fig']);

% ---------------------------------------------------------
% 7. หั่นส่วนที่ 3: หมุน 360 องศา (หาค่า PPR)
count_step3 = slice_y(Count, 3);
PPR_Value = max(count_step3) - min(count_step3); 
Angular_Res = 360 / PPR_Value;

fig3 = figure('Name', [prefix ' - Step 3: Count 360']); hold on; grid on;
plot(slice_t(3), count_step3, 'g', 'LineWidth', 2);
title([prefix ' : นับพัลส์ 1 รอบ (PPR = ' num2str(PPR_Value) ')']);
savefig(fig3, [prefix '_3_Count360.fig']);

% ---------------------------------------------------------
% 8. หั่นส่วนที่ 4: หมุนเร็ว (ดู Noise)
fig4 = figure('Name', [prefix ' - Step 4: High Speed Noise']); 
subplot(2,1,1); hold on; grid on;
plot(slice_t(4), slice_y(PhaseA, 4) + 0.1); plot(slice_t(4), slice_y(PhaseB, 4), '--');
title('High Speed Waveform (Check Noise)');
subplot(2,1,2); hold on; grid on;
plot(slice_t(4), slice_y(Count, 4), 'g');
title('High Speed Position');
savefig(fig4, [prefix '_4_HighSpeed.fig']);

% ---------------------------------------------------------
% 9. บันทึกข้อมูลลง Excel อัตโนมัติ (ระบบเช็กข้อมูลซ้ำ)
excel_file = 'Lab1_3_MasterResults.xlsx';
new_data = table({Encoder_Name}, {Read_Mode}, PPR_Value, Angular_Res, ...
    'VariableNames', {'Encoder', 'Mode', 'Measured_PPR', 'Angular_Res_Deg'});
if isfile(excel_file)
    old_data = readtable(excel_file);
    dup_idx = strcmp(old_data.Encoder, Encoder_Name) & strcmp(old_data.Mode, Read_Mode);
    if any(dup_idx)
        old_data(dup_idx, :) = []; 
    end
    final_data = [old_data; new_data];
else
    final_data = new_data;
end
writetable(final_data, excel_file);

% ---------------------------------------------------------
% 10. Backup ข้อมูลดิบ
save([prefix '_RawData.mat'], 'data');

disp('-----------------------------------------');
disp(['✅ ประมวลผล ' prefix ' เสร็จสมบูรณ์!']);
disp(['👉 สร้างกราฟรวม 1 หน้าต่าง และ กราฟย่อย 4 หน้าต่าง']);
disp(['👉 Backup ข้อมูลดิบไว้ที่ไฟล์ ' prefix '_RawData.mat']);
disp('-----------------------------------------');