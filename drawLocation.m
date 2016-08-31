function drawLocation(Samples)

%% Plot the location where action happend
%  1 --> Lying
%  2 --> Lie-to-sit
%  3 -- > Sit- to-lie
%  4 --> Sitting
%  5 --> Sit-to-stand
%  6 --> Stand-to-sit
%  7 --> Standing
%  8 --> Walking
%clc
%clear

%load Samples;

color = ['y','m','c','r','g','b','r','k'];
markertype = ['+','*','x','s','o','d','<','>'];
%markertype = ['o','+','o','+','o','+','o','+'];

figure; 
hold on;
axis([-4.5 4.5 -4.5 4.5])
axis equal

for i = 1:8
    plot(0,0,[color(i) markertype(i)]); 
end     
for i = 1:8
    plot(0,0,['w' markertype(i)]); 
end

for i = 1:length(Samples)
    location = Samples{i}.PF;
    label = Samples{i}.Label;
    %for j = 1:size(location,2)
    plot(location(1),location(2),[color(label) markertype(label)]); 
        %scatter(location(1,:),location(2,:),'MarkerFaceColor',color(label),'Marker',markertype(label));

    %end
end
hold off
title('Location');
xlabel('X ');
ylabel('Y');
legend('Lying','Lie-to-sit','Sit- to-lie','Sitting','Sit-to-stand','Stand-to-sit',...
              'Standing','Walking');

%%%   K-means   %%%
knn_Samples = [];
for i = 1:length(Samples)
    if Samples{i}.Label == 2||Samples{i}.Label == 3||Samples{i}.Label == 5||Samples{i}.Label == 6 ...
        ||Samples{i}.Label == 1||Samples{i}.Label == 4
        knn_Samples = [knn_Samples;Samples{i}.PF'];
    end
end

[idx,C] = kmeans(knn_Samples,2);
          
figure;
plot(knn_Samples(idx==1,1),knn_Samples(idx==1,2),'r.','MarkerSize',12)
hold on
plot(knn_Samples(idx==2,1),knn_Samples(idx==2,2),'b.','MarkerSize',12)
plot(C(:,1),C(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3)

max_x1 = max(knn_Samples(idx==1,1));
min_x1 = min(knn_Samples(idx==1,1));
max_y1 = max(knn_Samples(idx==1,2));
min_y1 = min(knn_Samples(idx==1,2));

max_x2 = max(knn_Samples(idx==2,1));
min_x2 = min(knn_Samples(idx==2,1));
max_y2 = max(knn_Samples(idx==2,2));
min_y2 = min(knn_Samples(idx==2,2));

plot([min_x1,max_x1,max_x1,min_x1,min_x1],[min_y1,min_y1,max_y1,max_y1,min_y1]);
plot([min_x2,max_x2,max_x2,min_x2,min_x2],[min_y2,min_y2,max_y2,max_y2,min_y2]);

legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
title 'Cluster Assignments and Centroids'
hold off
axis([-4.5 4.5 -4.5 4.5])



          
