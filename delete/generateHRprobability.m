function [variableStructure] = generateHRprobability(variableStructure,errorMessage)

fprintf('Calculating HR probability...')

featureScores = variableStructure.hr_metric_3dArray;
constantOffset = ones(size(featureScores(:,:,1)));
W = [-62.9814  -10.6785   27.8771    1.0016   20.6321;
  -69.1597  -11.3584   30.8556    0.9196   19.3833];
 
DataScores1 = constantOffset*W(1,1) + featureScores(:,:,1)*W(1,2)+ featureScores(:,:,2)*W(1,3)+ (featureScores(:,:,3))*W(1,4)+ featureScores(:,:,4)*W(1,5);
DataScores2 = constantOffset*W(2,1) + featureScores(:,:,1)*W(2,2)+ featureScores(:,:,2)*W(2,3)+ (featureScores(:,:,3))*W(2,4)+ featureScores(:,:,4)*W(2,5);

allScores = cat(1,reshape(DataScores1,[1,size(DataScores1,1)*size(DataScores1,2)]),reshape(DataScores2,[1,size(DataScores1,1)*size(DataScores1,2)]))';
allScores = double(allScores);

P = exp(allScores) ./ repmat(sum(exp(allScores),2),[1 2]);

vesselProbability = reshape(P(:,2),[size(DataScores1,1),size(DataScores1,2)]);
variableStructure.vesselProbability = vesselProbability;

fprintf(' done.\n')
