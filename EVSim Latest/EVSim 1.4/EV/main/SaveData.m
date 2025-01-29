
% if(isfile('D:\EV4\EVSim\output\PerformanceMetric.csv'))
%     delete('D:\EV4\EVSim\output\PerformanceMetric.csv');
% end
% if(isfile('D:\EV4\EVSim\output\Vehicle Matlab Output_Range City.csv'))
%     delete('D:\EV4\EVSim\output\Vehicle Matlab Output_Range City.csv');
% end
% if(isfile('D:\EV4\EVSim\output\Vehicle Matlab Output_Range Hwy.csv'))
%     delete('D:\EV4\EVSim\output\Vehicle Matlab Output_Range Hwy.csv');
% end
% if(isfile('D:\EV4\EVSim\output\Vehicle Matlab Output_Top Speed x Grade.csv'))
%     delete('D:\EV4\EVSim\output\Vehicle Matlab Output_Top Speed x Grade.csv');
% end
% if(isfile('D:\EV4\EVSim\output\Vehicle Matlab Output_Wide Open Throtle.csv'))
%     delete('D:\EV4\EVSim\output\Vehicle Matlab Output_Wide Open Throtle.csv');
% end
pause(5);
gui;
 
% Define the variable name you're waiting for
variableName = 'VehicleType'; % Change this to the actual variable name you're checking for

% Continuously check if the variable exists in the workspace
while true
    % Check if the variable exists in the base workspace
    if evalin('base', ['exist(''', variableName, ''', ''var'')'])
        
        break; % Exit the loop once the variable exists
    else
       
    end
    pause(1); % Wait for 1 second before checking again (adjust as necessary)
end





tic

sim1 = 0;
ttime=0;
T1 = [];
T2 = [];
ANS1=[];
ANS2=[];
ANS4=[];
ANS5=[];
%% Accessing the data directly from the workspace
VehicleType = evalin('base', 'VehicleType');  
VehicleSize = evalin('base', 'VehicleSize');  
Passengers = evalin('base', 'Passengers');  
Payload = evalin('base', 'Payload');  
DriveSchedule = evalin('base', 'PerformanceMetric'); 
RegenBraking = evalin('base', 'RegenBraking');  
%AirConditioner = evalin('base', 'AirConditioner');  
MotorSize = evalin('base', 'MotorSize');  
BatterySize = evalin('base', 'BatterySize');  
TireSize = evalin('base', 'TireSize');  
BatteryVoltage = evalin('base', 'BatteryVoltage');  
DragCoefficient = evalin('base', 'DragCoefficient');  
FrontalArea = evalin('base', 'FrontalArea');  

if(VehicleType == "Car")
    const2 = 2;
    MotorSize = 1000 * MotorSize;  % Conversion if needed
    BatterySize = BatterySize;  % No change needed if already in appropriate units
    NF = 2;
    NR = 2;
else
    AirConditioner = "OFF";
    MotorSize = 1000 * MotorSize;  % Conversion if needed
    BatterySize = BatterySize;  % No change needed if already in appropriate units
    if(VehicleType == 'Rickshaw')
        const2 = 2;
        NF = 1;
        NR = 2;
    elseif(VehicleType == 'Bike')
        const2 = 1;
        NF = 1;
        NR = 1;
    end
end

BatterySize = (BatterySize * 1000)/BatteryVoltage;
Mass = VehicleSize + Passengers * 75 + Payload;
Tire_W = TireSize(1,1);
AR = TireSize(1,2);
Rim_d = TireSize(1,3)*25.4;% From inch to mm 
Tire_H = Tire_W * AR / 100;
Tire_d = ((Tire_H*2) + Rim_d)/1000;
Tire_r = Tire_d / 2;

if(AirConditioner == 'ON')
    const1 = 1;
else
    const1 = 2;
end

open('D:\EV4\EVSim\EV\main\EV.prj')
open('D:\EV4\EVSim\EV\main\EvReferenceApplication.slx')

%% Simulating the Simulink buildin model
for i =1:1:size(DriveSchedule,1)
    if (DriveSchedule(i,1)=='Range (km) - City')
        const = 1;
        ttime = 2474;
        Grade = 0;
        R = sim('D:\EV4\EVSim\EV\main\EvReferenceApplication.slx')
        X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
        ANS1 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
        X3 = ["Time","Distance","TargetVelocity","ActualVelocity","StateOfCharge","BatteryPower","BatteryCurrent","MotorTorque","MotorSpeed","MilesPerGallon"];
        T = cell2table(num2cell(ANS1),'VariableNames',cellstr(X3));
        writetable(T,'D:\EV4\EVSim\EV\main\Vehicle Matlab Output_Range City.csv');
        [EV_Range] = RangeCal(ANS1(:,2),ANS1(:,5));
        T1(1,1) = [EV_Range];
        T1(1,9) = [ANS1(end,2)];
    elseif(DriveSchedule(i,1)=='Top Speed (kph) x% grade')
        const = 2;
        Grade = 7;
        ttime = 310;
        R1 = sim('D:\EV4\EVSim\EV\main\EvReferenceApplication.slx')
        X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
        ANS4 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
        X3 = ["Time","Distance","TargetVelocity","ActualVelocity","StateOfCharge","BatteryPower","BatteryCurrent","MotorTorque","MotorSpeed","MilesPerGallon"];
        T = cell2table(num2cell(ANS4),'VariableNames',cellstr(X3));
        writetable(T,'D:\EV4\EVSim\EV\main\Vehicle Matlab Output_Top Speed x Grade.csv');
        [Vel_max] = TopSpeed(ANS4(:,4));
        T1(1,4) = [Vel_max];
        T1(1,9) = [ANS4(end,2)];
    elseif(DriveSchedule(i,1)=='Range (km) - Hwy (or Mwy)')
        const = 3;
        if(const2 == 1)
            ttime = 1874;
        else
            ttime = 775;
        end
        Grade = 0;
%         ttime = 775;
        R2 = sim('D:\EV4\EVSim\EV\main\EvReferenceApplication.slx')
        X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
        ANS5 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
        X3 = ["Time","Distance","TargetVelocity","ActualVelocity","StateOfCharge","BatteryPower","BatteryCurrent","MotorTorque","MotorSpeed","MilesPerGallon"];
        T = cell2table(num2cell(ANS5),'VariableNames',cellstr(X3));
        writetable(T,'D:\EV4\EVSim\EV\main\Vehicle Matlab Output_Range Hwy.csv');
        [EV_Range1] = RangeCal(ANS5(:,2),ANS5(:,5));
        T1(1,2) = [EV_Range1];
        T1(1,9) = [ANS5(end,2)];
    elseif(DriveSchedule(i,1)=='Time (sec) 50 - 80 kph' || DriveSchedule(i,1)=='Top Speed (kph) 0% grade' || DriveSchedule(i,1)=='Time (sec) 0 - 100 kph' || DriveSchedule(i,1)=='Time (sec) 0.4 km')% || DriveSchedule(i,1)=='Time (sec) 50 - 80 kph')
        sim1 = sim1 + 1;
        if (sim1 == 1)
            const = 2;
            Grade = 0;
            ttime = 310;
            R4 = sim('D:\EV4\EVSim\EV\main\EvReferenceApplication.slx')
            X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
            ANS2 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
            X3 = ["Time","Distance","TargetVelocity","ActualVelocity","StateOfCharge","BatteryPower","BatteryCurrent","MotorTorque","MotorSpeed","MilesPerGallon"];
            T = cell2table(num2cell(ANS2),'VariableNames',cellstr(X3));
            writetable(T,'D:\EV4\EVSim\EV\main\Vehicle Matlab Output_Wide Open Throtle.csv');
            T1(1,9) = [ANS2(end,2)];
        end
        if(DriveSchedule(i,1)=='Time (sec) 50 - 80 kph')
            [Time1] = Time_sec3(ANS2(:,4),ANS2(:,1));
            T1(1,7) = [Time1];
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
%% Regen Braking
if(RegenBraking == 'ON')
    if(isempty(ANS1))
        const = 1;
        ttime = 2474;
        Grade = 0;
        R = sim('D:\EV4\EVSim\EV\main\EvReferenceApplication.slx')
        X1 = min([size(Vref.Data,1) size(SOC.Data,1) size(BatP.Data,1) size(BatI.Data,1) size(MotT.Data,1) size(MotS.Data,1) size(MPG.Data,1)]);
        ANS1 = [Vref.Time(1:X1,:) Dist.Data(1:X1,:) Vref.Data(1:X1,:) SOC.Data(1:X1,:) BatP.Data(1:X1,:) BatI.Data(1:X1,:) MotT.Data(1:X1,:) MotS.Data(1:X1,:) MPG.Data(1:X1,:)];
        [R1] = RegenB(ANS1(:,4),ANS1(:,6));
        T1(1,8) = R1;
    else
        [R1] = RegenB(ANS1(:,4),ANS1(:,6));
        T1(1,8) = R1;
    end
else
    T1(1,8)=0;
end
R11 = ["RangeCity","RangeHwy","TopSpeed0Grade","TopSpeedxGrade","Time0to100kph","Time400m","Time50to80kph","RegenBraking","TotalDistance"];
T1 = [T1 zeros(1,size(R11,2)-size(T1,2))];
T1(1:end-2) = round(T1(1:end-2));
T1(1,end-1) = round(T1(1,end-1),5);
T1(1,end) = round(T1(1,end)*1.60934);
T3 = cell2table(num2cell(T1),'VariableNames',cellstr(R11));
writetable(T3,'D:\EV4\EVSim\EV\main\PerformanceMetric.csv');
toc
fclose('all');
pause();