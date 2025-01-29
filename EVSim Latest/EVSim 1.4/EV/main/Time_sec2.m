function T_sec1 = Time_sec2(D,Time)
A1 = size(D,1);
a = 1;
D1 = D(1:A1).*1.60934;
%% Distance
for i=1:1:A1-1
   if(D1(i,1)<=0.4)%in km
       a = i;
   else
       a = a;
   end
end
%% Time at Distance = 0.4 km
T_sec1 = Time(a,1);%in sec
end