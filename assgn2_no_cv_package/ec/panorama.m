% Q4.3x
clc;
clear all;
close all;

%%
IMG1_PATH = 'pano_1.jpg';
IMG2_PATH = 'pano_2.jpg';
SCALE = 0.1;

img1 = imread(IMG1_PATH);
img2 = imread(IMG2_PATH);

%% compute H
S = [SCALE 0 0; 0 SCALE 0; 0 0 1];

disp('matching points...');
[locs1, locs2] = matchPics(imresize(img1, SCALE), imresize(img2, SCALE));
disp('computing H...');
[H, ~] = computeH_ransac(locs1, locs2);
H = inv(S)*H*S;

%% prepare warpping
disp('warpping...');

tform1 = maketform( 'projective', eye(3));
tform2 = maketform( 'projective', H');

xData1 = [1 size(img1, 2)];
yData1 = [1 size(img1, 1)];
[~, xData2, yData2] = imtransform(img2, tform2);
xMin = min(xData1(1), xData2(1));
xMax = max(xData1(2), xData2(2));
yMin = min(yData1(1), yData2(1));
yMax = max(yData1(2), yData2(2));

%% warp
img1Warp = imtransform(img1, tform1, 'bilinear', 'XData', [xMin xMax], 'YData', [yMin yMax]);
img2Warp = imtransform(img2, tform2, 'bilinear', 'XData', [xMin xMax], 'YData', [yMin yMax]);

mask1 = imtransform(ones(size(img1)), tform1, 'bilinear', 'XData', [xMin xMax], 'YData', [yMin yMax]);
mask2 = imtransform(ones(size(img2)), tform2, 'bilinear', 'XData', [xMin xMax], 'YData', [yMin yMax]);
maskAnd = and(mask1, mask2);
mask1 = mask1 - 0.5*maskAnd;
mask2 = mask2 - 0.5*maskAnd;

result = mask1.*mat2gray(img1Warp) + mask2.*mat2gray(img2Warp);
imshow(result);

disp('done');