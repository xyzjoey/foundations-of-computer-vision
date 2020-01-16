function mat = gaussian(sze, sigma)
X = 0:sze(2)-1;
Y = 0:sze(1)-1;
X = X - (sze(2)-1)/2;
Y = Y - (sze(1)-1)/2;
[X, Y] = meshgrid(X, Y);

mat = exp(-(X.^2 + Y.^2)/(2*sigma^2));
mat = mat/sum(sum(mat));
end