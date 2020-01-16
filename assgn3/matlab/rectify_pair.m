function [M1, M2, K1n, K2n, R1n, R2n, t1n, t2n] = ...
                        rectify_pair(K1, K2, R1, R2, t1, t2)
% RECTIFY_PAIR takes left and right camera paramters (K, R, T) and returns left
%   and right rectification matrices (M1, M2) and updated camera parameters. You
%   can test your function using the provided script q4rectify.m

% center
c1 = getCenter(K1, R1, t1);
c2 = getCenter(K2, R2, t2);

% rotation
R1n = getRotation(c1, c2, R1);
R2n = R1n;

% K
K1n = K2;
K2n = K2;

% translation
t1n = -R1n*c1;
t2n = -R2n*c2;

% M
M1 = (K1n*R1n) * inv(K1*R1);
M2 = (K2n*R2n) * inv(K2*R2);

end

function c = getCenter(K, R, t) % 3x1
c = -inv(K*R) * (K*t);
end

function Rn = getRotation(c1, c2, R)

r1 = (c1 - c2)/norm(c1 - c2);
r2 = cross(R(3,:).', r1);
r3 = cross(r2, r1);
Rn = [r1.'; r2.'; r3.'];

end