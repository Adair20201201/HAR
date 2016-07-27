function Output = pre_pocessing_CS2(raw_txt)

%fid=fopen('./ActionData/00.txt','rt');
fid=fopen(raw_txt,'rt');

showtime=1;
b_t=[];

Data_pos=0;% Data point position(raw data)
Rows=[1:9];% Rows to format the data
Data=[];
Time=[];
while ~feof(fid)
    a_t = str2num(fgetl(fid))';
    time_t= a_t(1); %a(1) is the time stamp
    a_t(1)=[];
    b_t=[b_t;a_t];
    msg_len=13; %message length
    if size(b_t,1) < msg_len
        continue;
    end
    
    idx=0;
    for i=1:size(b_t,1)-(msg_len-1)
        if b_t(i)==255 && b_t(i+1)==255 &&...
                (b_t(i+2)==1 || b_t(i+2)==2 || b_t(i+2)==3 || b_t(i+2)==4 || b_t(i+2)==5 || b_t(i+2)==6) &&...% || b(i+2)==64 || b(i+2)==128 || b(i+2)==256 || b(i+2)==512) &&...
                (i+msg_len-1)<=size(b_t,1) %% FF FF 04 PIR1..PIR9 RSSI:total 13 Bytes
            %c=[c;b(i:i+msg_len-1)' ti];%the first message time=0
            Data_put = [];
            switch b_t(i+2)  % switch between P1 and node number
                case 1
                    %b_t(i+2) = 1;
                    Data_pos=Data_pos+1;
                    Data_put=Rows;
                    Time=[Time time_t];
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
    
    if idx+msg_len-1>size(b_t,1)
        b_t=b_t(idx:end);
    end
    
end

fclose(fid);

%Data=[Data;Time];

Hz=(size(Data,2)-1)/(Time(end)-Time(1));

Output.Data=Data;
Output.Time=Time;
Output.Hz=Hz;

%save periodData Data Hz Time

% Plot for *.mat %
% Plot_Node = 1
if 0
    for i=1:(size(Data,1)-1)/9
        figure(i)
        for ch=1:9
            Y=Data((i-1)*9+ch,:);
            subplot(5,2,ch);
            if showtime==1
                plot(Time,Y)
            else
                plot(Y)
            end
            ylim([0 3.5])
        end
    end
end

