function [pts2] = epipolarCorrespondence(im1, im2, F, pts1)
% epipolarCorrespondence:
%   Args:
%       im1:    Image 1
%       im2:    Image 2
%       F:      Fundamental Matrix from im1 to im2
%       pts1:   coordinates of points in image 1
%   Returns:
%       pts2:   coordinates of points in image 2
%

im1 = double(im1);
im2 = double(im2);

windowSize = 5;
N = size(pts1, 1);
% [h1, w1, ~] = size(im1);
[h2, w2, ~] = size(im2);

pts2 = zeros(N, 2);
dist = Inf * ones(N, 1);

% padding
winSizeHalf = floor(windowSize/2);
I1padded = padarray(im1, [winSizeHalf winSizeHalf]);
I2padded = padarray(im2, [winSizeHalf winSizeHalf]);

for i=1:N
  
    l2 = F * [pts1(i,:) 1].'; % epipolar line for ith point
    [X2, Y2] = lineToPts(l2, [h2 w2]); % point candidates
    
    for j = 1:numel(X2)
        pt1 = pts1(i,:);
        pt2 = [X2(j) Y2(j)];
    
        currDist = getDist(pt1, pt2, I1padded, I2padded, windowSize);
        
        if currDist < dist(i)
            dist(i) = currDist;
            pts2(i,:) = pt2;
        end
    end

end
end

% function [e1,e2] = epipoles(E)
% 
% [~, ~, V] = svd(E);
% e1 = V(:, 3);
% e1 = e1 / e1(3);
% 
% [~, ~, V] = svd(E');
% e2 = V(:, 3);
% e2 = e2 / e2(3);
% 
% end

function [X, Y] = lineToPts(line, imgSze)
h = imgSze(1);
w = imgSze(2);

X = 1:w;
Y = round(-(line(1).*X + line(3)) ./ line(2));

invalid = Y < 1 | Y > h;

X(invalid) = [];
Y(invalid) = [];
end

function dist = getDist(p1, p2, I1padded, I2padded, windowSize)

EUCLID = false;

x1 = round(p1(1));
y1 = round(p1(2));
x2 = round(p2(1));
y2 = round(p2(2));

window1 = I1padded(y1:y1+windowSize-1, x1:x1+windowSize-1, :);
window2 = I2padded(y2:y2+windowSize-1, x2:x2+windowSize-1, :);

if EUCLID %Euclidean distance
    dist = sum(sum(sqrt(sum((window1-window2).^2, 3))));%%%
else %Manhattan distance
    dist = sum(abs(window1-window2), 'all');
end

end