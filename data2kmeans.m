%% K-means
function data_kmeans = data2kmeans(data,numCuster)
opts = statset('Display','final');
[data_kmeans, ~] = kmeans(data',numCuster, 'Distance','sqEuclidean', ...
                              'Replicates',5, 'Options',opts);                  
                          