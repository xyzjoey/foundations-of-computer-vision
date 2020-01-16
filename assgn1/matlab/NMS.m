function [img1] = NMS(imgGrad, imgDir)
     
[h, w] = size(imgGrad);
isXOutRange = @(x) x < 1 | x > w;
isYOutRange = @(y) y < 1 | y > h;

img1 = imgGrad;

for y=1:h
    for x=1:w
        %get direction
        theta = imgDir(y, x);
        j = double(theta > -67.5 && theta < 67.5);
        i = round(min(max(tand(theta), -1), 1));

        %suppress
        if (~isXOutRange(x+j) && ~isYOutRange(y+i) && imgGrad(y+i, x+j) >= imgGrad(y, x)) ...
                || (~isXOutRange(x-j) && ~isYOutRange(y-i) && imgGrad(y-i, x-j) >= imgGrad(y, x))
            img1(y, x) = 0;
        end
    end
end

end