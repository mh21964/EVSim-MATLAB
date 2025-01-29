function R = RegenB(V,P)
A1 = size(V,1);
Pow = 0;
% Pow1 = 0;
% Vel is in mph (1 mph = 1.60934 kph)
Vel = V.*1.60934;% in kph
for i =1:1:A1
    %% Regen
    if(Vel(i,1)>0 && P(i,1)<0)
        Pow = Pow + abs(P(i,1));
    else
        Pow = Pow;
    end
%     %% Power Used
%     if(P(i,1)>0)
%         Pow1 = Pow1 + abs(P(i,1));
%     else
%         Pow1 = Pow1;
%     end
end
RegenBraking = Pow/(3600*1000);%in kW
% PowerUsed = Pow1/1000;%in kW

R = [RegenBraking];% PowerUsed];
end