function [Sample,unsolvedData,Beg_Location] = SegData_online(Output,win,gap,unsolvedData,Beg_Location,lastSample,varargin)
% data_raw - the raw data collect from serial port in raw
% win - Window Size for each segment (e.g. =30 points)
% gap -  the gap between two windows (e.g. =15 points)

% Data Matrix (Only Data)
    tmpData=Output.Data;
    %Output.Data
    tmpData = [unsolvedData tmpData];
    size(tmpData)
    sam_idx = 2;%sample number
    Sample{1} = lastSample;
%     if Beg_Location == 0
%         Sample{1} = [];
%     end
%     Sample(cellfun('isempty',Sample)) = [];
    
    seg = [];
if size(tmpData,2) >= win
    for k=1:gap:size(tmpData,2)
        if (k+win - 1)<= size(tmpData,2)
            % Data
            if nargin == 6
                Sample{sam_idx}.Data = tmpData(:,k:k+win-1);
            elseif nargin  >= 7 && strcmp(varargin{1},'fft')
                Sample{sam_idx}.Data = data2fft(tmpData(:,k:k+win-1));
            elseif nargin  >= 7 && strcmp(varargin{1},'k-means')
                Sample{sam_idx}.Data = data2kmeans(tmpData(:,k:k+win-1),varargin{2})';
            end

            % Location & STE
            [Sample{sam_idx}.Location,Sample{sam_idx}.STE] = calcLocation(tmpData(:,k:k+win-1));

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

        else
            % Keep the unsolvedData
            unsolvedData = tmpData(:,k:end);
            Sample{sam_idx}.Data = Inf;
        end
    end
else
    Sample{sam_idx}.Data = Inf;
    unsolvedData = tmpData;
end



