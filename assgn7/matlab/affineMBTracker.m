function [Wout] = affineMBTracker(img, tmp, rect, Win, context)

iter = 30;
tol = 0.0001;

img = double(img);
[x1, y1, x2, y2, w, h] = getRectInfo(rect);

J = context.J;
invH = context.invH;

% weight2D = gaussian(size(tmp), 1.5);
% weight = weight2D(:);

Wout = Win;

for i = 1:iter

    I = imwarp2D(img, Wout, x1:x2, y1:y2, size(tmp));
    T = tmp;
    b = I - T;
    b = b(:);
%     b = b .* weight .* norm(b);
    
    pDelta = invH * J' * b;
    pDelta(isnan(pDelta)) = 0;
    
    Wout = Wout * inv(pToWarp(pDelta));    
    
    if norm(pDelta) < tol
        break
    end
end

end

function W = pToWarp(p)
W = [p(1)+1 p(3)    p(5);
     p(2)   p(4)+1  p(6);
     0      0       1];
end

function imgWarpped = imwarp2D(img, W, xrange, yrange, sizeOut)
img = double(img);

[X2, Y2] = meshgrid(xrange, yrange);
[X1, Y1] = warpMeshgrid(X2, Y2, inv(W));
imgWarpped = interp2(img, X1, Y1);  

imgWarpped = imresize(imgWarpped, sizeOut);
end

function [Xnew, Ynew] = warpMeshgrid(X, Y, W)
[h, w] = size(X);

points = [X(:) Y(:) ones(h*w,1)]';
pointsNew = W * points;

Xnew = reshape(pointsNew(1,:), h, w);
Ynew = reshape(pointsNew(2,:), h, w);
end