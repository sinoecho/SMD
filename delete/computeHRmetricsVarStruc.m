function [variableStructure] = computeHRmetrics(variableStructure,errorMessage)
fprintf('HR metrics calculation...')

FrameMatrix_fft = variableStructure.FrameMatrix_fft;
frame_rate = variableStructure.frame_rate; % Hz

% limit values for SNR, change to 60-200. 
computed_HR =  variableStructure.SNR_HR_inGuessTolerance;
HR_uncertainty_bufferLeft = variableStructure.HR_uncertainty_bufferLeft; % 50 BPM

HR_uncertainty_bufferRight = variableStructure.HR_uncertainty_bufferRight;

noiseStart = variableStructure.SNR_NoiseStart;
noiseEnd = variableStructure.SNR_NoiseEnd;

% limit values for the other 3 metrics
threshold = variableStructure.crossingThreshold; %0.7 implies 70% of the max value
startHR = variableStructure.HR_metrics_HRstart; % BPM 40
endHR_1 =variableStructure.HR_metrics_HRend1;   % BPM 250
endHR_2 =variableStructure.HR_metrics_HRend2;   % BP 390

%define the heart rate frequency axis (units BPM)
HR_axis = (60*frame_rate/2)*(0:(size(FrameMatrix_fft,3)-1))/(size(FrameMatrix_fft,3));

%convert BPM to indexes
HR_start_index = min(find(abs(HR_axis>(computed_HR-HR_uncertainty_bufferLeft)))); %80 -20 = 60
HR_end_index   = min(find(abs(HR_axis>(computed_HR+HR_uncertainty_bufferRight)))); %80 + 120 = 200 BPM
noiseStart_index = min(find(abs(HR_axis>noiseStart)));
noiseEnd_index = min(find(abs(HR_axis>noiseEnd)));

startHR_index = min(find(HR_axis>startHR)); %#ok<MXFND>
endHR_index1 = min(find(HR_axis>endHR_1)); %#ok<MXFND>
endHR_index2 = min(find(HR_axis>endHR_2)); %#ok<MXFND>

%% SNR

%define the signal images
signalImage = FrameMatrix_fft(:,:,HR_start_index:HR_end_index); % 10-110 bpm
signalImage_2D = mean(signalImage,3);
%define the noise images
noiseImage = FrameMatrix_fft(:,:,noiseStart_index:noiseEnd_index);
noiseImage_2D = mean(noiseImage,3);

%compute the pixel-by-pixel ratio of signal/noise
SNR_image = signalImage_2D./noiseImage_2D;

%% maxOverMean and numStdevsAway
signal = FrameMatrix_fft(:,:,startHR_index:endHR_index1);

% Perform the operations over the matrices to avoid for loops
% Max, mean and std to perform along the 3rd dimension of the array
% maxOverMean = max(signal,[],3)./mean(signal,3);
% stdevs_away_from_mean = ( max(signal,[],3) - mean(signal,3) )./std(signal,0,3);

% This is a little more efficent than the previous
max_signal = max(signal,[],3);
mean_signal = mean(signal,3);
maxOverMean_image = max_signal./mean_signal;
numStdevsAway_image = (max_signal - mean_signal)./std(signal,0,3);

%% num crossings

% move the signal so the different threshold are all crossing zero
% this is equivalent to substract the threshold for each pixel to the
% original signal

% Next line is equivalent to
% number_points_time = endHR_index2 - startHR_index +1;
% signal = FrameMatrix_fft(:,:,startHR_index:endHR_index2) - threshold*repmat(max(FrameMatrix_fft(:,:,startHR_index:endHR_index2),[],3),[1 1 number_points_time]);
% and it's a faster implementation
signal = bsxfun(@minus,FrameMatrix_fft(:,:,startHR_index:endHR_index2),threshold*max(FrameMatrix_fft(:,:,startHR_index:endHR_index2),[],3));

% indices_crosses = find(diff(test>0,1,3)~=0)+1;
% calculate number of crosses
numCrossings_image = sum(abs(diff(signal>0,1,3)),3);

%% 
variableStructure.hr_metric_3dArray = cat(3,maxOverMean_image,numStdevsAway_image,numCrossings_image,SNR_image);

fprintf(' done.\n');
