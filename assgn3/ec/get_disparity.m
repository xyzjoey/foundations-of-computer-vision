function dispM = get_disparity(im1, im2, maxDisp, windowSize)
% GET_DISPARITY creates a disparity map from a pair of rectified images im1 and
%   im2, given the maximum disparity MAXDISP and the window size WINDOWSIZE.

[h, w] = size(im1);
winSizeHalf = (windowSize-1)/2;

% padding
im1padded = zeros(h + windowSize - 1, w + windowSize - 1);
im2padded = zeros(h + windowSize - 1, w + windowSize - 1);
im1padded(1+winSizeHalf:h+winSizeHalf, 1+winSizeHalf:w+winSizeHalf) = im1;
im2padded(1+winSizeHalf:h+winSizeHalf, 1+winSizeHalf:w+winSizeHalf) = im2;

dispM = zeros(h, w);
distM = Inf * ones(h, w);

for y=1:h
    
    disp(y);
    
    for x1=1:w

        for d=0:maxDisp
            x2=x1-d;
            if x2 <= 0 || x2 > w continue; end
            
            window1 = im1padded(y:y+windowSize-1, x1:x1+windowSize-1);
            window2 = im2padded(y:y+windowSize-1, x2:x2+windowSize-1);
            
            dist = sum(sum((window1-window2).^2));
            if dist <= distM(y, x1)
                distM(y, x1) = dist;
                dispM(y, x1) = d;
            end
        end
        
    end
end

end