function [Sample,unsolvedData,Beg_Location] = SegData_online(Output,win,gap,unsolvedData,Beg_Location,lastSample,varargin)
% input: Output --- Matrix that each colunm is a message receive from
%                            sensoes.
%           win --- Window Size for each segment (e.g. =30 points)
%           gap ---  the gap between two windows (e.g. =15 points)
%           unsolvedData --- Matrix that last time didn't be segmented into
%                                      a sample.
%           Beg_Location --- Just a flag that means whether the function
%                                     was the first time be called, 0 for first time 1 for other. 
%           lastSample --- Sample that the previous time or before this
%                                  sample.
%           varargin --- The optional variable, for selecting different or
%                              transform into different features, sunch as
%                              fft or k-means.
%
% output: Sample --- The samples those have been already segmented and more
%                                features such as Location, Speed had been
%                                added.
%             unsolvedData --- The matrix that haven't been segmented into
%                                        sample this time, it will combine
%                                        with next receive matrix.
%                                       
%             Beg_Location ---  Just a flag that means whether the function
%                                     was the first time be called, 0 for first time 1 for other. 

% Data Matrix (Only Data)
    tmpData=Output.Data;
    %Output.Data
    tmpData = [unsolvedData tmpData];
    size(tmpData)
    sam_idx = 2;%sample number
    Sample{1} = lastSample;
    
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



