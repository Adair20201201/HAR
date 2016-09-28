%% Show outline Samples
clear all
close all

Samples_num = 0;
Labels = [];
Sample_mult = [];
num = 30;

load Samples2
load outputRF
figure(2)
for i = 1:length(Samples)
    Sample_tmp = Samples(i);
    inferedLabels = rfPredict_Online(Sample_tmp, outputRF{1,1}.training.learnedParams);
    Labels = [Labels inferedLabels];
    Samples_num = Samples_num + length(Sample_tmp);
    % Save the last num samples
    Sample_mult = [Sample_mult Sample_tmp];
    if length(Sample_mult) >num
        Sample_mult = Sample_mult(length(Sample_mult) - num+1 :end);
        Labels = Labels(length(Sample_mult) - num+1 :end);
    end

    if length(Sample_mult) > 0
        % Plot the Location in continouse line
        %continouseTrajectory_online(Sample_mult);
        continouseTrajectory_online2(Sample_mult)
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
          
     pause(0.05)
                
end