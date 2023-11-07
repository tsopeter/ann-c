clc
clear
X=processImagesMNIST('Images/train-images-idx3-ubyte.gz');
Y=processStreamToBlock(X);


% reconstruct first image
% U=zeros(28,28);
% 
% for i=1:28
%     block=Y(i,1,:);
%     for j=1:28
%         u=block((2*j-1):(2*j));
%         num=hex2dec(u(:).');
%         U(i,j)=num;
%     end
% end
% 
% figure;
% imagesc(U);
% 
% figure;
% imagesc(X(:,:,1));

%
% store into mem file

output_file_name_header='./MemoryFile/Train/mnist.train.f';
output_file_name_ext='.mem';
for i=1:28
    fileID=fopen([output_file_name_header, num2str(i), output_file_name_ext], 'w');
    for j=1:length(X)
        v=Y(i,j,:);
        v=v(:).';
        fprintf(fileID, "%s\n",v);
    end
end

L=processLabelsMNIST('Images/train-labels-idx1-ubyte.gz');
output_file_name='./MemoryFile/Train/mnist.labels.mem';
fileID=fopen(output_file_name, 'w');
for i=1:length(L)
    v=int8(L(i))-1;
    fprintf(fileID, "%s\n", dec2hex(v));
end
