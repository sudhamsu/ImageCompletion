function [ pyramid ] = getLaplacianPyramid( im, scales )
%GETLAPLACIANPYRAMID Summary of this function goes here
%   Detailed explanation goes here

    pyramid = cell(1,scales);
    pyramid{1} = im;
    for scale = 1:scales-1
        pyramid{scale+1} = impyramid(pyramid{scale},'reduce');
        im_exp = impyramid(pyramid{scale+1},'expand');
        if size(im_exp,1) ~= size(pyramid{scale},1) || size(im_exp,2) ~= size(pyramid{scale},2)
            im_exp = imresize(im_exp, [size(pyramid{scale},1),size(pyramid{scale},2)]);
        end
        pyramid{scale} = pyramid{scale} - im_exp;
    end
    
end

