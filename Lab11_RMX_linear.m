% --- โค้ด Lab 1.1: สำหรับกลุ่ม Linear (เซฟต่อท้ายไฟล์ Rotary) ---

% 1. ตรวจสอบและดึงข้อมูล 2 เส้น
if isa(data, 'Simulink.SimulationData.Dataset')
    if data.numElements < 2
        error('❌ ส่งข้อมูลมาไม่ครบ! กรุณาติ๊กถูกที่หน้าต่าง SDI ให้ครบ 2 เส้น');
    end
    v1 = data.getElement(1).Values.Data;
    v2 = data.getElement(2).Values.Data;
elseif isa(data, 'timeseries')
    if length(data) < 2
        error('❌ ส่งข้อมูลมาไม่ครบ! กรุณาติ๊กถูกที่หน้าต่าง SDI ให้ครบ 2 เส้น');
    end
    v1 = data(1).Data;
    v2 = data(2).Data;
else
    error('❌ รูปแบบข้อมูลไม่รองรับ');
end

% 2. กรอกสเกลระยะทาง (มิลลิเมตร) สูงสุด 60 mm
scale_val = input('รันที่ระยะเท่าไหร่? (เช่น 0, 5, 10 ... 60): ');

% 3. หาค่าเฉลี่ย 10 วินาที
mean_A0 = mean(v1);
mean_A1 = mean(v2);

% 4. สร้างตารางใหม่ (ติดป้าย Lable "(mm)" ไว้ที่ชื่อเซนเซอร์ให้เห็นชัดเจน)
Sensor_Type = ["Linear1_A0 (mm)"; "Linear2_A1 (mm)"];
Scale_Value = [scale_val; scale_val];
V_out_V = [mean_A0; mean_A1];

T_new = table(Sensor_Type, Scale_Value, V_out_V);

% 5. บันทึกลงไฟล์ Excel เดิม (Lab1_1_Potentiometer_Results.xlsx)
filename = 'Lab1_1_Potentiometer_Results.xlsx';
if isfile(filename)
    old_T = readtable(filename);
    
    % เปลี่ยนชื่อคอลัมน์ที่ 2 ของไฟล์เดิมให้เป็นกลาง (Scale_Value) จะได้ต่อกันได้โดยไม่ Error
    old_T.Properties.VariableNames{2} = 'Scale_Value';
    
    T_final = [old_T; T_new]; 
else
    T_final = T_new; 
end
writetable(T_final, filename);

% 6. โชว์ผลลัพธ์
disp('=======================================');
disp(['บันทึกสำเร็จที่ระยะ: ', num2str(scale_val), ' mm ']);
disp(['A0 (Linear 1): ', num2str(mean_A0), ' V']);
disp(['A1 (Linear 2): ', num2str(mean_A1), ' V']);
disp('=======================================');