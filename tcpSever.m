 pnet('closeall')

sock=pnet('tcpsocket',8888)
%con=pnet(sockcon,'tcplisten', ['noblock'] )

n = 2

while 1
    con=pnet(sock,'tcplisten');
    if con ~= -1
        while 1
            n;
            data=pnet(con,'read','noblock')
            str2num(data)
            n = n+1;
            if n == 4
                n = 0;
                %clc;
            end
            pause(0.5)
        end
    end
end

pnet(con,'close');
pnet(sock,'close');
