function blk = processStreamToBlock(st)
    %
    % each block is organized
    % as blk(1,1)=block 1, image 1
    %    blk(2,1)=block 2, image 1
    %

    %
    % create 28 blocks, each of 60,000
    m='00000000000000000000000000000000000000000000000000000000';
    blk(28,length(st),:)=m(:);

    for i=1:length(st)
        m_img = st(:,:,i);

        for j=1:28
            row=m_img(j,:);
            
            % convert each row to hex
            acc='00000000000000000000000000000000000000000000000000000000';
            for k=1:28
                w='00';
                u=dec2hex(row(k));
                if u < 2
                    w(2)=u;
                else
                    w=u;
                end
                acc((2*k-1):(2*k))=w;
            end
            blk(j,i,:)=acc;
        end
    end

end