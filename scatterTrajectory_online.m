function scatterTrajectory_online(Samples)
%set(gca,'XLim',[-4.5 4.5],'YLim',[-4.5 4.5]) 
cla
subplot(2,2,3);
axis([-4.5 4.5 -4.5 4.5])
%last_location = [];

for i = 1:length(Samples)
    location = Samples{i}.Location;
    speed = Samples{i}.Speed;
    PF = Samples{i}.PF;
    hold on;
    if 0
        if i>1 && ~isempty(last_location)
            scatter(last_location(1,:),last_location(2,:),[],'w','o');
        end

        if i>1 && ~isempty(last_PF)
            plot(last_PF(1),last_PF(2),'w+','markersize',20,'linewidth',2);
        end
    
    end

    if speed>0
        scatter(location(1,:),location(2,:),[],'r','o');
        plot(PF(1),PF(2),'m+','markersize',20,'linewidth',2);
    elseif speed == 0 && ~isempty(PF)
        plot(PF(1),PF(2),'k+','markersize',20,'linewidth',2);
    end
%     last_location = location;
%     last_PF = PF;
end
hold off;
