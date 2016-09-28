function continouseTrajectory_online(Samples)
subplot(2,2,1);
cla
last_location = [];

hold on
for i = 1:length(Samples)
    location = Samples{i}.Location;
    PF(:,i) = Samples{i}.PF;
    speed = Samples{i}.Speed;
    
    if i>1 && ~isempty(last_location)
         scatter(last_location(1,:),last_location(2,:),[],'w','o');
    end

     if i>1 && ~isempty(last_PF)
         plot(last_PF(1),last_PF(2),'w+','markersize',5,'linewidth',3);
     end
    
     if speed>0
        plot(PF(1,i),PF(2,i),'m+','markersize',5,'linewidth',3);
    elseif speed == 0 && ~isempty(PF)
        plot(PF(1,i),PF(2,i),'k+','markersize',5,'linewidth',3);
     end
    
     last_location = location;
     last_PF = PF(:,i);
end
plot(PF(1,:),PF(2,:),'LineWidth',2);
axis equal
axis([-6.0 6.0 -6.0 6.0]);
%axis equal;

