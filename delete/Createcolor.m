function RGB= Createcolor(DataRaw,data_savePath,Meta)
% [420-20 525-35 581-20 620-20 660-20 724-41 820-20 855-30]
% R = 620 nm
% G= 525 nm
% B = 420 nm
slash = '\\';
R = uint16(DataRaw(:,:,4));
G = uint16(DataRaw(:,:,2));
B = uint16(DataRaw(:,:,1));

R = im2double(R);
G = im2double(G);
B = im2double(B);

R1 = imadjust(R);
G1 = imadjust(G);
B1 = imadjust(B);

[M, N] = size(R);
% RGB combination
RGB = zeros(M, N, 3);
%RGB(:, :, 1) = 0.37*R1;
%RGB(:, :, 2) = 0.36*G1;
%RGB(:, :, 3) = 0.27*B1;

RGB(:, :, 1) = 0.69*R1;
RGB(:, :, 2) = 0.55*G1;
RGB(:, :, 3) = 0.51*B1;

% save pseudo color image
s1 = strcat(data_savePath,slash,'PseudoColor.dcm');
dicomwrite(RGB,s1,Meta); % RGB is of type double but converted to uint16 when read in by dicomread

s2 = strcat(data_savePath,slash,'PseudoColor.tif');
imwrite(RGB,s2);

end

