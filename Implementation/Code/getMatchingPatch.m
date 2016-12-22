function [ target_patch, best_source_patch, best_matte_sp, best_i, best_j, patch_size ] = getMatchingPatch( features, pi, pj, c_map, inv_matte )
%GETMATCHINGPATCH Gets matching patch for target_patch using sequential search in features

    scales = 3; % odd

    patch_size = findPatchSize(features, pi, pj, inv_matte) % odd
    hps = floor(patch_size/2); % half of patch size
    
    search_step_size = ceil(hps/2);
    fine_search_step = 1;
    
    target_patch = features(pi-hps:pi+hps,pj-hps:pj+hps,:);
%     figure; imshow(target_patch(:,:,1:3));
    c_map_t = c_map(pi-hps:pi+hps,pj-hps:pj+hps);
    inv_matte_patch_t = inv_matte(pi-hps:pi+hps,pj-hps:pj+hps,:);
    
    % create feature set and c_map_s_set for 8 orientations
    feature_set = cell(1,8);
    c_map_s_set = cell(1,8);
    matte_sp_set = cell(1,8);
    for orient = 1:8
        feature_set{orient} = features;
        c_map_s_set{orient} = c_map;
        matte_sp_set{orient} = inv_matte;
        switch orient
            case 2
                temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
                for i = 1:size(features,3)
                    temp_feat_arr(:,:,i) = imrotate(feature_set{orient}(:,:,i),90);
                end
                feature_set{orient} = temp_feat_arr;
                c_map_s_set{orient} = imrotate(c_map_s_set{orient},90);
                matte_sp_set{orient} = imrotate(matte_sp_set{orient},90);
            case 3
                temp_feat_arr = zeros(size(feature_set{orient},1),size(feature_set{orient},2),size(features,3));
                for i = 1:size(features,3)
                    temp_feat_arr(:,:,i) = imrotate(feature_set{orient}(:,:,i),180);
                end
                feature_set{orient} = temp_feat_arr;
                c_map_s_set{orient} = imrotate(c_map_s_set{orient},180);
                matte_sp_set{orient} = imrotate(matte_sp_set{orient},180);
            case 4
                temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
                for i = 1:size(features,3)
                    temp_feat_arr(:,:,i) = imrotate(feature_set{orient}(:,:,i),270);
                end
                feature_set{orient} = temp_feat_arr;
                c_map_s_set{orient} = imrotate(c_map_s_set{orient},270);
                matte_sp_set{orient} = imrotate(matte_sp_set{orient},270);
            case 5
                temp_feat_arr = zeros(size(feature_set{orient},1),size(feature_set{orient},2),size(features,3));
                for i = 1:size(features,3)
                    temp_feat_arr(:,:,i) = flip(feature_set{orient}(:,:,i), 1);
                end
                feature_set{orient} = temp_feat_arr;
                c_map_s_set{orient} = flip(c_map_s_set{orient}, 1);
                matte_sp_set{orient} = flip(matte_sp_set{orient}, 1);
            case 6
                temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
                for i = 1:size(features,3)
                    temp_feat_arr(:,:,i) = flip(imrotate(feature_set{orient}(:,:,i),90), 1);
                end
                feature_set{orient} = temp_feat_arr;
                c_map_s_set{orient} = flip(imrotate(c_map_s_set{orient},90), 1);
                matte_sp_set{orient} = flip(imrotate(matte_sp_set{orient},90), 1);
            case 7
                temp_feat_arr = zeros(size(feature_set{orient},1),size(feature_set{orient},2),size(features,3));
                for i = 1:size(features,3)
                    temp_feat_arr(:,:,i) = flip(imrotate(feature_set{orient}(:,:,i),180), 1);
                end
                feature_set{orient} = temp_feat_arr;
                c_map_s_set{orient} = flip(imrotate(c_map_s_set{orient},180), 1);
                matte_sp_set{orient} = flip(imrotate(matte_sp_set{orient},180), 1);
            case 8
                temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
                for i = 1:size(features,3)
                    temp_feat_arr(:,:,i) = flip(imrotate(feature_set{orient}(:,:,i),270), 1);
                end
                feature_set{orient} = temp_feat_arr;
                c_map_s_set{orient} = flip(imrotate(c_map_s_set{orient},270), 1);
                matte_sp_set{orient} = flip(imrotate(matte_sp_set{orient},270), 1);
        end
    end
    
    min_val = Inf; % to track value we are minimizing
    for scale_i = 1:1:scales
        disp(scale_i);
        scale = 1.1^(scale_i-floor(scales/2)+1);
        scaled_patch_size = floor(floor(scale * patch_size) / 2) * 2 + 1; % odd
        hsps = floor(scaled_patch_size/2); % half of scaled_patch_size
        for i = 1:search_step_size:size(features,1)
            if i>=hsps+1 && i<=size(features,1)-hsps
                for j = 1:search_step_size:size(features,2)
                    if j>=hsps+1 && j<=size(features,2)-hsps
                        if abs(i-pi)<=hsps && abs(j-pj)<=hsps, continue; end
                        
                        scaled_c_map_s = c_map(i-hsps:i+hsps,j-hsps:j+hsps);
                        if mean(scaled_c_map_s(:))<0.95, continue; end
                        
                        for orient = 1:1:8
                            [o_i, o_j] = updateCoordinates(i,j,c_map,orient);
                            scaled_source_patch = feature_set{orient}(o_i-hsps:o_i+hsps,o_j-hsps:o_j+hsps,:);
                            scaled_c_map_s = c_map_s_set{orient}(o_i-hsps:o_i+hsps,o_j-hsps:o_j+hsps);
                            scaled_matte_sp = matte_sp_set{orient}(o_i-hsps:o_i+hsps,o_j-hsps:o_j+hsps);
                            source_patch = zeros(size(target_patch));
                            c_map_s = imresize(scaled_c_map_s,[patch_size,patch_size]);
                            matte_sp = imresize(scaled_matte_sp,[patch_size,patch_size]);
                            for c = 1:1:size(features,3)
                                source_patch(:,:,c) = imresize(scaled_source_patch(:,:,c),[patch_size,patch_size]);
                            end

                            source_patch_temp = source_patch;
                            source_patch_temp(:,:,5:8) = source_patch_temp(:,:,5:8) .* repmat(inv_matte_patch_t,1,1,4);
                            dist = sum(abs(source_patch_temp-target_patch),3); % L1 dist along dim 3

                            val = sum(sum(dist.*c_map_s.*c_map_t + (c_map_t-c_map_s).*c_map_t));

                            if val < min_val
                                min_val = val;
                                best_source_patch = source_patch(:,:,1:3);
                                best_matte_sp = matte_sp;
                                best_i = i;
                                best_j = j;
                            end
                        end
                    end
                end
            end
        end
        
        for i = best_i-hsps:fine_search_step:best_i+hsps
            if i>=hsps+1 && i<=size(features,1)-hsps
                for j = best_j-hsps:fine_search_step:best_j+hsps
                    if j>=hsps+1 && j<=size(features,2)-hsps
                        if abs(i-pi)<=hsps && abs(j-pj)<=hsps, continue; end
                        
                        scaled_c_map_s = c_map(i-hsps:i+hsps,j-hsps:j+hsps);
                        if mean(scaled_c_map_s(:))<0.99, continue; end
                        
                        for orient = 1:1:8
                            [o_i, o_j] = updateCoordinates(i,j,c_map,orient);
                            scaled_source_patch = feature_set{orient}(o_i-hsps:o_i+hsps,o_j-hsps:o_j+hsps,:);
                            scaled_c_map_s = c_map_s_set{orient}(o_i-hsps:o_i+hsps,o_j-hsps:o_j+hsps);
                            scaled_matte_sp = matte_sp_set{orient}(o_i-hsps:o_i+hsps,o_j-hsps:o_j+hsps);
                            source_patch = zeros(size(target_patch));
                            c_map_s = imresize(scaled_c_map_s,[patch_size,patch_size]);
                            matte_sp = imresize(scaled_matte_sp,[patch_size,patch_size]);
                            for c = 1:1:size(features,3)
                                source_patch(:,:,c) = imresize(scaled_source_patch(:,:,c),[patch_size,patch_size]);
                            end

                            source_patch_temp = source_patch;
                            source_patch_temp(:,:,5:8) = source_patch_temp(:,:,5:8) .* repmat(inv_matte_patch_t,1,1,4);
                            dist = sum(abs(source_patch_temp-target_patch),3); % L1 dist along dim 3

                            val = sum(sum(dist.*c_map_s.*c_map_t + (c_map_t-c_map_s).*c_map_t));

                            if val < min_val
                                min_val = val;
                                best_source_patch = source_patch(:,:,1:3);
                                best_matte_sp = matte_sp;
                                best_i = i;
                                best_j = j;
                            end
                        end
                    end
                end
            end
        end
    end
    
    target_patch = target_patch(:,:,1:3);
end

