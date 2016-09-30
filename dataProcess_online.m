clear all
close all
%pnet('closeall')

user = 2; % Different user for different setting
switch user
    case 1 % Luo
        add_path_mac;
    case 2
        add_path;
end

sock=pnet('tcpsocket',8888);
unSolvedRawData = [];
unSolvedData = [];
Sample_mult = [];
Labels = [];
Samples_num = 0;
num = 30;
Beg_Location = 0;
lastSample.Data = Inf;
partMetric = [];
lastTransID = 0;
numDele = 0; % The num that is deleted becaise the PF was zero
 
figure
% Save the data
% fid = fopen('receiveData32_2.txt','a');
% fid2 = fopen('AllData_online32_2.txt','wb');
% fid3 = fopen('samplesSegment_online32_2.txt','wb');
while 1
    con=pnet(sock,'tcplisten');
    if con ~= -1
        while 1
            data = pnet(con,'read','noblock');
            if ~isempty(data)
                %data
                data=str2num(data);
                
                % Save the received data in txt
                %fprintf(fid,'%g\n',data);
                
                %Output
                 [Output,unSolvedRawData,partMetric] = pre_pocessing_online(data,unSolvedRawData,partMetric);
            
            else 
                continue
            end
            
            Sample_tmp = [];
            if ~isempty(Output.Data)
                
                % Save the matrix data in txt
                if 0
                     for i = 1:size(Output.Data,1)
                        for j = 1:size(Output.Data,2)
                            fprintf(fid2,'%f',Output.Data(i,j));
                            fprintf(fid2,'%c','  ');
                        end
                        fprintf(fid2,'%c\n','');
                    end
                    fprintf(fid2,'%c\n','');
                    fprintf(fid2,'%c\n','');    
                end
                              
               win = 30;
                gap = 15;
                [Sample,unSolvedData,Beg_Location] = SegData_online(Output,win,gap,unSolvedData,Beg_Location,lastSample);
                %Sample 
                if length(Sample) >2
                    Sample = Sample(2:end);
                    %Sample = Sample(1:end-1);
                    if  length(Sample) > 0
                        for i = 1:length(Sample)
                            if (Sample{i}.Data ~= Inf)
                                if ~isempty(Sample{i}.PF)
                                    Sample_tmp{end + 1} =  Sample{i};
                                    %Sample_tmp
                                    
                                    % Save samples in txt
                                    if 0
                                        tmp = Sample{i}.Data;
                                        for j = 1:size(tmp,1)
                                            for k = 1:size(tmp,2)
                                                fprintf(fid3,'%f',tmp(j,k));
                                                fprintf(fid3,'%c','  ');
                                            end
                                            fprintf(fid3,'%c\n','');
                                        end
                                        fprintf(fid3,'%c\n','');
                                        fprintf(fid3,'%c\n','');
                                    end
  
                                else
                                    numDele = numDele + 1;
                                    %pause
                                end
                            end
                        end
                        
                    end
                end
            else
                continue
                
            end
                
            
            if length(Sample_tmp) > 0
                Samples_num = Samples_num + length(Sample_tmp);
                 lastSample = Sample_tmp{end};
                % Plot the Location in Sctter
                %scatterTrajectory_online(Sample_tmp);
                
                % Predict the samples
                load outputRF
                inferedLabels = rfPredict_Online(Sample_tmp, outputRF{1,1}.training.learnedParams);
                Labels = [Labels inferedLabels];
                
                % Save the last num samples
                Sample_mult = [Sample_mult Sample_tmp];
                if length(Sample_mult) >num && ~isempty(Sample_mult)
                    Sample_mult = Sample_mult(length(Sample_mult) - num+1 :end);
                    Labels = Labels(length(Sample_mult) - num+1 :end);
                end

                if length(Sample_mult) > 0
                    % Plot the Location in continouse line
                    continouseTrajectory_online(Sample_mult);
                    %continouseTrajectory_online2(Sample_mult)

                end
                
                % Show the Predict result 
                subplot(2,2,2);
                cla
                if Samples_num < num &&  length(Sample_mult) > 0
                    %scatter(1:length(Labels),Labels,[],'r','.');
                    stem(1:length(Labels),Labels,'fill');
                    axis([1 num 0 10])
                elseif Samples_num >= num && length(Sample_mult) > 0
                    %scatter((Samples_num-num+1):Samples_num,Labels((Samples_num-num+1):end),[],'r','.');
                    stem((Samples_num-num+1):Samples_num,Labels((Samples_num-num+1):end),'fill');
                    axis([(Samples_num-num+1) Samples_num 0 10])
                end
                
            else
                continue
            end
            pause(0.5)
        end
    end
end
pnet(sock,'close');
% fclose(fid);
% fclose(fid2);
% fclose(fid3);


