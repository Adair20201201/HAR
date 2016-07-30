clear all
close all

File_root = '.\SensorData_labled\Tan\'; 
tmp = strsplit('\',File_root);
File_name = cell2mat(tmp(end-1));
file_excel = dir('.\SensorData_labled\Tan\*.xls');
file_num = size(file_excel,1);

for fileN = 1:file_num
        File = File_root;
        tmp = strsplit('.',file_excel(fileN,1).name);
        File = [File,tmp(1)];
        File = cell2mat(File);
        
        
        [num txt] = xlsread([File '.xls']);
        
        disp(['正在转换文件: ', File]);
        csvwrite([File,'.csv'],num);
        %dlmwrite([File,'.csv'],num);
        
end