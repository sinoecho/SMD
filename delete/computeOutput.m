function [variableStructure] = computeOutput(variableStructure)

trueHeartRate = variableStructure.HR_calculated;
FFT_array = variableStructure.FrameMatrix_fft;


startHR = (((trueHeartRate-10)/60)*1024)/15;
endHR = (((trueHeartRate+10)/60)*1025)/15;
%generate heartrate correctness mask using subfuction "findHRpeak_image"
[HR_image] = findHRpeak_image(FFT_array,startHR,endHR);

HRcorrectnessMask = 1./ceil(abs(HR_image-trueHeartRate));
HRcorrectnessMask(isinf(HRcorrectnessMask)) = 1;


%generate deep view output
variableStructure.DeepViewOutput = variableStructure.SNR_image_improved;

function [HR_image] = findHRpeak_image(FFT_array,startHR,endHR)

frame_rate = 30;
HR_axis = (60*frame_rate/2)*(0:(size(FFT_array,3)-1))/(size(FFT_array,3));

%convert BPM to indexes
HR_start_index = min(find(HR_axis>startHR));
HR_end_index   = min(find(HR_axis>endHR));

[C,I] = max(FFT_array(:,:,HR_start_index:HR_end_index),[],3);

%convert index to HR
croppedHRaxis = HR_axis(HR_start_index:HR_end_index);


HR_image = croppedHRaxis(I);
end

end
