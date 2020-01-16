function imgCrop = imcrop(img, xrange, yrange)
img = double(img);
[h, w] = size(img);

xmin = min(xrange);
xmax = max(xrange);
ymin = min(yrange);
ymax = max(yrange);

margin = ceil(max([1-xmin 1-ymin xmax-w ymax-h 0]));
img1pad = padarray(img, [margin margin], 'replicate');

[X, Y] = meshgrid(xrange+margin, yrange+margin);
imgCrop = interp2(img1pad, X, Y);    
end