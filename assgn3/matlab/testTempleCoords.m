% A test script using templeCoords.mat
%
% Write your code here
%
%%
clc
clear all

%%
% Load
I1 = imread('../data/im1.png');
I2 = imread('../data/im2.png');
load('../data/someCorresp.mat', 'pts1', 'pts2', 'M');
load('../data/intrinsics.mat', 'K1', 'K2');
% known correspondence set
pts1Corres1 = pts1;
pts2Corres1 = pts2;
load('../data/templeCoords.mat', 'pts1')
% unknown correspondences set
pts1Corres2 = pts1;

% compute F and E
F = eightpoint(pts1Corres1, pts2Corres1, M);
E = essentialMatrix(F, K1, K2);
% displayEpipolarF(I1, I2, F);
% epipolarMatchGUI(I1, I2, F);

% find second set of correspondences
disp('find correspondences..')
pts2Corres2 = epipolarCorrespondence(I1, I2, F, pts1Corres2);

% % combine correspondence set
% pts1 = [pts1Corres1; pts1Corres2];
% pts2 = [pts2Corres1; pts2Corres2];
pts1 = pts1Corres2;
pts2 = pts2Corres2;

% comput camera matrix
P1 = K1 * [eye(3) zeros(3, 1)];
P2ext = camera2(E); % 4 candidates
P2ext = P2ext(:,:,3); % use the 3rd extrinsic matrix
P2 = K2 * P2ext;

% triangulation
pts3d = triangulate(P1, pts1, P2, pts2);

% plot
figure,
plot3(pts3d(:,1), pts3d(:,2), pts3d(:,3), '.');
axis equal
xlabel('x')
ylabel('y')
zlabel('z')
% for EL = -90:2:90
%   view(270, EL);
%   pause(0.1);
% end

% re-projection error
pts1Reproject = project(pts3d, P1);
pts2Reproject = project(pts3d, P2);
reprojError1 = mean(sqrt(sum((pts1 - pts1Reproject).^2, 2)));
reprojError2 = mean(sqrt(sum((pts2 - pts2Reproject).^2, 2)));

fprintf('re-projection error to image %d: %d\n', 1, reprojError1)
fprintf('re-projection error to image %d: %d\n', 2, reprojError2)

% extrinsic parameters to R and t
R1 = eye(3);
t1 = zeros(3, 1);
R2 = P2ext(:,1:3);
t2 = P2ext(:,4);

%%
% save extrinsic parameters for dense reconstruction
save('../data/extrinsics.mat', 'R1', 't1', 'R2', 't2');

%%
function ptsProj = project(pts, P)
N = size(pts, 1);
ptsProj = [pts ones(N,1)] * P';
ptsProj = ptsProj(:,1:2) ./ ptsProj(:,3);
end
