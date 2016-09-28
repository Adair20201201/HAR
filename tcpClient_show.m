con = pnet('tcpconnect','127.0.0.1',8888);

%raw_txt = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)/SensorData_labeled/Tan/1.txt';
raw_txt = 'G:\ActionDataColection\ActionData\SensorData_labled\Tan\1.txt';
fid=fopen(raw_txt,'rt');
b_t=[];

Data_pos=0;% Data point position(raw data)
Rows=[1:9];% Rows to format the data
msg_len = 13; % The length of data
Data=[];

win = 30;
gap = 15;
Beg_Location = 0;
unsolvedData = [];

while ~feof(fid)
    %% Read and send data
    a_t = str2num(fgetl(fid));
    time_t= a_t(1); %a(1) is the time stamp
    a_t(1)=[];
    %a_t
    pnet(con,'write',[num2str(a_t) ' ' ]);
    
    %% Pre_Process the data
    b_t=[b_t a_t];
    %b_t
    msg_len=13; %message length
    if size(b_t,2) < msg_len
        continue;
    end
    idx=0;
    for i=1:size(b_t,2)-(msg_len-1)
        if b_t(i)==255 && b_t(i+1)==255 &&...
                (b_t(i+2)==1 || b_t(i+2)==2 || b_t(i+2)==3 || b_t(i+2)==4 || b_t(i+2)==5 || b_t(i+2)==6) &&...% || b(i+2)==64 || b(i+2)==128 || b(i+2)==256 || b(i+2)==512) &&...
                (i+msg_len-1)<=size(b_t,2) %% FF FF 04 PIR1..PIR9 RSSI:total 13 Bytes
            %c=[c;b(i:i+msg_len-1)' ti];%the first message time=0
            Data_put = [];
            switch b_t(i+2)  % switch between P1 and node number
                case 1
                    %b_t(i+2) = 1;
                    Data_pos=Data_pos+1;
                    Data_put=Rows;
                case 2
                    %b_t(i+2) = 2;
                    Data_put=Rows+9*(b_t(i+2)-1);
                case 3
                    %b_t(i+2) = 3;
                    Data_put=Rows+9*(b_t(i+2)-1);
                case 4
                    %b_t(i+2) = 4;
                    Data_put=Rows+9*(b_t(i+2)-1);
                case 5
                    %b_t(i+2) = 5;
                    Data_put=Rows+9*(b_t(i+2)-1);
                case 6
                    %b_t(i+2) = 6;
                    Data_put=Rows+9*(b_t(i+2)-1);
            end
            
            % Save to *.mat
            if Data_pos > 0
                Data(Data_put, Data_pos)=b_t(i+3:i+msg_len-2)*3.3/255;
            end
            
            % Save to *.txt
            %dlmwrite(['e' num2str(b_t(i+2)) '.txt'],[time_t;b_t(i:i+msg_len-1)*3.3/255]','-append','newline','pc','precision','%.2f');
            idx=i+msg_len;
            
        end
    end
    
    if idx+msg_len-1>size(b_t,2)
        b_t=b_t(idx:end);
    end
    
    Data
   
    %% Segement the data
    tmpData = [Data unsolvedData];
    tmpData
    sam_idx = 1;
    if size(tmpData,2) >= win
        for k=1:gap:size(tmpData,2)
            if (k+win - 1)<= size(tmpData,2)
                % Data
                Sample{sam_idx}.Data = tmpData(:,k:k+win-1);
                
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


    pause(0.01)
end
pnet(con,'close');
