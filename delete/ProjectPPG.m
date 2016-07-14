function errorInfor  = ProjectPPG(DataCell,data_savePath,abortingPath)
% code version number 1.4.4; merge was performed on 8-Dec-2015

close all;
start_project = tic();

%%%%%%%%%%%%%%%%%%%%%%%%%%% LOAD PARAMETERS
PPG_variables;
cellArrayOfWorkspace = who;
for ii = 1:length(cellArrayOfWorkspace)
    tempName = cellArrayOfWorkspace{ii,1};
    eval(strcat('variableStructure.',tempName,'=',tempName,';'))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% LOAD DATA
DataRaw = single(zeros(variableStructure.row_size_initialImage,variableStructure.column_size_initialImage,...
	variableStructure.frames_initialImage));% create
z = length(DataCell);
[x,y] = size(DataCell{1});

[errorMessage] = errorMessageSave();
findTxt = strcat(data_savePath,'\','SMDErrorMessage.txt');
fid = fopen(findTxt, 'w'); % a+ anstatt w bei append
fclose(fid);
if( z~=variableStructure.frames_initialImage)
    variableStructure.error{1} = '3001';  % error one, data stucture.
    errorInfor = ['3001',' ',errorMessage('3001')];
    fid = fopen(findTxt, 'w'); % a+ anstatt w bei append
    fprintf(fid,'%s',errorInfor);
    fclose(fid);
end
if( x~=variableStructure.row_size_initialImage || y~=variableStructure.column_size_initialImage)
    variableStructure.error{14} = '3013';  % error one, data stucture.
    errorInfor = ['3013',' ',errorMessage('3013')];
    fid = fopen(findTxt, 'a+t'); % a+ anstatt w bei append
    fprintf(fid,'\n%s',errorInfor);
    fclose(fid);
end
assert(x==variableStructure.row_size_initialImage...
    && y ==variableStructure.column_size_initialImage && z==variableStructure.frames_initialImage,...
    'Raw Image dimensions are incorrect. Please check raw images. ') % aborting the processing


for i = 1:variableStructure.frames_initialImage
    DataRaw(:,:,i) = uint16(DataCell{i})*16;
end
clear DataCell
variableStructure.DataRaw=DataRaw;

%%%%%%%%%%%%%%%%%%%%%%%%%%% READ META DATA
if exist([data_savePath '\DICOM.txt'])
	T =readtable([data_savePath '\DICOM.txt'],'Delimiter',',','ReadVariableNames',false); 
	Table=table2struct(T);
	for i=1:length(Table)
	    Meta.(Table(i).Var1)=Table(i).Var2;
	end
else
	Meta=struct([]);
end
variableStructure.Meta=Meta;


%%%%%%%%%%%%%%%%%%%%%% GENERATE PSEUDO COLOR IMAGE
variableStructure.pseudo=Createcolor(variableStructure.DataRaw,variableStructure.data_savePath,...
    variableStructure.Meta);

variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing -- Loading data ');


%%%%%%%%%%


variableStructure.FrameMatrix = single(variableStructure.DataRaw(:,:,8:variableStructure.frames_used+7));
% variableStructure.FrameMatrix = single(round(variableStructure.FrameMatrix));
clearvars -except variableStructure start_project data_savePath findTxt errorMessage
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing -- Loaiding Data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Average frame matrix
start_average = tic();

try
    variableStructure = averageFrameMatrixImage(variableStructure,errorMessage);
catch
    
    warning('Average has the problem to run');
    variableStructure.error{2} = '3002';  % error two, data stucture. 3002- Averging function
    errorInfor = ['3002',' ',errorMessage('3002')];
    
    fid = fopen(findTxt, 'a+t'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
end

end_average = toc(start_average);
disp(['Total spatial averaging time is ', num2str(end_average), ' seconds']);
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing -- Average Steps');

%%%%%%%%%%%%%%%%%%%%%% estimate HR image stage 1&2
estimateHRimage12(variableStructure)

field = 'FrameMatrix';
variableStructure = rmfield(variableStructure,field);
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%Compute Fourier transform for entire matrix_type
fftProductionTime = tic();
try
    variableStructure = generatePPGfftArrays_deconv(variableStructure,errorMessage);
    
catch
    warning('generatePPGfftArrays_deconv has the problem to run');
    variableStructure.error{7} = '3007';
    errorInfor = 3007;
    errorInfor = ['3007',' ',errorMessage('3007')];
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    fprintf(fid,'\n%s',errorInfor);
    fclose(fid);
end
end_fftCalc = toc(fftProductionTime);
disp(['Total FFT computation and filtering time is ', num2str(end_fftCalc), ' seconds']);
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing --- FFT steps ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%Compute HR metrics on image
startHRmetrics = tic();
try
    
    [variableStructure] = computeHRmetricsVarStruc(variableStructure,errorMessage);
    
catch
    warning('compute HR Metrics part');
    variableStructure.error{8} = '3008';
    errorInfor = ['3008',' ',errorMessage('3008')];
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    fprintf(fid,'\n%s',errorInfor);
    fclose(fid);
end

endHRmetrics = toc(startHRmetrics);
disp(['compute HRmetrics VarStruc ', num2str(endHRmetrics), ' seconds']);
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing -- Compute HRMetrics ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% image build up
estimateHRimage3(variableStructure)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%Generate vessel probability (from signal shape)
startVessProbmetrics = tic();
try
    variableStructure = generateHRprobability(variableStructure,errorMessage);
    
catch
    warning('generate HR probability part');
    variableStructure.error{9} = '3009';
    errorInfor = ['3009',' ',errorMessage('3009')];
    fid = fopen(findTxt, 'a+t','n'); % a+ anstatt w bei append
    fprintf(fid,'\n%d',errorInfor);
    fclose(fid);
end


endVesselProbability = toc(startVessProbmetrics);
disp(['Genearate Vessel Probability ', num2str(endVesselProbability), ' seconds']);
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing -- Generate Probability');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%Determine true heart rate
startFindHeartRate = tic();
try
    variableStructure = findHeartRateFrame(variableStructure,errorMessage,findTxt);
catch
    warning('find the HR');
    variableStructure.error{12} = '3011';
    errorInfor = ['3011',' ',errorMessage('3011')];
    
    fid = fopen(findTxt, 'a+t'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
end
endFindHeartRate = toc(startFindHeartRate);
disp(['Find heart rate ', num2str(endFindHeartRate), ' seconds']);
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing -- Find the heart rate ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%Generate output from workflow
startCalculations = tic();
try
    [variableStructure] = computeOutput(variableStructure);
catch
    warning('get the outputs');
    variableStructure.error{13} = '3012';
    
    
    errorInfor = ['3012',' ',errorMessage('3012')];
    
    fid = fopen(findTxt, 'a+t'); % a+ anstatt w bei append
    
    fprintf(fid,'\n%s',errorInfor);
    
    fclose(fid);
end
endOfCalculations = toc(startCalculations);
disp(['Compute Deepview Output is ', num2str(endOfCalculations), ' seconds']);
variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing -- Compute the outputs ');

%%%%%%%%%%%%%%%%%%%%%% GENERATE DICOM IMAGE
variableStructure=CreateDICOM(variableStructure);

end_project = toc(start_project);
disp(['Total Project running ', num2str(end_project), ' seconds']);

variableStructure = flagCheck(variableStructure);
assert(variableStructure.flag==0,'Aborting processing ');
errorInfor = variableStructure.error;

end

