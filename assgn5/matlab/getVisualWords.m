function [wordMap] = getVisualWords(I, filterBank, dictionary)

[h, w, ~] = size(I);
filterNum = size(filterBank, 1);

filterResponses = extractFilterResponses(I, filterBank);
filterResponses2D = reshape(filterResponses, [], 3*filterNum);

[~, labels] = pdist2(dictionary, filterResponses2D, 'euclidean', 'Smallest', 1);
wordMap = reshape(labels, h, w);

end