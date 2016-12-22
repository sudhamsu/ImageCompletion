function [ patch_out, matte_out ] = createComposite( tp, sp, matte_tp, matte_sp, scales )
%CREATECOMPOSITE Summary of this function goes here
%   Detailed explanation goes here

    tp_pyr = getLaplacianPyramid(tp, scales);
    sp_pyr = getLaplacianPyramid(sp, scales);
    
    ones_pyr = getLaplacianPyramid(ones(size(tp,1),size(tp,2)), scales);
    
    matte_tp_pyr = cell(1,scales);
    one_minus_matte_tp_pyr = cell(1,scales);
    matte_sp_pyr = cell(1,scales);
    matte_tp_pyr{1} = matte_tp;
    one_minus_matte_tp_pyr{1} = 1 - matte_tp;
    matte_sp_pyr{1} = matte_sp;
    for scale = 2:scales
        matte_tp_pyr{scale} = impyramid(matte_tp_pyr{scale-1},'reduce');
        one_minus_matte_tp_pyr{scale} = impyramid(one_minus_matte_tp_pyr{scale-1},'reduce');
        matte_sp_pyr{scale} = impyramid(matte_sp_pyr{scale-1},'reduce');
    end

    % for each scale:
    % L(p_out) = L(tp)G(matte_tp) + L(sp)G(matte_sp)G(1-matte_tp)
    p_out = cell(1,scales);
    m_out = cell(1,scales);
    for scale = 1:scales
        term1 = tp_pyr{scale}.*repmat(matte_tp_pyr{scale},1,1,3);
        term2 = sp_pyr{scale}.*repmat(matte_sp_pyr{scale},1,1,3).*repmat(one_minus_matte_tp_pyr{scale},1,1,3);
        p_out{scale} = term1 + term2;
        m_out{scale} = ones_pyr{scale}.*matte_tp_pyr{scale} + ...
                ones_pyr{scale}.*matte_sp_pyr{scale}.*one_minus_matte_tp_pyr{scale};
    end

    patch_out = reconstructFromLaplacianPyramid(p_out);
    matte_out = reconstructFromLaplacianPyramid(m_out);
end

