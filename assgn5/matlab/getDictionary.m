function [dictionary] = getDictionary(imgPaths, alpha, K, method)

PATH_PREFIX = '../data/';

% set getPoint method
switch method
    case 'random'
        getPoints = @(I) getRandomPoints(I, alpha);
    case 'harris'
        getPoints = @(I) getHarrisPoints(I, alpha, 0.05);
    otherwise
        error('Error. Unexpected points selection method: %s', method)
end

filterBank = createFilterBank();
imgNum = size(imgPaths, 2);
% imgNum = 10;
filterNum = size(filterBank, 1);

pixelResponses = zeros(alpha*imgNum, 3*filterNum);

for i = 1:imgNum
    fprintf('img %d/%d...\n', i, imgNum);
    img = imread(strcat(PATH_PREFIX, imgPaths{i}));
    [h, w, ~] = size(img);
    filterResponses = extractFilterResponses(img, filterBank);
    
    points = getPoints(img);
    pointInds = sub2ind([h w], points(:,2), points(:,1));
    filterResponses2D = reshape(filterResponses, [], 3*filterNum);
    pixelResponses(alpha*(i-1)+1:alpha*(i),:) = filterResponses2D(pointInds,:);
end

disp('kmeans...')
[~, dictionary] = kmeans(pixelResponses, K, 'EmptyAction', 'drop', 'MaxIter', 1000);

disp('dictionary done')
end