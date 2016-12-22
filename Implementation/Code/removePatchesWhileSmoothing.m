function wholeImage = removePatchesWhileSmoothing(im)
    while size(find(isnan(im)),1)~=0
        [X,Y]=find(isnan(im));
        randomNum=randi(size(X,1));
        currX=X(randomNum);
        currY=Y(randomNum);
        isBoundary=false;
        for i=currX-2:currX+2
            for j=currY-2:currY+2
                if ~isnan(im(i,j))
                    isBoundary=true;
                end
            end
        end
        if isBoundary
            currX, currY
            currPatch=im(currX-2:currX+2,currY-2:currY+2);
            closestPatch=findClosestPatch(currPatch,im)
            for i=currX-2:currX+2
                for j=currY-2:currY+2
                    if ~isnan(im(i,j))
                        im(i,j)=(im(i,j)+closestPatch((i-currX+3),(j-currY+3)))./2;
                    else
                        im(i,j)=closestPatch((i-currX+3),(j-currY+3));
                    end
                end
            end
        end
    end
    wholeImage=im;
end