function F = eightpoint(pts1, pts2, M)
% eightpoint:
%   pts1 - Nx2 matrix of (x,y) coordinates
%   pts2 - Nx2 matrix of (x,y) coordinates
%   M    - max (imwidth, imheight)

% Q2.1 - Todo:
%     Implement the eightpoint algorithm
%     Generate a matrix F from correspondence '../data/some_corresp.mat'

F = computeF(pts1, pts2);
F = refineF(F, pts1, pts2);

end

function F = computeF(pts1, pts2)

N = size(pts1, 1);

% normalize
[pts1Norm, T1] = normalize2d(pts1);
[pts2Norm, T2] = normalize2d(pts2);

x1 = pts1Norm(:, 1);
y1 = pts1Norm(:, 2);
x2 = pts2Norm(:, 1);
y2 = pts2Norm(:, 2);

A = [x1.*x2 y1.*x2 x2 x1.*y2 y1.*y2 y2 x1 y1 ones(N, 1)];

[~, ~, V] = svd(A);
F = reshape(V(:,9),3,3).';

[U, D, V] = svd(F);
D(3,3) = 0;
F = U * D * V.';

% un-normalize
F = T2.' * F * T1;

end

function [xNorm, T] = normalize2d(x)

N = size(x, 1);

mu = mean(x);
sigma = std(x - repmat(mu, N, 1));

T = [1/sigma(1) 0 mu(1)/sigma(1); 0 1/sigma(2) mu(2)/sigma(2); 0 0 1];
xNorm = [x ones(N, 1)] * T.';
xNorm = xNorm(:, 1:2);

end