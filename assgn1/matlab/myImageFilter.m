function [img1] = myImageFilter(img0, h)

[height, width] = size(img0);
hSize = size(h, 1);
hSize2 = floor(hSize/2);

%prepare temp img with padded values
imgPad = zeros(height+hSize-1, width+hSize-1);
imgPad(hSize2+1:height+hSize2, hSize2+1:width+hSize2) = img0;
%left
imgPad(hSize2+1:height+hSize2, 1:hSize2) = repmat(img0(:, 1), 1, hSize2);
%right
imgPad(hSize2+1:height+hSize2, width+hSize2+1:end) = repmat(img0(:, end), 1, hSize2);
%top
imgPad(1:hSize2, :) = repmat(imgPad(hSize2+1, :), hSize2, 1);
%bottom
imgPad(height+hSize2+1:end, :) = repmat(imgPad(height+hSize2, :), hSize2, 1);

%generate resulting img1
img1 = zeros(size(img0));
for i=1:height
    for j=1:width
        img1(i, j) = sum(sum(h.*imgPad(i:i+hSize-1, j:j+hSize-1)));
    end
end
    
end
