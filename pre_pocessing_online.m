function [Output,unSolvedData,partMetric] = pre_pocessing_online(data_raw,unSolvedData,partMetric)
%partMetric
Rows=1:9;% Rows to format the data
Data=[];
unSolvedData=[unSolvedData data_raw]; % Add previous data
%unSolvedData
msg_len = 13; % The length of data
idx=0;
num = 0; % The total number of mesige(13)
begNode = 0; % Which node of the first messsige belong to
if size(unSolvedData,2) >=msg_len
    
    for i=1:size(unSolvedData,2)-(msg_len-1)
        if unSolvedData(i)==255 && unSolvedData(i+1)==255 &&...
                (unSolvedData(i+2)==1 || unSolvedData(i+2)==2 || unSolvedData(i+2)==3 || unSolvedData(i+2)==4 || unSolvedData(i+2)==5 || unSolvedData(i+2)==6) &&...% || b(i+2)==64 || b(i+2)==128 || b(i+2)==256 || b(i+2)==512) &&...
                (i+msg_len-1)<=size(unSolvedData,2) %% FF FF 04 PIR1..PIR9 RSSI:total 13 Bytes
            %c=[c;b(i:i+msg_len-1)' ti];%the first message time=0
            num = num + 1;
            if num == 1 
                if ~isempty(partMetric)
                    Data = partMetric;
                    Data_pos = 1;
                else
                    Data_pos = 0;
                end    
            end
            
            Data_put = [];
            switch unSolvedData(i+2)  % switch between P1 and node number
                case 1
                    %b_t(i+2) = 1;
                    Data_pos=Data_pos+1;
                    Data_put=Rows;
                    %Time=[Time time_t]; 
                case 2
                    %b_t(i+2) = 2;
                    Data_put=Rows+9*(unSolvedData(i+2)-1);
                case 3
                    %b_t(i+2) = 3;
                    Data_put=Rows+9*(unSolvedData(i+2)-1);
                case 4
                    %b_t(i+2) = 4;
                    Data_put=Rows+9*(unSolvedData(i+2)-1);
                case 5
                    %b_t(i+2) = 5;
                    Data_put=Rows+9*(unSolvedData(i+2)-1);
                case 6
                    %b_t(i+2) = 6;
                    Data_put=Rows+9*(unSolvedData(i+2)-1);
            end
                

                % Save to *.mat
                if Data_pos > 0
                    Data(Data_put, Data_pos)=unSolvedData(i+3:i+msg_len-2)*3.3/255;
                end
               
            % Save to *.txt
            %dlmwrite(['e' num2str(b_t(i+2)) '.txt'],[time_t;b_t(i:i+msg_len-1)*3.3/255]','-append','newline','pc','precision','%.2f');
            idx=i+msg_len;
            
        end
        
    end
    %Data
    if ~isempty(Data)
        if size(Data(:,end),1) < 45 || size(find(Data(:,end) == 0),1) >= 9
            %Data
            partMetric = zeros(45,1);
            [row,cul] = size(Data(:,end));
            partMetric(1:row,1:cul) = Data(:,end);
            %partMetric
            if size(Data,2) > 1
                Output.Data=Data(:,1:end-1);
            else
                Output.Data = [];
            end
        else
            Output.Data = Data;
            partMetric = [];
        end
    else
        Output.Data = [];
        partMetric = [];
    end
    
     if idx > 0 && idx+msg_len-1>size(unSolvedData,2)
        unSolvedData=unSolvedData(idx:end);
     end
     
else
    Output.Data=Data;
end

%partMetric

