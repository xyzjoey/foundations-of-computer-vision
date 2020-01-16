% Your solution to Q2.1.5 goes here!
close all
%% Read the image and convert to grayscale, if necessary
I1=imread('../data/cv_cover.jpg');
if ndims(I1) == 3
    I1 = rgb2gray(I1);
end
%% Compute the features and descriptors
P1 = fast_corner_detect_9(I1, 50);
[D1, L1] = computeBrief(I1, P1);

allNumMatches = ones(36, 2);
for i = 0:36
    disp(i*10);
    %% Rotate image
    I2 = imrotate(I1, i*10);
    %% Compute features and descriptors
    P2 = fast_corner_detect_9(I2, 50);
    [D2, L2] = computeBrief(I2, P2);

    %% Match features
    indexPairs = customMatchFeatures(D1, D2);
    locs1 = L1(indexPairs(:, 1), :);
    locs2 = L2(indexPairs(:, 2), :);

    %% Update histogram
    numMatches = size(indexPairs, 1);
    allNumMatches(i+1, 1) = i*10;
    allNumMatches(i+1, 2) = numMatches;
    
    if i == 0 || i == 1 || i == 2
        figure
        customShowMatchedFeatures(I1,I2,locs1,locs2);
    end
end

%% Display histogram
%histogram(allNumMatches(:, 2));
figure
plot(allNumMatches(:,1), allNumMatches(:,2));
xlabel('Degree') 
ylabel('Number of matched points') 

