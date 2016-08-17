%% K-means
function cluster = data2kmeans(data,centroid)
data = data';
for k = 1:size(data,1)
    for i = 1:size(centroid,1)
        tmp = data(k,:) - centroid(i,:);
        dis(i) = tmp * tmp';
    end
    [row,cluster(k)] = min(dis);
end


                          