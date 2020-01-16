function [u,v] = LucasKanade_Robust(It, It1, rect)

It = double(It);
It1 = double(It1);

iter = 100;
tolmin = 0.01; % tolerance
% tolmax = 50;

p = [0 0]'; % translation only

[x1, y1, Tw, Th] = split(rect);
x2 = x1 + Tw - 1;
y2 = y1 + Th - 1;

T2D = imcrop(It, x1:x2, y1:y2);
[Ix2D, Iy2D] = gradient(T2D);
weight2D = huber([Th Tw]);
% weight2D = gaussian([Th Tw], 1.5);

T = T2D(:); %1D
Ix = Ix2D(:); %1D
Iy = Iy2D(:); %1D
A = [Ix Iy];
W = weight2D(:);
H = A' * (A .* repmat(W, 1, 2));

brightness = mean2(T);

for i = 1:iter
    Iwarp2D = imcrop(It1, (x1:x2)+p(1), (y1:y2)+p(2));    
    Iwarp = Iwarp2D(:); %1D
    Iwarp = adjustBrightness(Iwarp, brightness);

    b = (T - Iwarp) .* W;

    pDelta = H\(A' * b);
    p = p + pDelta;
    
    if norm(pDelta) < tolmin
        break
    end
end

p(isnan(p)) = 0;
[u, v] = split(p);

% if norm(p) > tolmax
%     [u, v] = split([0 0]);
% end

end

function imgAdjusted = adjustBrightness(img, targetBrightness)
imgAdjusted = img + (mean2(img) - targetBrightness);
end

function weight = huber(sze)
% c = 0.1 * min(sze)/2;
c = 5;

X = 0:sze(2)-1;
Y = 0:sze(1)-1;
X = X - (sze(2)-1)/2;
Y = Y - (sze(1)-1)/2;
[X, Y] = meshgrid(X, Y);

D = sqrt(X.^2 + Y.^2);

weight = D;
weight(D <= c) = 1;
weight(D > c) = c./D(D > c);
% weight = weight/sum(sum(weight));
end