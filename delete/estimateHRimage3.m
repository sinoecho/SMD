% function: Using HR initial guess to generate an intial SNR image
% signal range: SNR_HR_initalGuess+/-SNR_HR_inGuessTolerance
% noise range: SNR_NoiseStart:SNR_NoiseEnd
% input: variableStructure
% output: initial PPG image
% author: Lu May 26, 2015

function estimateHRimage3(variableStructure)
imageHandle = figure('Visible','off');
% use SNR image in variableStructure.hr_metric_3dArray
slash='\\';
X = variableStructure.hr_metric_3dArray(:,:,end); % SNR is the last, class= single

% 3rd stage, display the estimated HR image
Y=mat2gray(X,[double(min(min(X))) double(max(max(X)))]);
Z=ceil(Y*size(jet,1));

% image interpolation
Z=imresize(Z,variableStructure.fast_divisor,'bilinear');

% image save with temp name first
s= strcat(variableStructure.data_savePath,slash,'imagebuildup3.tif');
imwrite(Z,jet,s);

