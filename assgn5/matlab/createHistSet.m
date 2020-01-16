function histSet = createHistSet(imgPaths, dictionary, filterBank, prefix)
imgNum = size(imgPaths, 2);
dictSize = size(dictionary, 1);
histSet = zeros(imgNum, dictSize);

for i = 1:imgNum
    fprintf('img %d/%d...\n', i, imgNum);
    load([prefix, strrep(imgPaths{i},'.jpg','.mat')], 'wordMap');
    histSet(i,:) = getImageFeatures(wordMap, dictSize);
end

end