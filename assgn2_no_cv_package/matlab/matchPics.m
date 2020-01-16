function [ locs1, locs2] = matchPics( I1, I2 )
%MATCHPICS Extract features, obtain their descriptors, and match them!
THRESHOLD = 50;

%% Convert images to grayscale, if necessary
if ndims(I1) == 3 I1 = (rgb2gray(I1)); end
if ndims(I2) == 3 I2 = (rgb2gray(I2)); end

%% Detect features in both images
x1 = fast_corner_detect_9(I1, THRESHOLD);
x2 = fast_corner_detect_9(I2, THRESHOLD);

%% Obtain descriptors for the computed feature locations
[desc1, x1] = computeBrief(I1, x1);
[desc2, x2] = computeBrief(I2, x2);

%% Match features using the descriptors
indPairs = customMatchFeatures(desc1, desc2);
locs1 = x1(indPairs(:, 1), :);
locs2 = x2(indPairs(:, 2), :);

end

