function [points] = getHarrisPoints(I, alpha, k)

[h, w, channelNum] = size(I);
if channelNum > 1
    I = rgb2gray(I);
end
if max(max(I)) > 1.0
    I = mat2gray(I);
end

[Gx,Gy] = imgradientxy(I);

Ixx = Gx.*Gx;
Ixy = Gx.*Gy;
Iyy = Gy.*Gy;

mask = ones(3, 3);
M11 = conv2(Ixx, mask, 'same');
M12 = conv2(Ixy, mask, 'same');
M21 = M12;
M22 = conv2(Iyy, mask, 'same');

Mdet = M11.*M22 - M12.*M21;
Mtr = M11 + M22;

R = Mdet - k*Mtr;

[~, indsTop] = maxk(R(:),alpha);
[rows, cols] = ind2sub([h w], indsTop);

points = [cols rows];


end