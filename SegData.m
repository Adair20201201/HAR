%function Sample = SegData(label_file,data_file,win,gap)
%function Sample = SegData(label_file,data_file,win,gap,varargin)
function Sample = SegData(data_file,win,gap,varargin)
% Sample = SegData(label_file,data_file,win,gap)
% label_file - labels.xls file (e.g. 1.xls)
% data_file - rawData.txt file (e.g. 1.txt)
% winSize - Window Size for each segment (e.g. =30 points)
% gap -  the gap between two windows (e.g. =15 points)
%

% % Label Matrix
% A=dlmread(label_file);
% label_mat=[];
% for j=2:2:size(A,2)
%     label_mat=[label_mat A(:,j).'];
% end

% Data Matrix (Data&Time)
Output=pre_pocessing_CS2(data_file);

tmpData=Output.Data;
% Save the data in txt
if 0
    fid = fopen('offlineAllData32_1.txt','wt');
    for i = 1:size(tmpData,1)
        for j = 1:size(tmpData,2)
            fprintf(fid,'%f',tmpData(i,j));
            fprintf(fid,'%c','  ');
        end
        fprintf(fid,'%c\n','');
    end
end


tmpTime=Output.Time;

sam_idx = 1;%sample number
seg = [];
Beg_Location = 0;
for k=1:gap:size(tmpData,2)
    %if (k+win)<size(tmpData,2)
    if (k+win - 1)<= size(tmpData,2)
        % Time (most of the datapoints belong to)
        TimeRange=floor(tmpTime(k:k+win-1));
        table=tabulate(TimeRange);
        [F,I]=max(table(:,2));
        I=find(table(:,2)==F);
        result=table(I,1);
        Sample{sam_idx}.Time=result(1);
        if Sample{sam_idx}.Time==0 %% VS online segmentData,the outline maybe less one samples
            continue;
        end

        % Hz
        Sample{sam_idx}.Hz = (win-1)/(tmpTime(k+win-1)-tmpTime(k));
        
        % Data
        if nargin == 3
            Sample{sam_idx}.Data = tmpData(:,k:k+win-1);
        elseif nargin  >= 4 && strcmp(varargin{1},'fft')
            Sample{sam_idx}.Data = data2fft(tmpData(:,k:k+win-1));
        elseif nargin  >= 4 && strcmp(varargin{1},'k-means')
            Sample{sam_idx}.Data = data2kmeans(tmpData(:,k:k+win-1),varargin{2})';
        end
        %Sample{sam_idx}.Data = tmpData(:,k:k+win-1);
        
        %Label
        %Sample{sam_idx}.Label = label_mat(Sample{sam_idx}.Time);
        
        % Location & STE
        [Sample{sam_idx}.Location,Sample{sam_idx}.STE, Sample{sam_idx}.Fired] = calcLocation(tmpData(:,k:k+win-1));
        
        % Partical Filter & Speed
        if ~isempty(Sample{sam_idx}.Location)
            if Beg_Location == 0
                Sample{sam_idx}.PF = mean(Sample{sam_idx}.Location,2);
                Sample{sam_idx}.Speed = 0;
                Beg_Location = 1;
            else
                Sample{sam_idx}.PF = PFfilter(Sample{sam_idx-1}.PF, Sample{sam_idx}.Location);
                tmp = Sample{sam_idx}.PF - Sample{sam_idx-1}.PF;
                Speed = sqrt(tmp' * tmp);
                Sample{sam_idx}.Speed = Speed;
                if Speed > 3 % caused by PIR misalarm
                    Sample{sam_idx}.PF = Sample{sam_idx-1}.PF;
                    Sample{sam_idx}.Speed = 0;
                end
            end
            %Sample{sam_idx}.Location = mean(Sample{sam_idx}.Location,2);
        else
            if Beg_Location == 0
                Sample{sam_idx}.PF = [];
            else
                Sample{sam_idx}.PF = Sample{sam_idx-1}.PF;
            end
            Sample{sam_idx}.Speed = 0;
        end
        
        % Motion Segmentation
        if sam_idx >2
            if Sample{sam_idx}.Speed == 0 && Sample{sam_idx-1}.Speed >0
                tmp_idx = sam_idx;
                seg = [];
                while tmp_idx > 1
                    if Sample{tmp_idx-1}.Speed > 0
                        seg = [seg;tmp_idx-1];
                        tmp_idx = tmp_idx-1;
                    else
                        break;
                    end
                end
                seg;
            end
        end
        
        % Increas sample index
        sam_idx=sam_idx+1;
    end
    
    % Clean incomplete data
    %     if ~((isfield(Sample{end},'Time')) && isfield(Sample{end},'Label'))
    %         Sample(end) = [];
    %     end
    
end

if 0 %verbose Info
    size(tmpData,2)
end

%fclose(fid);
