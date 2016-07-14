function [variableStructure] = findHeartRateFrame(variableStructure,errorMessage,findTxt)

FFT_array = variableStructure.FrameMatrix_fft;
startHR = variableStructure.SNR_HR_initialGuess - variableStructure.SNR_HR_inGuessToleranceStart;
endHR = variableStructure.SNR_HR_initialGuess + variableStructure.SNR_HR_inGuessToleranceEnd;

frame_rate = variableStructure.frame_rate;
HR_axis = (60*frame_rate/2)*(0:(size(FFT_array,3)-1))/(size(FFT_array,3));
variableStructure.HR_axis = HR_axis;
endHR_index = min(find(HR_axis>endHR));

test = variableStructure.vesselProbability;

Test_normal = test./max(max(test));


clear HR_votes votingPower


%msgID = 'Data:No good signal';
%msgtext = 'There is no good signal in the image data';
%ME = MException(msgID,msgtext);



try
    [rows ,cols, vals] = find(test>0.5);
    counter = 1;
    for ii = 1:length(rows)
        if(rows(ii)>variableStructure.border_size && rows(ii) < size(FFT_array,1)-(variableStructure.border_size+1))
            if(cols(ii)>variableStructure.border_size && cols(ii) < size(FFT_array,2)-(variableStructure.border_size+1))
                tempVect = squeeze(FFT_array(rows(ii),cols(ii),1:endHR_index));
                votingPower(counter) = test(rows(ii),cols(ii));
                [val loc] = max(tempVect);
                HR_votes(counter) = HR_axis(round(loc));
                counter = counter + 1;
            end
        end
    end
    
    uniqueHRvotes = unique(HR_votes);
    
    for ii = 1:length(uniqueHRvotes)
        %load i'th HR to test and find all the votes corresponding to it
        [indexes] = find(HR_votes==uniqueHRvotes(ii));
        totalWeightedVotes(ii) = sum(votingPower(indexes));
    end
    
catch
    
    warning('1st there is no good signal in the image data');
    variableStructure.error{10} = '0001'; % show the usder from the software team
    errorInfor = ['0001',' ',errorMessage('0001')];
    
    fid = fopen(findTxt, 'a+t'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
    [rows ,cols, vals] = find(Test_normal>0.5);
    counter = 1;
    for ii = 1:length(rows)
        if(rows(ii)>variableStructure.border_size && rows(ii) < size(FFT_array,1)-(variableStructure.border_size+1))
            if(cols(ii)>variableStructure.border_size && cols(ii) < size(FFT_array,2)-(variableStructure.border_size+1))
                tempVect = squeeze(FFT_array(rows(ii),cols(ii),1:endHR_index));
                votingPower(counter) = test(rows(ii),cols(ii));
                [val loc] = max(tempVect);
                HR_votes(counter) = HR_axis(round(loc));
                counter = counter + 1;
            end
        end
    end
    
    uniqueHRvotes = unique(HR_votes);
    
    for ii = 1:length(uniqueHRvotes)
        %load i'th HR to test and find all the votes corresponding to it
        [indexes] = find(HR_votes==uniqueHRvotes(ii));
        totalWeightedVotes(ii) = sum(votingPower(indexes));
    end
    
    
end

[numTotalVotes loc] = max(totalWeightedVotes);
%numTotalVotes = sum(totalWeightedVotes(loc-2:max(loc+2,length(totalWeightedVotes))));
trueHR = uniqueHRvotes(loc);
smallBuffer = variableStructure.SNR_improved_tolerance;
SNR_NoiseStart = trueHR - variableStructure.noise_post;
SNR_NoiseEnd = trueHR +  variableStructure.noise_post;

try
    variableStructure.SNR_image_improved = computeSNRimage_mod(FFT_array,frame_rate, trueHR,smallBuffer,SNR_NoiseStart,SNR_NoiseEnd);
    variableStructure.HR_calculated = trueHR;
    variableStructure.HR_calculated_votes = numTotalVotes;
    variableStructure.HR_calculated_confidence = round(numTotalVotes)/round(sum(votingPower));
    variableStructure.uniqueHRvotes = uniqueHRvotes;
    variableStructure.totalWeightedVotes = totalWeightedVotes;
    
catch
    warning('2nd there is no good signal in the image data');
    variableStructure.error{11} = '3010'; % show the usder from the software team
    errorInfor = ['3010',' ',errorMessage('3010')];
    
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
    
end

end


