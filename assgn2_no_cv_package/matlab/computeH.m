function [ H2to1 ] = computeH( x1, x2 )
%COMPUTEH Computes the homography between two sets of points

n = size(x1, 1);

p1 = x1;
p2 = x2;

x1 = p1(:, 1);
x2 = p2(:, 1);
y1 = p1(:, 2);
y2 = p2(:, 2);

Ax = [-x2 -y2 -ones(n, 1) zeros(n, 3) x2.*x1 y2.*x1 x1];
Ay = [zeros(n, 3) -x2 -y2 -ones(n, 1) x2.*y1 y2.*y1 y1];
A = [Ax; Ay];

if n == 4
    [~, ~, V] = svd(A);
else
    [~, ~, V] = svd(A, 'econ');
end

% [V, ~] = eigs(A.'*A,1,'SM');

H2to1 = reshape(V(:, end), 3, 3).';
H2to1 = H2to1/H2to1(end);

end
