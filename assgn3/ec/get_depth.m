function depthM = get_depth(dispM, K1, K2, R1, R2, t1, t2)
% GET_DEPTH creates a depth map from a disparity map (DISPM).

b = norm(getCenter(K1, R1, t1) - getCenter(K2, R2, t2));
f = K1(1,1);

depthM = b * f * dispM.^-1;
depthM(dispM == 0) = 0;

end

function c = getCenter(K, R, t) % 3x1
c = -inv(K*R) * (K*t);
end