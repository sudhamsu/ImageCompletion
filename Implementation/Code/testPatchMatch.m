im1 = im2double(imread('C:\Users\Sudhamsu\Google Drive\Grad School\Sem 1 - 2016 Fall\CS670 - Computer Vision\Project\Papers\PatchMatch-master\lena.bmp'));
im2 = im2double(imread('C:\Users\Sudhamsu\Google Drive\Grad School\Sem 1 - 2016 Fall\CS670 - Computer Vision\Project\Papers\PatchMatch-master\barbara.bmp'));
figure; imshow(im1);
figure; imshow(im2);

ps  = 11;
hps = floor(ps/2);

tic;
NNF = getNNF(im1, im2, ps);
toc;

new_im1 = zeros(size(im1));
for i = 1+hps:ps:size(im1,1)-hps
    for j = 1+hps:ps:size(im1,2)-hps
        s_patch = im2(NNF(i,j,1)-hps:NNF(i,j,1)+hps,NNF(i,j,2)-hps:NNF(i,j,2)+hps,:);
        new_im1(i-hps:i+hps,j-hps:j+hps,:) = s_patch;
    end
end

figure; imshow(new_im1);