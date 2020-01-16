function [u,v] = LucasKanade_Pyramid(It, It1, rect)

scales = [0.5 1];
iters = [50 50];
tolmin = 0.01; % tolerance
tolmax = 50;

It = double(It);
It1 = double(It1);

p = [0 0]'; % translation only

[x1, y1, x2, y2, ~, ~] = getRectInfo(rect);
T2D = imcrop(It, x1:x2, y1:y2);
[Ix2D, Iy2D] = gradient(T2D);

for s = 1:numel(scales)

    scale = scales(s);
    
    [x1, y1, x2, y2, Tw, Th] = getRectInfo(scaleRectAboutOrigin(rect, scale));
    Tw = numel(x1:x2);
    Th = numel(y1:y2);

    I = imresize(It1, scale);
    T = imresize(T2D, [Th Tw]);
    Ix = imresize(Ix2D, [Th Tw]);
    Iy = imresize(Iy2D, [Th Tw]);
    T = T(:); %1D
    Ix = Ix(:); %1D
    Iy = Iy(:); %1D
        
    weight2D = gaussian([Th Tw], 1.5);
    brightness = mean2(T);
    
    A = [Ix Iy];
    W = weight2D(:);
    H = A' * (A .* repmat(W, 1, 2));
    
    for i = 1:iters(s)
%         fprintf('s=%d\ti=%d\n', s, i);%%
        
        Iwarp2D = imcrop(I, x1+p(1):x2+p(1), y1+p(2):y2+p(2));    
        Iwarp = Iwarp2D(:); %1D
        Iwarp = adjustBrightness(Iwarp, brightness);

        b = (T - Iwarp) .* W;

        pDelta = H\(A' * b);
        p = p + pDelta;
        
        if norm(pDelta) < tolmin * scale
            break
        end
    end

    % unscale
    if s ~= numel(scales)
        p = p * (scales(s+1)/scales(s));
    end
end

p(isnan(p)) = 0;
[u, v] = split(p);

if norm(p) > tolmax
    [u, v] = split([0 0]);
end

end

function imgAdjusted = adjustBrightness(img, targetBrightness)
imgAdjusted = img + (mean2(img) - targetBrightness);
end

function rectScaled = scaleRectAboutOrigin(rect, scale)
rectScaled = scale * rect;
end