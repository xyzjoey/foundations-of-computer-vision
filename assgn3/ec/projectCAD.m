clc
clear all

%%
load('../data/PnP.mat', 'X', 'cad', 'image', 'x');

%%
P = estimate_pose(x, X);
[K, R, t] = estimate_params(P);

N = size(X, 2);

% project points
xProj = P*[X; ones(1, N)];
xProj = xProj(1:2,:)./repmat(xProj(3,:), 2, 1);

% plot
figure,
imshow(image,[]); hold on
plot(x(1,:), x(2,:), '.g');
plot(xProj(1,:), xProj(2,:), 'ok', 'MarkerSize', 10);
hold off

%%
% rotate mesh
verticesRotated = cad.vertices * R.';

figure,
trimesh(cad.faces, verticesRotated(:,1), verticesRotated(:,2), verticesRotated(:,3), 'EdgeColor', 'r');
axis equal
xlabel('x')
ylabel('y')
zlabel('z')

%%
N = size(cad.vertices, 1);
verticesProjected = P * [cad.vertices ones(N, 1)].';
verticesProjected = verticesProjected./repmat(verticesProjected(3,:), 3, 1);
verticesProjected = verticesProjected.';

figure,
imshow(image,[]); hold on
patch('Faces', cad.faces, 'Vertices', verticesProjected, 'EdgeColor', 'none', 'FaceColor', 'red', 'FaceAlpha', 0.5);
hold off


