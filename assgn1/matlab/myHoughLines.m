function [rhos, thetas] = myHoughLines(H, nLines)
%Your implemention here

H = imregionalmax(H) .* H;

[sortedH, sortedInds] = sort(H(:),'descend');

nLines = min(nLines, nnz(H));
[rhos, thetas] = ind2sub(size(H), sortedInds(1:nLines));

end
        