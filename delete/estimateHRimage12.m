function estimateHRimage12(variableStructure)
imageHandle = figure('Visible','off');
data_savePath=variableStructure.data_savePath;
slash='\\';

% 1st stage, display gray refence in 3 channels
X=variableStructure.FrameMatrix(:,:,1); %% saved in averageFrameMatrixImage, already scaled, mirrored and rotate 90
Y=mat2gray(X,[double(min(min(X))) double(max(max(X)))]);
Z=ceil(Y*size(jet,1));
s= strcat(data_savePath,slash,'imagebuildup1.tif');
imwrite(Z,jet,s);

% 2nd stage, display 1st of the averaged image
im2=uint16(variableStructure.FrameMatrix_small(:,:,1)); % averaged image
% remove edges before rescaling
edge=variableStructure.border_size;
im2([1:edge,end-edge:end],:)=im2(17,17);
im2(:,[1:edge,end-edge:end])=im2(17,17);
Y=mat2gray(im2,[double(min(min(im2))) double(max(max(im2)))]);
Z=ceil(Y*size(jet,1));
% image interpolation
im2=imresize(Z,variableStructure.fast_divisor,'bilinear');
s= strcat(data_savePath,slash,'imagebuildup2.tif');
imwrite(im2,jet,s);

