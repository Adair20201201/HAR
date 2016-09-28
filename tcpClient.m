con = pnet('tcpconnect','127.0.0.1',8888);

user = 2; % Different user for different setting
switch user
    case 1 % Luo
        raw_txt = '/Users/xiaomuluo/Win7/E/kuaipan/sourcecode/MyDBank/new(20140330)/SensorData_labeled/Tan/1.txt';
        add_path_mac;
    case 2
        raw_txt = 'G:\ActionDataColection\ActionData\SensorData_labled\Tan\1.txt';
        add_path;
end

fid=fopen(raw_txt,'rt');
fid2 = fopen('sendData32_1.txt','a');

while ~feof(fid)
    %% Read and send data
    a_t = str2num(fgetl(fid));
    time_t= a_t(1); %a(1) is the time stamp
    a_t(1)=[];
    a_t
    pnet(con,'write',[num2str(a_t) ' ' ]);
    
    % Save the send data in txt
     fprintf(fid2,'%g\n',a_t);
    
    pause(0.005)
end
pnet(con,'close');
fclose(fid);
fclose(fid2);

