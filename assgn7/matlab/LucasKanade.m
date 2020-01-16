function [u,v] = LucasKanade(It, It1, rect)

iter = 100;
tolmin = 0.01; % tolerance
tolmax = 50;

It = double(It);
It1 = double(It1);

p = [0 0]'; % translation only

[x1, y1, x2, y2, ~, ~] = getRectInfo(rect);
Tw = numel(x1:x2);
Th = numel(y1:y2);

T2D = imcrop(It, x1:x2, y1:y2);
[Ix2D, Iy2D] = gradient(T2D);
weight2D = gaussian([Th Tw], 1.5);

T = T2D(:); %1D
Ix = Ix2D(:); %1D
Iy = Iy2D(:); %1D
A = [Ix Iy];
W = weight2D(:);
H = A' * (A .* repmat(W, 1, 2));

for i = 1:iter
    Iwarp2D = imcrop(It1, x1+p(1):x2+p(1), y1+p(2):y2+p(2));    
    Iwarp = Iwarp2D(:); %1D

    b = (T - Iwarp) .* W;

    pDelta = H\(A' * b);
    p = p + pDelta;
    
    if norm(pDelta) < tolmin
        break
    end
end

p(isnan(p)) = 0;
[u, v] = split(p);

if norm(p) > tolmax
    [u, v] = split([0 0]);
end

end