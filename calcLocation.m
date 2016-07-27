function Location = calcLocation(Data)
% clear all
% close all
% load tmp
[a1,b1]=size(Data);
chlnum=9;%num of channels on each node
nodenum=a1/chlnum;%num of nodes; 
time_p=b1;%num of sample time point

Win=15;%Time window to cal ave
step=5;

%%%%%%%%%%%%%% Remove empty 0
for i_node=1:nodenum
    tmp=Data((i_node-1)*chlnum+1:i_node*chlnum,:);
    
    for j=1:size(tmp,2)
        if sum(tmp(:,j),1)==0
            if j>1
                tmp(:,j)=tmp(:,j-1);
            else
                tmp(:,j)=tmp(:,j+1);
            end
        end
        %%% Remove Peak %%%
        if j>1 && j<size(tmp,2)
            for k=1:chlnum
                if abs(tmp(k,j)-tmp(k,j-1))>0.4
                    tmp(k,j)=0.5*(tmp(k,j-1)+tmp(k,j+1));
                end
            end
        end
    end
    node(i_node).Voltage=tmp;
end

t=1;
idx=1;%index 4 STE
factor=2.5;%STE amplified factor
STE=zeros(a1,floor(time_p/Win));

Theld_STE=[
    %N1     N2      N3       N4       N5    
    1.8      1.1       1.0      1.1       1.6     % PIR1
    0.7      0.6       0.7      0.9       0.8     % PIR2 Up
    1.3      0.9       1.0      0.8       0.8     % PIR3
    0.7      0.6       0.7      0.4       0.4     % PIR4 Left
    1.6      0.9       1.0      1.8      1.1     % PIR5
    0.9      0.5       0.8       0.4      0.55     % PIR6 Right
    0.7      1.1       1.2      1.3       0.7     % PIR7
    0.9      0.5       0.8       0.6       0.85     % PIR8 Down
    1.3      1.1       1.0       0.9       1.0     % PIR9
    ];

%%%%% Backup after cal 20150720
% Theld_STE=[
%     %N1     N2      N3       N4       N5    
%     1.8      1.1       1.0      1.1       1.6     % PIR1
%     0.7      0.6       0.7      0.9       0.8     % PIR2 Up
%     1.3      0.8       1.0      0.8       0.8     % PIR3
%     0.7      0.6       0.7      0.4       0.4     % PIR4 Left
%     1.6      0.9       0.9      1.8      1.5     % PIR5
%     0.9      0.5       0.8       0.4      0.55     % PIR6 Right
%     0.7      0.5       0.7      0.6       0.6     % PIR7
%     0.9      0.5       0.8       0.6       0.85     % PIR8 Down
%     1.3      1.0       1.0       0.9       1.0     % PIR9
%     ];

%%%%%%  Add in 0715  %%%%%%
for i_node=1:nodenum
    STE=zeros(chlnum+1,floor(time_p/Win));
    STE2=[];%Every point
    idx=1;%index 4 STE
    %Seg_beg=[];%Segmentation beg time
    %Seg_end=[];%Segmentation end time
    for t=1:step:time_p-Win+1
        %%%% Compute STE %%%%
        tmp=abs(node(i_node).Voltage(:,t:t+Win-1)-repmat(mean(node(i_node).Voltage(:,t:t+Win-1),2),[1,Win]));
        STE(1:chlnum,idx)=sum(tmp,2)*factor;
        %STE(chlnum+1,idx)=node(i_node).Time(t);%time
        STE2(1:chlnum,(idx-1)*step+1:idx*step)=repmat(STE(1:chlnum,idx),[1,step]);        
        %%%%%%
        idx=idx+1;
    end    
    
    %%%% Compute BIN %%%%
    BIN=[STE(1:chlnum,:)>repmat(Theld_STE(:,i_node),[1,size(STE,2)])];
    BIN2=[STE2>repmat(Theld_STE(:,i_node),[1,size(STE2,2)])];   
    
    %%%% Compute Circle %%%
    Circle=BIN(1,:)*16+BIN(5,:)*8+BIN(9,:)*4+BIN(3,:)*2+BIN(7,:)*1;
    for t=1:size(Circle,2)
        tmp=Circle(t);
        if tmp==1
            Circle(t) = 5;
        elseif 2<=tmp&&tmp<=3
            Circle(t) = 4;
        elseif 4<=tmp&&tmp<=7
            Circle(t) = 3;
        elseif 8<=tmp&&tmp<=15
            Circle(t) = 2;
        elseif 16<=tmp
            Circle(t) = 1;
        end
    end
    
    %%%% Compute Dir %%%
    %Dir=BIN(6,:)*8+BIN(2,:)*4+BIN(4,:)*2+BIN(8,:)*1;
    Bin_tmp=[BIN(6,:);BIN(2,:);BIN(4,:);BIN(8,:)];
    STE_tmp=[STE(6,:);STE(2,:);STE(4,:);STE(8,:)];
    [B,IX]=sort(STE_tmp,1);
    %Bin_tmp(IX(1:2,:),:)=0;
    Dir=zeros(1,size(Bin_tmp,2));
    
    for t=1:size(Bin_tmp,2)
        if sum(Bin_tmp(:,t),1)>2
            Bin_tmp(IX(1:2,t),t)=0;
        end
        tmp=[8 4 2 1]*Bin_tmp(:,t);
        if tmp~=0
            Tab=[8 6 7 4 9 5 9 2 1 9 9 3 9 9 9];
            Dir(t)=Tab(tmp);
        end
    end
    
    %%%% Compute Position (Measurement) %%%
    Rd=[0 0.8 1.3 2.3 3];%Radius
    Ang=(pi/4)*2.5-[1:8]*(pi/4);%Angle
    X_pos=999*ones(1,size(BIN,2));
    Y_pos=999*ones(1,size(BIN,2));
    last_dir=[];
    last_cir=[];
    for t=1:size(BIN,2)
        if   Circle(t)~=0 
            last_cir=Circle(t);
            if Circle(t)==1
                X_pos(t)=0;
                Y_pos(t)=0;
            elseif (Dir(t)==9||Dir(t)==0)&&~isempty(last_dir)
                Dir_tmp=last_dir;
                Rd_tmp=Rd(Circle(t));
                X_pos(t)=Rd_tmp*cos(Dir_tmp);
                Y_pos(t)=Rd_tmp*sin(Dir_tmp);
            elseif Dir(t)~=9&&Dir(t)~=0
                Dir_tmp=Ang(Dir(t));
                last_dir=Dir(t);
                Rd_tmp=Rd(Circle(t));
                X_pos(t)=Rd_tmp*cos(Dir_tmp);
                Y_pos(t)=Rd_tmp*sin(Dir_tmp);
            end
%         elseif Circle(t)==0&&Dir(t)~=9&&Dir(t)~=0
%             if ~isempty(last_cir)
%                 Rd_tmp=Rd(last_cir);
%                 Dir_tmp=Ang(Dir(t));
%                 X_pos(t)=Rd_tmp*cos(Dir_tmp);
%                 Y_pos(t)=Rd_tmp*sin(Dir_tmp);              
%             end
        end
    end
    Shift=[%N1    N2    N3    N4    N5
                 0      2       2       -2      -2
                 0      2       -2      -2      2];%Location of the PIR nodes
    Mea=[X_pos+Shift(1,i_node);Y_pos+Shift(2,i_node);STE(chlnum+1,:)];
    
    node(i_node).Win=Win;
    node(i_node).STE=STE;
    node(i_node).STE2=STE2;
    node(i_node).BIN=BIN;
    node(i_node).BIN2=BIN2;
    node(i_node).Circle=Circle;
    node(i_node).Dir=Dir;
    node(i_node).Mea=Mea;
end

Theld_STE2=zeros(chlnum,nodenum);
for i_node=1:nodenum
    Theld_STE2(:,i_node)=max(node(i_node).STE(1:chlnum,:),[],2);
end

Mea2=999*ones(2,size(node(1).Mea,2));
for t=1:size(node(1).Mea,2)
    Mea_t=[];
    for i_node=1:nodenum
        if node(i_node).Mea(1,t)<900
            Mea_t=[Mea_t [node(i_node).Mea(1,t);node(i_node).Mea(2,t)]];
        end
    end
    switch size(Mea_t,2)
        case 1
            Mea2(:,t)=Mea_t;
        case 2
            Mea2(:,t)=0.5*(Mea_t(:,1)+Mea_t(:,2));
        case 3
            x1=Mea_t(1,1);
            z1=Mea_t(2,1);
            x2=Mea_t(1,2);
            z2=Mea_t(2,2);
            x3=Mea_t(1,3);
            z3=Mea_t(2,3);
            %Trilateration 
            if 0
                A=[x2-x1 z2-z1;x3-x1 z3-z1];
                b=0.5*[x2^2+z2^2-x1^2-z1^2;x3^2+z3^2-x1^2-z1^2];
                pos=inv(A'*A)*A'*b;  %(X;Z)
            else
                pos=1/3*[x1+x2+x3;z1+z2+z3];
            end
            Mea2(:,t)=[pos(1);pos(2)];
        case 4
            x1=Mea_t(1,1);
            z1=Mea_t(2,1);
            x2=Mea_t(1,2);
            z2=Mea_t(2,2);
            x3=Mea_t(1,3);
            z3=Mea_t(2,3);
            x4=Mea_t(1,4);
            z4=Mea_t(2,4);
            %maximum likelihood estimation
            if 0
                A=2*[x1-x4 z1-z4;x2-x4 z2-z4;x3-x4 z3-z4];
                snapnow;
                b=[x1^2-x4^2+z1^2-z4^2;x2^2-x4^2+z2^2-z4^2;x3^2-x4^2+z3^2-z4^2];
                pos=inv(A'*A)*A'*b;  %(X;Z)
            else
                pos=1/3*[x1+x2+x3+x4;z1+z2+z3+z4];
            end
            Mea2(:,t)=[pos(1);pos(2)];
    end
end
%node(1).Mea2=[Mea2;node(1).Mea(3,:)];%Store the Measurement fusion result+time in Node1

del_list=[];
for i=1:length(Mea2)
    if (Mea2(1,i)>900)&&(Mea2(2,i)>900)
        del_list=[del_list i];
    end
end

Mea2(:,del_list)=[];

node(1).Mea2=Mea2;%Store the Measurement fusion result in Node 1

Location=Mea2;
