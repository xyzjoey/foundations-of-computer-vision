% A custom feature matching script that DOES NOT rely on the computer
% vision package.
% Given binary features F1 and F2, it computes the max match in F2 for
% every point in F1. The threshold parameter will suppress bad matches.
% Increase the threshold to get more matches.
%

function indexPairs = customMatchFeatures(F1, F2, threshold)

if nargin < 3
  threshold = 30;
end

F1 = logical(F1);
F2 = logical(F2);

n = size(F1, 1);
indexPairs = zeros(n, 2);
mismatchs = zeros(n, size(F2, 1));

indexPairs(:,1) = linspace(1, n, n);
for i = 1:n
    mismatchs(i, :) = sum(xor(F1(i,:), F2), 2).';
end

[mins, inds] = min(mismatchs, [], 2);
indexPairs(:, 2) = inds;

indexPairs(mins>threshold,:) = [];