function DataCell=DataGenerator(data_loc)

[listing] = dir([data_loc '\*.tif*']);
frame_number = 1;
for i=1:1:407  
    filename = listing(i).name;
    frame_temp = imread([data_loc '\' filename]);
    DataRaw(:,:,frame_number) = frame_temp;
    frame_number = frame_number + 1;
end

if frame_number==809
    DataRaw=DataRaw(:,:,2:end);
end
for i = 1:407
       DataCell{i}=DataRaw(:,:,i) ;
end

end