function [H2to1] = computeH_norm(x1, x2)

N = size(x1, 1);

%% Compute centroids of the points
centroid1 = mean(x1);
centroid2 = mean(x2);

%% Shift the origin of the points to the centroid
x1norm = x1 - repmat(centroid1, N, 1);
x2norm = x2 - repmat(centroid2, N, 1);

%% Normalize the points so that the average distance from the origin is equal to sqrt(2).
s1 = sqrt(2)/mean(eucliDist(x1norm));
s2 = sqrt(2)/mean(eucliDist(x2norm));

x1norm = s1 * x1norm;
x2norm = s2 * x2norm;

%% similarity transform 1
tx = -s1*centroid1(1);
ty = -s1*centroid1(2);
T1 = [s1 0 tx; 0 s1 ty; 0 0 1];

%% similarity transform 2
tx = -s2*centroid2(1);
ty = -s2*centroid2(2);
T2 = [s2 0 tx; 0 s2 ty; 0 0 1];

%% Compute Homography
Hnorm = computeH(x1norm, x2norm);

%% Denormalization
H2to1 = inv(T1)*Hnorm*T2;
