function P = estimate_pose(x, X)
% ESTIMATE_POSE computes the pose matrix (camera matrix) P given 2D and 3D
% points.
%   Args:
%       x: 2D points with shape [2, N]
%       X: 3D points with shape [3, N]

N = size(x, 2);
MIN_N = 4;
ITER = 100;
THRESHOLD = 20; %%%

xT = x.';
XT = X.';
xHomo = [xT ones(N, 1)].';
XHomo = [XT ones(N, 1)].';

inlierIndsBest = [];

% RANSAC
for i=1:ITER
    randInds = randperm(N, MIN_N);
    P = computeP(xT(randInds, :), XT(randInds, :));
    
    xProj = P * XHomo;
    xProj = xProj(1:2,:)./repmat(xProj(3,:), 2, 1);
    errors = sqrt(sum((xProj-x).^2)).';
    
    inlierInds = find(errors <= THRESHOLD);
    
    if length(inlierInds) > length(inlierIndsBest)
        inlierIndsBest = inlierInds;
    end
end

P = computeP(xT(inlierIndsBest, :), XT(inlierIndsBest, :));

end

function P = computeP(xT, XT)

N = size(xT, 1);

[xT, T1] = normalize2d(xT);
[XT, T2] = normalize3d(XT);

x1 = xT(:,1);
y1 = xT(:,2);

A1 = [zeros(N, 4) -XT -ones(N, 1) y1.*XT y1.*ones(N, 1)];
A2 = [XT ones(N, 1) zeros(N, 4) -x1.*XT -x1.*ones(N, 1)];
A = [A1; A2];

[~, ~, V] = svd(A);
P = reshape(V(:,end),4,3).';

P = P/P(end);
P = inv(T1) * P * T2;

end

function [xNorm, T] = normalize2d(xT)

N = size(xT, 1);

mu = mean(xT);
sigma = std(xT - repmat(mu, N, 1));

T = [1/sigma(1) 0 mu(1)/sigma(1); 0 1/sigma(2) mu(2)/sigma(2); 0 0 1];
xNorm = [xT ones(N, 1)] * T.';
xNorm = xNorm(:, 1:2);

end

function [xNorm, T] = normalize3d(xT)

N = size(xT, 1);

mu = mean(xT);
sigma = std(xT - repmat(mu, N, 1));

T = [1/sigma(1) 0 0 mu(1)/sigma(1); 0 1/sigma(2) 0 mu(2)/sigma(2); 0 0 1/sigma(3) mu(3)/sigma(3); 0 0 0 1];
xNorm = [xT ones(N, 1)] * T.';
xNorm = xNorm(:, 1:3);

end