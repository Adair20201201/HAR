%% Plot the location where action happend
%  1 --> Lying
%  2 --> Lie-to-sit
%  3 -- > Sit- to-lie
%  4 --> Sitting
%  5 --> Sit-to-stand
%  6 --> Stand-to-sit
%  7 --> Standing
%  8 --> Walking
clc
clear

load Samples;

color = ['y','m','c','r','g','b','w','k'];
markertype = ['+','*','x','s','o','p','h','>'];

figure; 
for i = 1:length(Samples)
    location = Samples{i}.Location;
    label = Samples{i}.Label;
    for j = 1:size(location,2)
        scatter(location(1,:),location(2,:),'MarkerFaceColor',color(label)); 
        %scatter(location(1,:),location(2,:),'MarkerFaceColor',color(label),'Marker',markertype(label));
        hold on;
    end
end

title('Location');
xlabel('X ');
ylabel('Y');
legend('Lying','Lie-to-sit','Sit- to-lie','Sitting','Sit-to-stand','Stand-to-sit',...
              'Standing','Walking','Location','NorthEastOutside');