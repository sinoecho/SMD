%[Processing Flags]
detrend_flag=0; %1 = zscore, 0 = detrend;
filter_type_flag=0;
windowFlag = 0; 
waveformFilterFlag = 1; %don't filter = 0, filter = 1;

%[PPG Processing Variables]
deconvolution = 1; %use deconvolution = 1, don't = 0;
deconv_cutoff_freq = 1; %1.2; %Hz
%[PPG Processing Variables]
row_size_initialImage= 1044;
column_size_initialImage=1408;
frames_initialImage=407; % number of frames collected
frames_used=400; % number of frames actually used

frame_rate=30;
N=2048; %the length of the FFT to preform
filter_size=31;
row_size=1044;
column_size=1408;

%Filtering waveforms
LPcutoffFreq = 10;%Hz
HPcutoffFreq = 0.75; %Hz

gamma_flag=0;

useGPU = 0;

fast_divisor=4;
border_size=round(16 / fast_divisor);

%HR classification parameters
SNR_HR_initialGuess = 80; %BPM
SNR_HR_inGuessTolerance = 30; % +/- BPM on either side of the intial guess
SNR_HR_inGuessToleranceStart = 50;
SNR_HR_inGuessToleranceEnd  = 130;    
SNR_NoiseStart = 200; %BPM
SNR_NoiseEnd = 300; %BPM
SNR_improved_tolerance = 3; % +/- BPM on either side of the calculated HR
HR_uncertainty_bufferLeft = 20;
HR_uncertainty_bufferRight = 120;

%MaxOverMean and NumStdevsAway
HR_metrics_HRstart = 40; %BPM (Where will we start the metrics)
HR_metrics_HRend1 = 250; %BPM (Where will we end the metrics)
%NumCrossings
crossingThreshold = 0.7;
HR_metrics_HRend2 = 390; %BPM (Where will we end this metric)

%[Output File Frequency Range]
start_freq=20;
end_freq=200;

flag = 0;
error = {};
% post processing
variableStructure.noise_post=15;