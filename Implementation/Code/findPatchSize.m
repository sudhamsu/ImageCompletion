function patchSize = findPatchSize(im, x, y, inv_matte)
radii = zeros(3, 1);
radii(1) = 4;
radii(2) = 7;
radii(3) = 10;
% radii(4) = 13;
% radii(5) = 19;
patchParameters = zeros(size(radii,1),1);

averageGradient=Inf;
notBoundary = false;
for i=1:size(radii,1)
    % checking for boundary pixels
    if (x-radii(i)>=1 && x+radii(i)<=size(im,1) && y-radii(i)>=1 && y+radii(i)<=size(im,2))
        currentPatch = abs(im(x-radii(i):x+radii(i), y-radii(i):y+radii(i),5:8));
        currInvMatte = inv_matte(x-radii(i):x+radii(i), y-radii(i):y+radii(i));
    else
        continue;
    end
    confidentCurrPatch=currentPatch(repmat(currInvMatte>0.95,1,1,4));
    if mean(confidentCurrPatch(:)) < (1+(0.01*(4.5+(1/sqrt(averageGradient)))))*averageGradient 
        averageGradient = mean(confidentCurrPatch);
        maxPatchIndex = i;
        notBoundary=true;
    end
end
if ~notBoundary %if boundary pixel, return minimum patch size
    [~,maxPatchIndex]=min(patchParameters);
end
patchSize = radii(maxPatchIndex).*2+1;
