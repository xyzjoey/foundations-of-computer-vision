function mat = gaussian(size, sigma)
X = 0:size(2)-1;
Y = 0:size(1)-1;
X = X - (size(2)-1)/2;
Y = Y - (size(1)-1)/2;
[X, Y] = meshgrid(X, Y);

mat = exp(-(X.^2 + Y.^2)/(2*sigma^2));
mat = mat/sum(sum(mat));
end