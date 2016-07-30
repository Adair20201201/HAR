%% fft
function data_fft = data2fft(data)
%Fs = 15;  % Frenquency
data_fft = [];
for i = 1:size(data,1)
    L = size(data,2);
    NFFT = 2^nextpow2(L);  % Next power of 2 from length of data
    Y = fft(data(i,:),NFFT)/L;
    Y2 = 2*abs(Y(1:NFFT/2+1)); % Half  frequency spectrum
    %f = Fs/2*linspace(0,1,NFFT/2+1);
    data_fft = [data_fft Y2];
    %figure(2)
    %plot(f,Y2) 
end

