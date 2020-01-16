function [ locs1, locs2] = matchFeatures_ec( x1, x2, F1, F2, threshold )
%% Match features using the descriptors

if nargin < 5
  threshold = 30;
end

F1 = logical(F1);
F2 = logical(F2);

n = size(F1, 1);
indPairs = zeros(n, 2);
mismatchs = zeros(n, size(F2, 1));

indPairs(:,1) = linspace(1, n, n);

for i = 1:n
    mismatchs(i, :) = sum(xor(F1(i,:), F2), 2).';
end

[mins, inds] = min(mismatchs, [], 2);
indPairs(:, 2) = inds;
indPairs(mins>threshold,:) = [];

locs1 = x1(indPairs(:, 1), :);
locs2 = x2(indPairs(:, 2), :);

end

