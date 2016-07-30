%function Sample = SegData(label_file,data_file,win,gap)
function Sample = SegData(label_file,data_file,win,gap,varargin)
% Sample = SegData(label_file,data_file,win,gap)
% label_file - labels.xls file (e.g. 1.xls)
% data_file - rawData.txt file (e.g. 1.txt)
% winSize - Window Size for each segment (e.g. =30 points)
% gap -  the gap between two windows (e.g. =15 points)
%

% Label Matrix
A=dlmread(label_file);
%A=xlsread(label_file);
label_mat=[];
for j=2:2:size(A,2)
    label_mat=[label_mat A(:,j).'];
end

% Data Matrix (Data&Time)
Output=pre_pocessing_CS2(data_file);
tmpData=Output.Data;
tmpTime=Output.Time;

sam_idx=1;%sample number
for k=1:gap:size(tmpData,2)
    if (k+win)<size(tmpData,2)
        % Time (most of the datapoints belong to)
        TimeRange=floor(tmpTime(k:k+win-1));
        table=tabulate(TimeRange);
        [F,I]=max(table(:,2));
        I=find(table(:,2)==F);
        result=table(I,1);
        Sample{sam_idx}.Time=result(1);
        if Sample{sam_idx}.Time==0
            continue;
        end
        
        %if ~isnan(label_mat(Sample{sam_idx}.Time))&&(Sample{sam_idx}.Label~=0)
        if label_mat(Sample{sam_idx}.Time)>0
                % Hz
                Sample{sam_idx}.Hz = (win-1)/(tmpTime(k+win-1)-tmpTime(k));

                % Data
                if  strcmp(varargin{1},'fft')  
                    Sample{sam_idx}.Data = data2fft(tmpData(:,k:k+win-1));
                elseif strcmp(varargin{1},'k-means') 
                    Sample{sam_idx}.Data = data2kmeans(tmpData(:,k:k+win-1),int32(varargin{2}))';
                else
                    Sample{sam_idx}.Data = tmpData(:,k:k+win-1); 
                end
                %Sample{sam_idx}.Data = tmpData(:,k:k+win-1);        

                %Label
                Sample{sam_idx}.Label = label_mat(Sample{sam_idx}.Time);
                
                % Location
                Sample{sam_idx}.Location = calcLocation(tmpData(:,k:k+win-1));
                
                % Increas sample index
                sam_idx=sam_idx+1;
        end

    end
    
    % Clean incomplete data
    if ~((isfield(Sample{end},'Time')) && isfield(Sample{end},'Label'))
        Sample(end) = [];
    end
    
end

if 0 %verbose Info
    size(tmpData,2)
end
