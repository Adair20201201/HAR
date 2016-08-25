%% Calculate centroid if use k-means
function centroid = calcuCentroid(win,gap,clusterNum,projectDir,DataDir)
filetype='.csv';
cd(projectDir);
files = dir([DataDir '*' filetype]);
file_num = size(files,1);
%DataIdx=1:file_num;
DataIdx=1:2; % Just for testing
data = [];
for i=1:length(DataIdx)
     disp(sprintf('Dealing with file : %d', i));
     label_file=[DataDir num2str(DataIdx(i)) filetype];
     data_file=[DataDir num2str(DataIdx(i)) '.txt'];
     % Data Matrix (Data&Time)
     Output=pre_pocessing_CS2(data_file);
     tmpData=Output.Data;
     tmpTime=Output.Time;
     % Label Matrix
     A=dlmread(label_file);
     %A=xlsread(label_file);
     label_mat=[];
     for j=2:2:size(A,2)
         label_mat=[label_mat A(:,j).'];
     end
     
 
 
    for k=1:gap:size(tmpData,2)
        if (k+win)<size(tmpData,2)
            
            % Time (most of the datapoints belong to)
            TimeRange=floor(tmpTime(k:k+win-1));
            table=tabulate(TimeRange);
            [F,I]=max(table(:,2));
            I=find(table(:,2)==F);
            result=table(I,1);
            Time=result(1);
            
            if Time==0
                continue;
            end
            
            %if ~isnan(label_mat(Sample{sam_idx}.Time))&&(Sample{sam_idx}.Label~=0)
            if label_mat(Time)>0
                data = [data tmpData(:,k:k+win-1)]; 
            end

        end
        
    end
    
end

opts = statset('Display','final');
[index,centroid] = kmeans(data',clusterNum,...
                    'Distance','sqeuclidean',...
                    'Replicates',20,...
                    'Options',opts);

