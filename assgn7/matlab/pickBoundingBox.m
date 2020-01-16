function rect = pickBoundingBox(img)
% pick
figure;
imshow(img);
title('please pick 2 diagonal corners of the bounding box');
hold on
[x1, y1] = ginput(1);
plot(x1, y1, 'r*', 'LineWidth', 2, 'MarkerSize', 10);
[x2, y2] = ginput(1);
plot(x2, y2, 'r*', 'LineWidth', 2, 'MarkerSize', 10);
hold off

% swap
if x1 > x2
    [x1, x2] = swap(x1, x2);
end
if y1 > y2
    [y1, y2] = swap(y1, y2);
end

% output
rect = [x1 y1 x2-x1+1 y2-y1+1];
end

function [b, a] = swap(a, b)
end