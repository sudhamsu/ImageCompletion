function returnedPatch = findClosestPatch(patch, im)
maxLevels     = 3;
k             = 1.4;
initialScale  = 2;
minL2distance = Inf;
currScale     = 1;
imRotated90   = imrotate(im,90);
imRotated180  = imrotate(im,180);
imRotated270  = imrotate(im,270);
for n=initialScale:-1:1
    n
    resizedImage=imresize(im,currScale,'Antialiasing',false);
    resizedImageRotated180=imresize(imRotated180,currScale,'Antialiasing',false);
    for i=1:size(resizedImage,1)-size(patch,1)+1
        for j=1:size(resizedImage,2)-size(patch,2)+1
            currImagePatch=resizedImage(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
            currImagePatch=resizedImageRotated180(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
        end
    end
    resizedImageRotated90=imresize(imRotated90,currScale,'Antialiasing',false);
    resizedImageRotated270=imresize(imRotated270,currScale,'Antialiasing',false);
    for i=1:size(resizedImageRotated90,1)-size(patch,1)+1
        for j=1:size(resizedImageRotated90,2)-size(patch,2)+1
            currImagePatch=resizedImageRotated90(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
            currImagePatch=resizedImageRotated270(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
        end
    end
    currScale=currScale/k;
end
currScale=1;
for n=initialScale+1:maxLevels
    n
    currScale=currScale*k;
    resizedImage=imresize(im,currScale,'Antialiasing',false);
    resizedImageRotated180=imresize(imRotated180,currScale,'Antialiasing',false);
    for i=1:size(resizedImage,1)-size(patch,1)+1
        for j=1:size(resizedImage,2)-size(patch,2)+1
            currImagePatch=resizedImage(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
            currImagePatch=resizedImageRotated180(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
        end
    end
    resizedImageRotated90=imresize(imRotated90,currScale,'Antialiasing',false);
    resizedImageRotated270=imresize(imRotated270,currScale,'Antialiasing',false);
    for i=1:size(resizedImageRotated90,1)-size(patch,1)+1
        for j=1:size(resizedImageRotated90,2)-size(patch,2)+1
            currImagePatch=resizedImageRotated90(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
            currImagePatch=resizedImageRotated270(i:i-1+size(patch,1),j:j-1+size(patch,2));
            if size(find(isnan(currImagePatch)),1)==0
                currL2norm=calculateL2distance(currImagePatch,patch);
                if currL2norm<minL2distance
                    minL2distance=currL2norm;
                    returnedPatch=currImagePatch;
                end
            end
        end
    end
end
end

function l2distance = calculateL2distance(im1,im2)
sum=0;
for i=1:size(im1,1)
    for j=1:size(im1,2)
        if ~(isnan(im1(i,j)) || isnan(im2(i,j)))
            sum=sum+((im1(i,j)-im2(i,j)).^2);
        end
    end
end
l2distance=sum;
end