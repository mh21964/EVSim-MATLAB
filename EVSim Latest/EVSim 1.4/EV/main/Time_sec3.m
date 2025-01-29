function T_sec = Time_sec3(Vel1,Time)
A1 = size(Vel1,1);
a = 1;
Vel = Vel1(1:A1).*1.60934;
maxVel = max(Vel);
maxValue = size(Vel,1);
% Vel1 is in mph (1 mph = 1.6093 kph)
% Vel is in kph
%% Maximum Velocity Target
for i=1:1:A1
    if(Vel(i,1)==maxVel)
        maxValue = i;
    end
    if(Vel(i,1)<=80 && i<=maxValue)%in kph
        a = i;
    else
        a = a;
    end
    if(Vel(i,1)<=50 && i<=maxValue)%in kph
        b = i;
    else
        b = b;
    end
end
c = a - b;
%% Time at Velocity = 100 kph
T_sec = Time(a,1)-Time(b,1);%in sec
end