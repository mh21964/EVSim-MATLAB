function FileO = DataIO(FileI)
sim1 = 0;
ttime=0;
T1 = [];
FileI = 'F:\Vehicle Developement Data\Vehicle Matlab Input .txt';
%% Reading the file generated by Unity
fid = fopen(FileI);%Vehicle Matlab Input 23.18427.txt');
C = textscan(fid,'%s %s','Delimiter',':');
A1 = C{1,2};
A2 = string(A1);
VehicleType = A2(1,1);
VehicleSize = str2num( regexprep( A2(2,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
Passengers = str2num(A2(3,1));
Payload = str2num( regexprep( A2(5,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
DriveSchedule = split(A2(4,1),",");
Payload = str2num( regexprep( A2(5,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
RegenBraking = A2(6,1);
if(VehicleType == "Car")
    AirConditioner = A2(7,1);
    MotorSize = 1000 * str2num( regexprep( A2(8,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
    BatterySize = str2num( regexprep( A2(9,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
    TireSize = str2num( regexprep( A2(10,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
    NF = 2;
    NR = 2;
else
    MotorSize = 1000 * str2num( regexprep( A2(7,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
    BatterySize = str2num( regexprep( A2(8,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
    TireSize = str2num( regexprep( A2(9,1), {'\D*([\d\.]+\d)[^\d]*', '[^\d\.]*'}, {'$1 ', ' '} ) );
    if(VehicleType == 'Rickshaw')
        NF = 1;
        NR = 2;
    elseif(VehicleType == 'Bike')
        NF = 1;
        NR = 1;
    end
end
Mass = VehicleSize + Passengers * 75 + Payload;
Tire_H = TireSize(1,1)*TireSize(1,2)/100;
Tire_d = (Tire_H*2 + TireSize(1,3))/1000;
Tire_r = Tire_d / 2;
if(AirConditioner == 'ON')
    const1 = 1;
else
    const1 = 2;  
end

%% Simulating the Simulink buildin model
for i =1:1:size(DriveSchedule,1)-1
    if (DriveSchedule(i,1)=='Range (km) - City')
        const = 1;
        ttime = 2474;
        Grade = 0;
        open('EV.prj')
        open('EvReferenceApplication.slx')
        R = sim('EvReferenceApplication.slx')
        X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
        ANS1 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];% BattV.Data(1:X1,:) BattPwr(1:X1,:) BattCrnt(1:X1,:) MotCrnt(1:X1,:)];
        [EV_Range] = RangeCal(ANS1(:,2),ANS1(:,5));
        T1(1,1) = [EV_Range];
        if(RegenBraking == 'ON')
            [R1] = RegenB(ANS1(:,4),ANS1(:,6));
            RB = R1(1,1);
            T1(1,8) = [RB];
        end
    elseif(DriveSchedule(i,1)=='Top Speed (kph) x% grade')
        const = 2;
        Grade = 7;
        ttime = 310;
        open('EV.prj')
        open('EvReferenceApplication.slx')
        R1 = sim('EvReferenceApplication.slx')
        X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
        ANS4 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
        [Vel_max] = TopSpeed(ANS4(:,4));
        T1(1,4) = [Vel_max];
    elseif(DriveSchedule(i,1)=='Time (sec) 50 - 80 kph')
        const = 3;
        Grade = 0;
        ttime = 310;
        open('EV.prj')
        open('EvReferenceApplication.slx')
        R2 = sim('EvReferenceApplication.slx')
        X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
        ANS5 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
        [Time1] = Time_sec3(ANS5(:,4),ANS5(:,1));
        T1(1,7) = [Time1];
    elseif(DriveSchedule(i,1)=='Range (km) - Hwy (or Mwy)' || DriveSchedule(i,1)=='Top Speed (kph) 0% grade' || DriveSchedule(i,1)=='Time (sec) 0 - 100 kph' || DriveSchedule(i,1)=='Time (sec) 0.4 km')% || DriveSchedule(i,1)=='Time (sec) 50 - 80 kph')
        sim1 = sim1 + 1;
        if (sim1 == 1)
            const = 2;
            Grade = 0;
            ttime = 310;
            open('EV.prj')
            open('EvReferenceApplication.slx')
            R4 = sim('EvReferenceApplication.slx')
            X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
            ANS2 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
        end
        if(DriveSchedule(i,1)=='Range (km) - Hwy (or Mwy)')
            [EV_Range1] = RangeCal(ANS2(:,2),ANS2(:,5));
            T1(1,2) = [EV_Range1];
        elseif(DriveSchedule(i,1)=='Top Speed (kph) 0% grade')
            [Vel_max] = TopSpeed(ANS2(:,4));
            T1(1,3) = [Vel_max];
        elseif(DriveSchedule(i,1)=='Time (sec) 0 - 100 kph')
            [T_sec] = Time_sec1(ANS2(:,4),ANS2(:,1));
            T1(1,5) = [T_sec];
        elseif(DriveSchedule(i,1)=='Time (sec) 0.4 km')
            [T_sec1] = Time_sec2(ANS2(:,2),ANS2(:,1));
            T1(1,6) = [T_sec1];
        end
    end
end
R1 = ["RangeCity","RangeHwy","TopSpeed0Grade","TopSpeedxGrade","Time0to100kph","Time400m","Time50to80kph","RegenBraking"];
T1 = [T1 zeros(1,size(R1,2)-size(T1,2))];
T2 = cell2table(num2cell(round(T1)),'VariableNames',cellstr(R1));
writetable(T2,'F:\Vehicle Developement Data\PerformanceMetric.csv');
FileO = T2;
end