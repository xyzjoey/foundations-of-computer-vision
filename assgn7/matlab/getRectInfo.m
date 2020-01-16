function [x1, y1, x2, y2, w, h] = getRectInfo(rect)
[x1, y1, w, h] = split(rect);
x2 = x1 + w - 1;
y2 = y1 + h - 1;
end