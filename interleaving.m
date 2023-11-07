clc
clear

T=readtable("iladata3.csv");
V=T.design_1_i_design_1_i_usp_rf_data_converter_0_m00_axis_tdata_12;

N=4*length(V);
dt=0.5e-9;
t=linspace(0,4*length(V)*dt,N);
S=zeros(size(1,4*length(V)));
V1=zeros(size(V));
V2=zeros(size(V));
V3=zeros(size(V));
V4=zeros(size(V));
count=1;
for i=1:length(V)
    I=int64(V(i));
    I1=bitand(I, int64(0xFFFF));
    I2=bitand(bitsrl(I,16), int64(0xFFFF));
    I3=bitand(bitsrl(I,32), int64(0xFFFF));
    I4=bitand(bitsrl(I,48), int64(0xFFFF));

    V1(i)=uint16_to_int16(I1);
    V2(i)=uint16_to_int16(I2);
    V3(i)=uint16_to_int16(I3);
    V4(i)=uint16_to_int16(I4);

    S(count)=uint16_to_int16(I1);
    S(count+1)=uint16_to_int16(I2);
    S(count+2)=uint16_to_int16(I3);
    S(count+3)=uint16_to_int16(I4);
    count=count+4;
end

plot(t,S);