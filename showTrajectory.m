function showTrajectory(Samples, Action_name)

if 1
    figure(1);
    hold on
    STE_tmp = [];
    for i = 1:length(Samples)
        STE_tmp = [STE_tmp Samples{i}.STE'];
    end
    
    color = ['y','m','c','r','g','b','r','k'];
    for j=1:5
        plot(STE_tmp(j,:),color(j));
    end
    set(gca,'XTick',[5:5:length(Samples)]) %
    legend('PIR1','PIR2','PIR3','PIR4','PIR5')
end


if 1
    %color = ['y','m','c','r','g','b','r','k'];
    %markertype = ['+','*','x','s','o','p','h','>'];
    figure(2);
    hold on;
    axis([-4.5 4.5 -4.5 4.5])
    last_location = [];
    last_mark = [];
    last_location_mean = [];
    for i = 1:length(Samples)
        location = Samples{i}.Location
        speed = Samples{i}.Speed
        label = Samples{i}.Label;
        PF = Samples{i}.PF;
        
        
        if i>1 && ~isempty(last_location)
            scatter(last_location(1,:),last_location(2,:),[],'w','o');
        end
        
        if i>1 && ~isempty(last_PF)
            plot(last_PF(1),last_PF(2),'w+','markersize',20,'linewidth',2);
        end
        
        if speed>0
            scatter(location(1,:),location(2,:),[],'r','o');
            plot(PF(1),PF(2),'m+','markersize',20,'linewidth',2);
        elseif speed == 0 && ~isempty(PF)
            plot(PF(1),PF(2),'k+','markersize',20,'linewidth',2);
        end
        
        if label > 0
            title(['Samples:\{' num2str(i) '\}' '   Time: ' num2str(Samples{i}.Time)...
                '    Action: ' cell2mat(Action_name(label)) ' (' num2str(label) ')' '   Speed: '  num2str(speed) ])
        else
            title(['Samples:\{' num2str(i) '\}' '   Time: ' num2str(Samples{i}.Time)...
                '    Action: Null' '   Speed: '  num2str(speed) ])
        end
        
        last_location = location;
        last_PF = PF;
        pause;
    end
    hold off;
end