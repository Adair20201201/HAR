function continouseTrajectory_online2(Samples)
subplot(2,2,1);
cla
speed = 0;
PF = [];
hold on
for i = 1:length(Samples)
    PF(:,i) = Samples{i}.PF;
    speed = Samples{i}.Speed;
end

 if speed>0
        plot(PF(1,end),PF(2,end),'m+','markersize',5,'linewidth',3);
    elseif speed == 0 && ~isempty(PF)
        plot(PF(1,end),PF(2,end),'k+','markersize',5,'linewidth',3);
 end
  
plot(PF(1,:),PF(2,:),'LineWidth',2);
axis equal
axis([-6.0 6.0 -6.0 6.0]);
%axis equal;

