function [ out_im ] = fastApprox( im, inv_matte )
%FASTAPPROX Fast Approximation step in Fragment-based Image Completion
    
    % get matte
    matte = 1 - inv_matte;
    
    % number of levels in pyramid
    L = 3;
    
    % kernel for up/down-scaling
    % values as mentioned in MATLAB's impyramid documentation
    a = 0.375;
    K = [0.25-a/2,0.25,a,0.25,0.25-a/2];

    % fast approximation
    Y = ones(size(im));
    for l = L:-1:1
        ifContinue = true;
        while ifContinue
            Y_prev = Y;
            Y = Y.*repmat(matte,1,1,3) + im.*repmat(inv_matte,1,1,3);
            if l ~= 1
                % l IS > 1
                for i = 2:l
                    Y = impyramid(Y,'reduce');
                end
                for i = 2:l
                    Y = impyramid(Y,'expand');
                end
            else
                % l EQUALS 1
                Y = convn(convn(Y, K, 'same'),K','same');
            end

            % repeated up/down-scaling may lead to change in size(Y) by a
            % pixel or two; resize to make sure size(Y)=size(Y_prev)
            if size(Y,1) ~= size(Y_prev,1) || size(Y,2) ~= size(Y_prev,2)
                Y = imresize(Y, [size(Y_prev,1),size(Y_prev,2)]);
            end
            
            % if Y has pretty much converged to Y_prev, stop iterating
            if sum(sum(sum((Y - Y_prev).^2))) < 1E-8
                ifContinue = false;
            end
        end
    end
    
    % keep known pixels unchanged
    Y = Y.*repmat(matte,1,1,3) + im.*repmat(inv_matte,1,1,3);
    
    % push out Y
    out_im = Y;
end

