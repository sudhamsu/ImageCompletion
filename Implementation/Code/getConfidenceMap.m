function [ map ] = getConfidenceMap( inv_matte )
%GETCONFIDENCEMAP Confidence Map building step in Fragment-based Image Completion

    gsize = 31; % odd
    hg = (gsize-1)/2; % half of gsize
    sigma = 10;
    gauss = fspecial('gaussian', gsize, sigma);

    inv_matte = padarray(inv_matte,[hg hg],0,'both');
    map = ones(size(inv_matte));
    for i = hg+1:size(map,1)-hg
        for j = hg+1:size(map,2)-hg
            if inv_matte(i,j) < 0.99
                map(i,j) = sum(sum(inv_matte(i-hg:i+hg,j-hg:j+hg) .* gauss));
            end
        end
    end

    map = map(1+hg:end-hg,1+hg:end-hg);
end

