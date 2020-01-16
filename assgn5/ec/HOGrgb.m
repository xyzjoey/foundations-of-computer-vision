function [feature] = HOGrgb(I)

[~, ~, channelNum] = size(I);
if channelNum == 1
    I = repmat(I, [1 1 3]);
end

featureR = HOG(I(:,:,1));
featureG = HOG(I(:,:,2));
featureB = HOG(I(:,:,3));

feature = [featureR featureG featureB];

end