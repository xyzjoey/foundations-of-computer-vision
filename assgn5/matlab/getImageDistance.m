function [dist] = getImageDistance(hist1, histSet, method)

hist1 = repmat(hist1, size(histSet, 1), 1);

switch method
    case 'euclidean'
        dist = sqrt(sum( (hist1-histSet).^2 , 2));
    case 'chi2'
        dist = 0.5*(sum( ((hist1-histSet).^2)./(hist1+histSet+eps) , 2));
    otherwise
        error('Error. Unexpected image distance method: %s', method)
end

end