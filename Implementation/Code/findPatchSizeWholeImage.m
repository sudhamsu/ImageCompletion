function returnedIm = findPatchSizeWholeImage(im)
returnedIm=im(:,:,1);
for i=1:size(im,1)
    for j=1:size(im,2)
        returnedIm(i,j)= findPatchSize(im, i, j);
    end
end
