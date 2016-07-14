function [SNR_image] = computeSNRimage_mod(FrameMatrix_fft,frame_rate, computed_HR, tolerance,noiseStart,noiseEnd)
%define the heart rate frequency axis (units BPM)
HR_axis = (60*frame_rate/2)*(0:(size(FrameMatrix_fft,3)-1))/(size(FrameMatrix_fft,3));

[~,HR_index] = min(abs(HR_axis-computed_HR)); 
offset = round(tolerance/(HR_axis(2)-HR_axis(1)));

% indices for the start and end of the noise
[~,index_noiseStart] = min(abs(HR_axis-noiseStart)); 
[~,index_noiseEnd] = min(abs(HR_axis-noiseEnd)); 

HR_indices = HR_index-offset:HR_index+offset;
noise_indices = index_noiseStart:index_noiseEnd;

 % remove HR indices from noise
[~,~,index_noise2remove] = intersect(HR_indices,noise_indices);
noise_indices(index_noise2remove) = []; % remove HR indices from noise

%define the signal images
signalImage = FrameMatrix_fft(:,:,HR_indices);
signalImage_2D = mean(signalImage,3);
noiseImage = FrameMatrix_fft(:,:,noise_indices);
noiseImage_2D = mean(noiseImage,3);

%compute the pixel-by-pixel ratio of signal/noise
SNR_image = signalImage_2D./noiseImage_2D; 