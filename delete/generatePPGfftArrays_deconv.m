function variableStructure = generatePPGfftArrays_deconv(variableStructure,errorMessage)


variableStructure.index_start_freq = floor((variableStructure.N/variableStructure.frame_rate)*(variableStructure.start_freq/60));
variableStructure.index_end_freq = round((variableStructure.N/variableStructure.frame_rate)*(variableStructure.end_freq/60));


[variableStructure.row_size variableStructure.column_size variableStructure.L] = size(variableStructure.FrameMatrix_small);

FrameMatrix_avg_list = reshape(variableStructure.FrameMatrix_small, variableStructure.row_size*variableStructure.column_size, variableStructure.L)';
field = 'FrameMatrix_small';
variableStructure = rmfield(variableStructure,field);

%% Deconvolution
try
    if variableStructure.deconvolution == 1
        
        fprintf('Deconvolution...')
        
        % Calculate, store and substract the mean
        mean_value = mean(FrameMatrix_avg_list);
        FrameMatrix_avg_list = FrameMatrix_avg_list - repmat(mean_value,[variableStructure.L,1]);
        
        % LP filter for the deconvolution
        normalized_freq = variableStructure.deconv_cutoff_freq / (variableStructure.frame_rate/2);
        % Filter to remove high frequencies on the envelope
        b = firls(20,[0 normalized_freq 2*normalized_freq 1],[1 1 0 0]);
        % group delay of the filter is 10;
        D = 10;
        % append D zeros to compensate for the filter delay
        FrameMatrix_to_filter = [FrameMatrix_avg_list ; zeros(D,variableStructure.row_size*variableStructure.column_size)];
        FrameMatrix_to_filter = filter(b,1, FrameMatrix_to_filter);
        % remove the D first samples
        FrameMatrix_LP = FrameMatrix_to_filter(1+D:end,:);
        
        clear FrameMatrix_to_filter
        
        % add back the mean to avoid division by negative numbers and zero
        FrameMatrix_LP = FrameMatrix_LP + repmat(mean_value,[variableStructure.L,1]);
        FrameMatrix_avg_list = FrameMatrix_avg_list +  repmat(mean_value,[variableStructure.L,1]);
        
        FrameMatrix_avg_list = FrameMatrix_avg_list./FrameMatrix_LP;
        
        variableStructure = flagCheck(variableStructure);
        assert(variableStructure.flag==0,'Aborting processing-Deconvolution ');
        
        fprintf(' done.\n')
    end
catch
    generatePwarning('De-convlution');
    variableStructure.error{3} = '3003';  % error three, data stucture.
    errorInfor = 3003;
    errorInfor = ['3003',' ',errorMessage('3003')];
    
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%d',errorInfor);
    
    fclose(fid);
    
end


if(variableStructure.windowFlag == 1) %windowing in the time domain
    disp('Windowing time domain signals');
    %window each pixel
    
    %ourWindow = hann(size(FrameMatrix_filtered,3));
    temp = hann(size(FrameMatrix_filtered,3));
    
    ourWindow(1,1,:) = temp;
    window3D = repmat(ourWindow,[size(FrameMatrix_filtered,1), size(FrameMatrix_filtered,2)]);
    meanImage = mean(FrameMatrix_filtered,3);
    meanImage3d = repmat(meanImage,[1,1,size(window3D,3)]);
    windowedFrameMatrix = (FrameMatrix_filtered - meanImage3d).*window3D;
    
    FrameMatrix_filtered = windowedFrameMatrix;
end



%% Detrend

%FrameMatrix_avg_list = detrend(FrameMatrix_avg_list);
try
    N = size(FrameMatrix_avg_list,1);
    bp = unique([1; N]);   % Include both endpoints
    lbp = length(bp);
    % Build regressor with linear pieces + DC
    a = zeros(N,lbp,class(FrameMatrix_avg_list));
    a(1:N,1) = (1:N)./N;
    a(1:N,end) = 1;
    FrameMatrix_avg_list = FrameMatrix_avg_list - a*(a\FrameMatrix_avg_list);   % Remove best fit
    variableStructure = flagCheck(variableStructure);
    assert(variableStructure.flag==0,'Aborting processing -- Detrend steps ');
catch
    warning('detrend part');
    variableStructure.error{4} = '3004';
    errorInfor = 3004;
    errorInfor = ['3004',' ',errorMessage('3004')];
    
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
end

%% Filter
try
    if(variableStructure.waveformFilterFlag == 1)
        %fprintf('Beginning filtering...')
        
        % Perform low pass filtering on PPG signal
        cutoff_freq = variableStructure.LPcutoffFreq; %Hz
        normalized_freq = cutoff_freq / (variableStructure.frame_rate/2);
        [b, a] = butter(8, normalized_freq, 'low');
        FrameMatrix_avg_list = filter(b,a, FrameMatrix_avg_list);
        
        % Perform high pass filtering on PPG signal
        cutoff_freq = variableStructure.HPcutoffFreq; %Hz
        normalized_freq = cutoff_freq / (variableStructure.frame_rate/2);
        [b, a] = butter(8, normalized_freq, 'high');
        FrameMatrix_avg_list = filter(b,a, FrameMatrix_avg_list);
        variableStructure = flagCheck(variableStructure);
        assert(variableStructure.flag==0,'Aborting processing --- Filtering step ');
        
    end
    
    % reshape to original size
    FrameMatrix_filtered = reshape(FrameMatrix_avg_list', variableStructure.row_size, variableStructure.column_size, variableStructure.L);
    FrameMatrix_filtered = single(FrameMatrix_filtered);
    variableStructure.FrameMatrix_filtered = FrameMatrix_filtered;
    clear filtered_point FrameMatrix_filtered_list FrameMatrix_avg_list
catch
    warning('filtering part');
    variableStructure.error{5} = '3005';
    errorInfor = ['3005',' ',errorMessage('3005')];
    
    errorInfor = 3005;
    
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
    
end
%fprintf(' done.\n')

%% FFT
try
    if (variableStructure.useGPU == false)
        
        fprintf('Computing FFT on microprocessor...');
        FrameMatrix_fft = fft(FrameMatrix_filtered,variableStructure.N,3);
    else %you're running a GPU
        
        fprintf('Computing FFT on GPU...');
        
        reset(parallel.gpu.GPUDevice.current());
        test1 = gpuArray(FrameMatrix_filtered);
        rows = size(FrameMatrix_filtered,1);
        cols = size(FrameMatrix_filtered,2);
        FrameMatrix_small_list = single(reshape(test1, (rows)*(cols), variableStructure.L))';
        
        total_pixels = rows*cols;
        block_size = total_pixels ./ variableStructure.num_of_blocks;
        
        y = zeros(variableStructure.N,total_pixels);
        
        for k=1:variableStructure.num_of_blocks
            start_point=1+block_size.*(k-1);
            end_point=block_size.*k;
            temp3 = gpuArray(FrameMatrix_small_list(:, start_point:end_point));
            
            
            output = fft(temp3, variableStructure.N);
            output = abs(output);
            clear temp3;
            temp = gather(output);
            clear output;
            
            y(:,start_point:end_point) = single(temp);
            clear temp;
            disp(['Part ' num2str(k) ' of ' num2str(variableStructure.num_of_blocks) ' complete']);
            
            if variableStructure.device.FreeMemory < 1e9
                reset(parallel.gpu.GPUDevice.current());
            end
        end
        
        y = single(y');
        
        FrameMatrix_fft = reshape(y, (rows), (cols), variableStructure.N);
        FrameMatrix_fft = FrameMatrix_fft(:,:,1:variableStructure.N/2);
    end
    
    clear FrameMatrix_filtered
    variableStructure.FrameMatrix_fft = abs(FrameMatrix_fft(:,:,1:(variableStructure.N/2)));
    
    fprintf('done.\n');
catch
    
    warning('FFT part');
    variableStructure.error{6} = '3006';
    errorInfor = 3006;
    errorInfor = ['3006',' ',errorMessage('3006')];
    
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
end
end
