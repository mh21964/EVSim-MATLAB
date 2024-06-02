function EV_range = RangeCal(D,SOC)
%% Total Distance Travelled
TotalDist = D(end,1)*1.60934;% in kms
%% SOC
E_soc = SOC(end,1);
I_soc = SOC(1,1);
%% Range
EV_range = (TotalDist / (I_soc-E_soc))*85;
end