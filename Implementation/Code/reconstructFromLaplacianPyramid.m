function [ im_out ] = reconstructFromLaplacianPyramid( pyramid )
%RECONSTRUCTFROMLAPLACIANPYRAMID Summary of this function goes here
%   Detailed explanation goes here

    for scale = length(pyramid)-1:-1:1
        im_exp = impyramid(pyramid{scale+1},'expand');
        if size(im_exp,1) ~= size(pyramid{scale},1) || size(im_exp,2) ~= size(pyramid{scale},2)
            im_exp = imresize(im_exp, [size(pyramid{scale},1),size(pyramid{scale},2)]);
        end
        pyramid{scale} = pyramid{scale} + im_exp;
    end
    im_out = pyramid{1};

end

