% Credit to https://stackoverflow.com/questions/22733985/draw-matched-points-between-two-images-in-matlab

function customShowMatchedFeatures(im1, im2, points1, points2)

% Convert gray images to RGB format
if ndims(im1) == 2
    im1 = im1(:,:,[1 1 1]);
end

if ndims(im2) == 2
    im2 = im2(:,:,[1 1 1]);
end

[rows1,cols1,~] = size(im1);
[rows2,cols2,~] = size(im2);

%// Create blank image
stackedImage = zeros(max([rows1,rows2]), cols1+cols2, 3);
stackedImage = cast(stackedImage, class(im1)); %// Make sure we cast output
%// Place two images side by side
stackedImage(1:rows1,1:cols1,:) = im1;
stackedImage(1:rows2,cols1+1:cols1+cols2,:) = im2;

%// Code from before
imshow(stackedImage);
width = size(im1, 2);
hold on;
numPoints = size(points1, 1); % points2 must have same # of points
% Note, we must offset by the width of the image
for i = 1 : numPoints
    plot(points1(i, 1), points1(i, 2), 'y+', points2(i, 1) + width, ...
         points2(i, 2), 'y+');
    line([points1(i, 1) points2(i, 1) + width], [points1(i, 2) points2(i, 2)], ...
         'Color', 'yellow');
end
hold off;