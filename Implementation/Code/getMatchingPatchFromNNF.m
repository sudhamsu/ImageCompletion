function [ t_patch, s_patch, sp_inv_matte, sp_i, sp_j, NNF_set ] = ...
    getMatchingPatchFromNNF( features, unknown_bbox, pi, pj, inv_matte, ps, NNF_set )
%GETMATCHINGPATCHFROMNNF Gets a matching patch for given t_patch using NNF

hps = floor(ps/2);

% disp(size(features));
% disp(unknown_bbox);

tp_features = features(unknown_bbox(1,1):unknown_bbox(2,1),unknown_bbox(1,2):unknown_bbox(2,2),:);
tp_inv_matte = floor(inv_matte(pi-hps:pi+hps,pj-hps:pj+hps)+0.05);
inv_matte_expanded_straight = floor(imgaussfilt(inv_matte,6));
t_im_inv_matte_expanded = inv_matte_expanded_straight(unknown_bbox(1,1):unknown_bbox(2,1),unknown_bbox(1,2):unknown_bbox(2,2));

adj_pi = pi - unknown_bbox(1,1) + 1;
adj_pj = pj - unknown_bbox(1,2) + 1;

% disp(unknown_bbox);
% disp(pi);
% disp(pj);
% disp(adj_pi);
% disp(adj_pj);

t_patch = features(pi-hps:pi+hps,pj-hps:pj+hps,1:3);
% figure; imshow(t_patch);


% CREATE SETS FOR ORIENTATIONS
feature_set = cell(1,8);
% c_map_s_set = cell(1,8);
sp_inv_matte_set = cell(1,8);
for orient = 1:8
    feature_set{orient} = features;
%     c_map_s_set{orient} = c_map;
    sp_inv_matte_set{orient} = inv_matte;
    switch orient
        case 2
            temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
            for i = 1:size(features,3)
                temp_feat_arr(:,:,i) = imrotate(feature_set{orient}(:,:,i),90);
            end
            feature_set{orient} = temp_feat_arr;
%             c_map_s_set{orient} = imrotate(c_map_s_set{orient},90);
            sp_inv_matte_set{orient} = imrotate(sp_inv_matte_set{orient},90);
        case 3
            temp_feat_arr = zeros(size(feature_set{orient},1),size(feature_set{orient},2),size(features,3));
            for i = 1:size(features,3)
                temp_feat_arr(:,:,i) = imrotate(feature_set{orient}(:,:,i),180);
            end
            feature_set{orient} = temp_feat_arr;
%             c_map_s_set{orient} = imrotate(c_map_s_set{orient},180);
            sp_inv_matte_set{orient} = imrotate(sp_inv_matte_set{orient},180);
        case 4
            temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
            for i = 1:size(features,3)
                temp_feat_arr(:,:,i) = imrotate(feature_set{orient}(:,:,i),270);
            end
            feature_set{orient} = temp_feat_arr;
%             c_map_s_set{orient} = imrotate(c_map_s_set{orient},270);
            sp_inv_matte_set{orient} = imrotate(sp_inv_matte_set{orient},270);
        case 5
            temp_feat_arr = zeros(size(feature_set{orient},1),size(feature_set{orient},2),size(features,3));
            for i = 1:size(features,3)
                temp_feat_arr(:,:,i) = flip(feature_set{orient}(:,:,i), 1);
            end
            feature_set{orient} = temp_feat_arr;
%             c_map_s_set{orient} = flip(c_map_s_set{orient}, 1);
            sp_inv_matte_set{orient} = flip(sp_inv_matte_set{orient}, 1);
        case 6
            temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
            for i = 1:size(features,3)
                temp_feat_arr(:,:,i) = flip(imrotate(feature_set{orient}(:,:,i),90), 1);
            end
            feature_set{orient} = temp_feat_arr;
%             c_map_s_set{orient} = flip(imrotate(c_map_s_set{orient},90), 1);
            sp_inv_matte_set{orient} = flip(imrotate(sp_inv_matte_set{orient},90), 1);
        case 7
            temp_feat_arr = zeros(size(feature_set{orient},1),size(feature_set{orient},2),size(features,3));
            for i = 1:size(features,3)
                temp_feat_arr(:,:,i) = flip(imrotate(feature_set{orient}(:,:,i),180), 1);
            end
            feature_set{orient} = temp_feat_arr;
%             c_map_s_set{orient} = flip(imrotate(c_map_s_set{orient},180), 1);
            sp_inv_matte_set{orient} = flip(imrotate(sp_inv_matte_set{orient},180), 1);
        case 8
            temp_feat_arr = zeros(size(feature_set{orient},2),size(feature_set{orient},1),size(features,3));
            for i = 1:size(features,3)
                temp_feat_arr(:,:,i) = flip(imrotate(feature_set{orient}(:,:,i),270), 1);
            end
            feature_set{orient} = temp_feat_arr;
%             c_map_s_set{orient} = flip(imrotate(c_map_s_set{orient},270), 1);
            sp_inv_matte_set{orient} = flip(imrotate(sp_inv_matte_set{orient},270), 1);
    end
end

best_offset = Inf;
for orient = 1:8
%     disp(unknown_bbox)
    
    inv_matte_expanded = floor(imgaussfilt(sp_inv_matte_set{orient},6));
    
%     [un_bbox_x1, un_bbox_y1] = updateCoordinates(unknown_bbox(1,1),unknown_bbox(1,2),inv_matte,orient);
%     [un_bbox_x2, un_bbox_y2] = updateCoordinates(unknown_bbox(2,1),unknown_bbox(2,2),inv_matte,orient);
%     un_bbox_orient = [ un_bbox_x1, un_bbox_y1 ; un_bbox_x2, un_bbox_y2 ];
%     
% %     disp(un_bbox_orient)
%     
%     if un_bbox_orient(1,1) > un_bbox_orient(2,1)
%         temp = un_bbox_orient(1,1);
%         un_bbox_orient(1,1) = un_bbox_orient(2,1);
%         un_bbox_orient(2,1) = temp;
%     end
%     if un_bbox_orient(1,2) > un_bbox_orient(2,2)
%         temp = un_bbox_orient(1,2);
%         un_bbox_orient(1,2) = un_bbox_orient(2,2);
%         un_bbox_orient(2,2) = temp;
%     end
%     
% %     disp(un_bbox_orient)
    
    [NNF,offsets] = getNNF(tp_features, feature_set{orient}, ps, inv_matte_expanded, tp_inv_matte, t_im_inv_matte_expanded, NNF_set{orient});
    NNF_set{orient} = NNF;
    % disp(size(NNF));
    
%     disp(adj_pi);
%     disp(adj_pj);
%     disp(size(offsets));
    offset = offsets(adj_pi,adj_pj);
    
    if offset < best_offset
        sp_i = NNF(adj_pi,adj_pj,1);
        sp_j = NNF(adj_pi,adj_pj,2);
        s_patch = feature_set{orient}(sp_i-hps:sp_i+hps,sp_j-hps:sp_j+hps,1:3);
        sp_inv_matte = sp_inv_matte_set{orient}(sp_i-hps:sp_i+hps,sp_j-hps:sp_j+hps);
    end
end

end

