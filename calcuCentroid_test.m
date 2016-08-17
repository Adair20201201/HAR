%% test calcuCentroid
projectDir =  'G:\HAR';
DataDir = 'G:\ActionDataColection\ActionData\SensorData_labled\Tan\';
win = 30;
gap = 15;
clusterNum = 5;

%centroid = calcuCentroid(win,gap,clusterNum,projectDir,DataDir);
load centroid
load data
load index
cluster = data2kmeans(data,centroid);
sum = 0;
index = index';
for i = 1:length(cluster)
    res = isequal(cluster(i),index(i));
    if res
        sum = sum+1;
    end
end
sum
 