% --- โค้ด Lab 1.1: รันทีละสเกล พร้อมกัน 3 เซนเซอร์ (เวอร์ชันป้องกัน Error) ---

% 1. ตรวจสอบและดึงข้อมูล 3 เส้น
if isa(data, 'Simulink.SimulationData.Dataset')
    if data.numElements < 3
        error('❌ ส่งข้อมูลมาไม่ครบ! เจอแค่ %d เส้น กรุณากลับไปติ๊กถูกที่หน้าต่าง SDI ให้ครบ 3 เส้นก่อน Export', data.numElements);
    end
    v1 = data.getElement(1).Values.Data;
    v2 = data.getElement(2).Values.Data;
    v3 = data.getElement(3).Values.Data;
elseif isa(data, 'timeseries')
    if length(data) < 3
        error('❌ ส่งข้อมูลมาแค่ 1 เส้น! กรุณากลับไปติ๊กถูกที่หน้าต่าง SDI ให้ครบ 3 เส้นก่อน Export');
    end
    v1 = data(1).Data;
    v2 = data(2).Data;
    v3 = data(3).Data;
else
    error('❌ รูปแบบข้อมูลไม่รองรับ ลอง Export ใหม่อีกครั้งครับ');
end

% 2. กรอกสเกลรอบปัจจุบัน
scale_val = input('รันที่สเกลเท่าไหร่? (เช่น 0, 5, 10): ');

% 3. หาค่าเฉลี่ย 10 วินาทีของแต่ละตัว
mean_A0 = mean(v1);
mean_A1 = mean(v2);
mean_A2 = mean(v3);

% 4. สร้างตารางเตรียมบันทึก (3 บรรทัด)
Sensor_Type = ["Rotary1_A0"; "Rotary2_A1"; "Rotary3_A2"];
Scale_Percent = [scale_val; scale_val; scale_val];
V_out_V = [mean_A0; mean_A1; mean_A2];

T_new = table(Sensor_Type, Scale_Percent, V_out_V);

% 5. บันทึกลงไฟล์ Excel
filename = 'Lab1_1_Potentiometer_Results.xlsx';
if isfile(filename)
    old_T = readtable(filename);
    T_final = [old_T; T_new]; % เอา 3 บรรทัดใหม่ไปต่อท้าย
else
    T_final = T_new; 
end
writetable(T_final, filename);

% 6. โชว์ผลลัพธ์
disp('=======================================');
disp(['บันทึกสำเร็จที่สเกล: ', num2str(scale_val), ' %']);
disp(['A0 (Rotary 1): ', num2str(mean_A0), ' V']);
disp(['A1 (Rotary 2): ', num2str(mean_A1), ' V']);
disp(['A2 (Rotary 3): ', num2str(mean_A2), ' V']);
disp('=======================================');