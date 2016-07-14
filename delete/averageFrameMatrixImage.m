function variableStructure = averageFrameMatrixImage(variableStructure,errorMessage)

disp('Beginning averaging...');

if(variableStructure.filter_size>1) %you're actually averaging

    % Force filter size of the PPG_avg (frame average) function to be odd
    if (mod(variableStructure.filter_size, 2) == 0)
        variableStructure.filter_size = variableStructure.filter_size + 1;
    end
    
    if(variableStructure.useGPU==1)
        
        start_average1 = tic();
        disp('Averaging pixel data on GPU...');
        
        h = fspecial('average',31);
        test1 = gpuArray(variableStructure.FrameMatrix);
        
        for i=1:1:variableStructure.L
            frame = test1(:,:,i);
            avg_filter = gpuArray(h);
            output = filter2(h, frame);
            temp = gather(output);
            FrameMatrix_avg(:,:,i) = temp;
        end
        end_average1 = toc(start_average1);
        disp(['Total spatial averaging time is ', num2str(end_average1), ' seconds']);
    else %don't use GPU
        
        disp('Averaging pixel data on microprocessor...');
        n = 31; %size of average windows
        v = repmat(-0.0323,n,1);
        h = repmat(-0.0323,1,n );
        % Caculate the v and h when changing the size of averaging filter (n).
        %        avg_filter = fspecial('average',n);
        %        [U,S,V] = svd(avg_filter); %
        %        v = single(U(:,1) * sqrt(S(1,1)));
        %        h = single(V(:,1)' * sqrt(S(1,1)));
        
        [r,c,f] = size(variableStructure.FrameMatrix);
        FrameMatrix_avg = single(zeros(r,c,f));
        
        for i = 1:variableStructure.frames_used
            FrameMatrix_avg(:,:,i) = single(conv2(conv2(variableStructure.FrameMatrix(:,:,i),v,'same'),h,'same'));
        end
        
    end
else
    FrameMatrix_avg = variableStructure.FrameMatrix;
end

[variableStructure.row_size variableStructure.column_size variableStructure.L] = size(FrameMatrix_avg);

variableStructure.FrameMatrix_small = FrameMatrix_avg(1:variableStructure.fast_divisor:variableStructure.row_size, 1:variableStructure.fast_divisor:variableStructure.column_size, :);
variableStructure.FrameMatrix_small = double(variableStructure.FrameMatrix_small);
FrameMatrix_small_sharp = variableStructure.FrameMatrix(1:variableStructure.fast_divisor:variableStructure.row_size, 1:variableStructure.fast_divisor:variableStructure.column_size, 1);

clear FrameMatrix_avg

%%%%%%%%%%%%%%%% save gray reference image
slash = '\\';

%%%%%%%%%%%%%%%%% image scaling
X=uint16(variableStructure.FrameMatrix(:,:,1)); % use full size PPG image
Z=mat2gray(X,[double(min(min(X))) double(max(max(X)))]);

s3 = strcat(variableStructure.data_savePath,slash,'GrayRefer.dcm');
dicomwrite(Z,s3,variableStructure.Meta);

s4 = strcat(variableStructure.data_savePath,slash,'GrayRefer.tif');
imwrite(Z,s4);

variableStructure.gray=Z;
