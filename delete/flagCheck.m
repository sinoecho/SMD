function [variableStructure] = flagCheck(variableStructure)
A =  exist([variableStructure.abortingPath,'\','SMDAbort.txt'], 'file');

if A ==2
    variableStructure.flag = 1; 
    %delete([data_savePath,'\','Aboritng.mat']);
    
end