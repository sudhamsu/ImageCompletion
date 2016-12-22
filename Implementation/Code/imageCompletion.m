outermostTic = tic;

%% load image and create inverse matte
im = im2double(imread('../Data/valley_small.jpg'));
imname = 'valley_small';
inv_matte = ones(size(im,1),size(im,2));
inv_matte(101:130,114:143) = 0;
% inv_matte(61:90,171:200) = 0;
% inv_matte(16:45,271:300) = 0;

% im = im2double(imread('../Data/textoverlay.png'));
% imname = 'textoverlay';
% inv_matte = ones(size(im,1),size(im,2));
% inv_matte(rgb2gray(im)==1) = 0;

% im = im2double(imread('../Data/einstein.png'));
% imname = 'einstein';
% inv_matte = ones(size(im,1),size(im,2));
% inv_matte(rgb2gray(im)==1) = 0;

% im = im2double(imread('../Data/elephant.jpg'));
% imname = 'elephant';
% inv_matte = floor(im2double(rgb2gray(imread('../Data/elephant_inv_matte.jpg')))+0.5);

% im = im2double(imread('../Data/boat_small.jpg'));
% imname = 'boat_small';
% inv_matte = floor(im2double(rgb2gray(imread('../Data/boat_small_inv_matte.jpg')))+0.5);

% im = im2double(imread('../Data/birds1.jpg'));
% imname = 'birds1';
% inv_matte = floor(im2double(rgb2gray(imread('../Data/birds1_inv_matte.jpg')))+0.5);

% im = im2double(imread('../Data/birds2.jpg'));
% imname = 'birds2';
% inv_matte = floor(im2double(rgb2gray(imread('../Data/birds2_inv_matte.jpg')))+0.5);

% im = im2double(imread('../Data/birds3.jpg'));
% imname = 'birds3';
% inv_matte = floor(im2double(rgb2gray(imread('../Data/birds3_inv_matte.jpg')))+0.5);

% im = im2double(imread('../Data/starrynight.jpg'));
% imname = 'starrynight';
% inv_matte = floor(im2double(rgb2gray(imread('../Data/starrynight_inv_matte2.jpg')))+0.5);

% im = im2double(imread('../Data/beach.jpg'));
% imname = 'beach';
% inv_matte = floor(im2double(rgb2gray(imread('../Data/beach_inv_matte.jpg')))+0.5);

Hx1 = find(sum(1-inv_matte,2)~=0,1);
Hy1 = find(sum(1-inv_matte,1)~=0,1);
Hx2 = find(sum(1-inv_matte,2)~=0,1,'last');
Hy2 = find(sum(1-inv_matte,1)~=0,1,'last');

%% fast approximation
imwrite(im.*repmat(inv_matte,1,1,3), strcat('../Results/',imname,'_hole.jpg'));
figure; imshow(im.*repmat(inv_matte,1,1,3));
approx_im = fastApprox(im, inv_matte);
% figure; imshow(approx_im);

%% build confidence map
c_map = getConfidenceMap(inv_matte);

% only for display
% c_map_disp = repmat(c_map,1,1,3);
% for c_map_i = 1:size(c_map_disp,1)
%     for c_map_j = 1:size(c_map_disp,2)
%         if c_map(c_map_i,c_map_j) == 1
%             c_map_disp(c_map_i,c_map_j,:) = [0,0.8,0.2];
%         elseif c_map(c_map_i,c_map_j) <= 0.01
%             c_map_disp(c_map_i,c_map_j,:) = [1,0,0];
%         else
%             c_map_disp(c_map_i,c_map_j,:) = [c_map(c_map_i,c_map_j),c_map(c_map_i,c_map_j),c_map(c_map_i,c_map_j)];
%         end
%     end
% end
% figure; imshow(c_map_disp);

%% obtain level set
level_set = getLevelSet(c_map);
% figure; imshow(level_set);

disp(mean(c_map(:)));

%% initialize nnf
NNF_set = cell(1,8);
for i = 1:8
    NNF_set{i} = 0;
end

iter = 0;

%% iterations
while mean(c_map(:)) < 0.9999 || min(inv_matte(:)) < 0.5
    iter = iter + 1;
    
    %% search for matching patch
    % create features to use to calculate distance
    features = zeros(size(approx_im,1),size(approx_im,2),8);
    features(:,:,1:3) = approx_im;
    features(:,:,4) = rgb2gray(approx_im);
    features(:,:,5) = conv2(features(:,:,4),[-0.5,0,0.5],'same').*inv_matte;
    features(:,:,6) = conv2(features(:,:,4),[-0.5,0,0.5]','same').*inv_matte;
    features(:,:,7) = conv2(features(:,:,4),[-0.5,0,0;0,0,0;0,0,0.5],'same').*inv_matte;
    features(:,:,8) = conv2(features(:,:,4),[0,0,-0.5;0,0,0;0.5,0,0]','same').*inv_matte;

    % find indices of maxima in level_set
    [M, max_i] = max(level_set);
    [M, max_j] = max(M);
    max_i = max_i(max_j);
    
    patch_size = findPatchSize(features, max_i, max_j, inv_matte); % odd
    disp(patch_size);
%     hps = floor(patch_size/2); % half of patch size
    hps = patch_size; % trying something -- increases border
    unknown_bbox = [Hx1-hps,Hy1-hps;Hx2+hps,Hy2+hps]; % [x1,y1;x2,y2] comes from the hole we punch manually
    if unknown_bbox(1,1) < 1, unknown_bbox(1,1) = 1; end
    if unknown_bbox(1,2) < 1, unknown_bbox(1,2) = 1; end
    if unknown_bbox(2,1) > size(features,1), unknown_bbox(2,1) = size(features,1); end
    if unknown_bbox(2,2) > size(features,2), unknown_bbox(2,2) = size(features,2); end
    
    % get a patch to match at this location
    searchTic = tic;
    [target_patch, source_patch, matte_sp, sp_i, sp_j, NNF_set] = ...
            getMatchingPatchFromNNF(features,unknown_bbox,max_i,max_j,inv_matte,patch_size,NNF_set);
    toc(searchTic);
    
%     % get a patch to match at this location
%     searchTic = tic;
%     [target_patch, source_patch, matte_sp, sp_i, sp_j, patch_size] = ...
%             getMatchingPatch(features,max_i,max_j,c_map,inv_matte);
%     toc(searchTic);

%     figure; imshow(source_patch);

    %% compositing patches
    hps = floor(patch_size/2); % half of patch size
    matte_tp = inv_matte(max_i-hps:max_i+hps,max_j-hps:max_j+hps);
    [composite_patch, matte_patch] = createComposite(target_patch(:,:,1:3), source_patch, matte_tp, matte_sp, 3);
%     figure; imshow(composite_patch);
%     figure; imshow(matte_patch);

    %% insert composite patch
    approx_im = approx_im .* repmat(inv_matte,1,1,3);
    approx_im(max_i-hps:max_i+hps,max_j-hps:max_j+hps,:) = composite_patch;
    inv_matte(max_i-hps:max_i+hps,max_j-hps:max_j+hps) = matte_patch;
    
    %% fast approximation
    imwrite(approx_im.*repmat(inv_matte,1,1,3), strcat('../Results/',imname,'_filling_',int2str(iter),'.jpg'));
    figure; imshow(approx_im.*repmat(inv_matte,1,1,3));
    approx_im = fastApprox(approx_im, inv_matte);
%     figure; imshow(approx_im);

    %% build confidence map
    c_map = getConfidenceMap(inv_matte);
%     figure; imshow(c_map);

    %% obtain level set
    level_set = getLevelSet(c_map);
%     figure; imshow(level_set);
    
    disp(mean(c_map(:)));
    
end

imwrite(approx_im.*repmat(inv_matte,1,1,3), strcat('../Results/',imname,'_filled.jpg'));
figure; imshow(approx_im);

toc(outermostTic);
