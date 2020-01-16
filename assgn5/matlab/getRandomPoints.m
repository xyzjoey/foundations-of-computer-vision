function [points] = getRandomPoints(I, alpha)

[h, w, ~] = size(I);
n = numel(I(:,:,1));

inds = randperm(n, alpha);

[rows, cols] = ind2sub([h w], inds.');
points = [cols rows];

end