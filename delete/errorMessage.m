%errorInfor ={};
function [errorMessage] = errorMessageSave()
valueSet = {'Error: Image data is corrupt.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',
    
'Error: Image data is corrupt.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',


'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',


'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',

'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',

'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.'

'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',

'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',

'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',


'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',

'Warning: Blood flow signals found in image data are poor quality. This may result from the subject lacking perfusion in the tissue being assesed. We recommend re-capturing this image from the patient to confirm.',

'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',


'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.',

'Error: Image processing algorithm error.  Try capturing another image from the subject.  Please contact the manufacturer if problem persists.'};

keySet = {'3001','3013','3002','3003','3004','3005','3006','3007','3008','3009','0001','3010','3011','3012'};
errorMessage = containers.Map(keySet,valueSet);


end
