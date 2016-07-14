function variableStructure = CreateDICOM(variableStructure)
%%
close all
slash = '\\';
imageHandle = figure('Visible','off');
X=variableStructure.DeepViewOutput;

%% image interpolation
X=imresize(X,[variableStructure.row_size_initialImage variableStructure.column_size_initialImage],'bilinear'); % bicubic will create negative values
variableStructure.DeepViewOutput=X;
%% convert DeepView output to 3 channel jet colormap
Y=mat2gray(X,[double(min(min(X))) double(max(max(X)))]);
Z= ind2rgb(gray2ind(Y,length(jet)),jet);%% new function for changing DeepView into 3 channel for DICOM output

s5 = strcat(variableStructure.data_savePath,slash,'DeepviewOutput.dcm');
dicomwrite(Z,s5,variableStructure.Meta);

s6 = strcat(variableStructure.data_savePath,slash,'DeepviewOutput.tif');
imwrite(Z,s6);

%% generate DICOM multiframe image with meta data
%% stack dicom images, in the order of pseudo, gray, DeepView output
stack(:,:,1:3,1)=variableStructure.pseudo;
stack(:,:,1:3,2)=cat(3,variableStructure.gray,variableStructure.gray,variableStructure.gray); % write grayscale in 3 channels
stack(:,:,1:3,3)=Z; 
s=strcat(variableStructure.data_savePath,slash,'stack.dcm');
dicomwrite(uint8(255*stack),s,variableStructure.Meta);

% overlay(variableStructure)
% %%%%%%%% overlay testing:
% figure;
% % bottom=rgb2gray(variableStructure.pseudo); %% bottom layer using pseudo
% bottom=variableStructure.Z; %% bottom layer using gray reference image
% I= max(max(X))*double(X)/(max(max(double(bottom))));
% Imask = zeros(size(I));
% I(I<1) = Imask(I<1);  %%%%%% set less than 1 elements of I to 0
% 
% figure(8);
% % imshow(variableStructure.pseudo);
% imagesc(repmat(variableStructure.Z,[1,1,3]));
% hold on;
% h=imagesc(variableStructure.DeepViewOutput);
% colormap(spring)
% hold off;
% title('Overlay image of DeepView output and FFT image')
% set(h,'AlphaData',I/max(I(:)));
% set(gca,'position',[0 0 1 1],'units','normalized')
% truesize(gcf,[1408 1044]) %truesize, both should work
% set(gcf,'PaperPosition',[0 0 1408 1044])
% saveas(gcf,[variableStructure.data_savePath,slash,'overlay.tif'])

end
