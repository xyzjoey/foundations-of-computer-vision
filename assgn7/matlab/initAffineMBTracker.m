function [affineMBContext] = initAffineMBTracker(img, rect)

img = double(img);

[x1, y1, x2, y2, w, h] = getRectInfo(rect);

T2D = imcrop(img, x1:x2, y1:y2);

[Ix2D, Iy2D] = gradient(T2D);
Ix = Ix2D(:);
Iy = Iy2D(:);

[X, Y] = meshgrid(x1:x2, y1:y2);
X = X(:);
Y = Y(:);

J = [Ix.*X Iy.*X Ix.*Y Iy.*Y Ix Iy];
H = J' * J;
% weight2D = gaussian([h w], 1.5);
% weight = weight2D(:);
% H = J' * (J .* repmat(weight, 1, 6));

affineMBContext.J = J;
affineMBContext.invH = inv(H);
end