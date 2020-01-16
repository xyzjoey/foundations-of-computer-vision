%%
alpha = 50;
K = 100;

%%
if ~isfile('visionHOG.mat')
    load('../data/traintest.mat', 'train_imagenames', 'train_labels');
    
    trainResponses = extractHOGResponses(train_imagenames);
    dictionary = getDictionary(trainResponses, alpha, K);
    trainWordMaps = getVisualWordsAll(trainResponses, dictionary);
    trainHistSet = getHistSet(trainWordMaps, K);
    save('visionHOG.mat', 'dictionary', 'trainHistSet', 'train_labels');
    disp('visionHOG.mat saved');
end

if ~isfile('testFeaturesHOG.mat')
    load('../data/traintest.mat', 'test_imagenames', 'test_labels');
    
    testResponses = extractHOGResponses(test_imagenames);
    testWordMaps = getVisualWordsAll(testResponses, dictionary);
    testHistSet = getHistSet(testWordMaps, K);
    save('testFeaturesHOG.mat', 'testHistSet', 'test_labels');
    disp('testFeaturesHOG.mat saved');
end

load('visionHOG.mat', 'dictionary', 'trainHistSet', 'train_labels');
load('testFeaturesHOG.mat', 'testHistSet', 'test_labels');

%% get svm model
disp('get svm model...')
svmModelGaussian = getSVMModel(trainHistSet, train_labels, 'gaussian');
svmModelLinear = getSVMModel(trainHistSet, train_labels, 'linear');
disp('svm obtained')

%% predict
disp('start prediction...')

% [accuracies, confusions, kBest] = knnEvaluate(trainHistSet, testHistSet, train_labels, test_labels, 'chi2')
% fprintf('kNN best k = %d\n', kBest)
% disp('accuracy with best k:')
% disp(accuracies(kBest))
% disp('confusion with best k:')
% disp(confusions(:,:,kBest))

[accuracy, confusion] = svmEvaluate(svmModelLinear, testHistSet, test_labels);
disp('svm linear')
disp('accuracy:')
disp(accuracy)
disp('confusion:')
disp(confusion)

% [accuracy, confusion] = svmEvaluate(svmModelGaussian, testHistSet, test_labels);
% 
% disp('svm gaussian')
% disp('accuracy:')
% disp(accuracy)
% disp('confusion:')
% disp(confusion)




%%
function hogResponses = extractHOGResponses(imgPaths) %return Tx1 cell array
PREFIX = '../data/';
imgNum = size(imgPaths, 2);

hogResponses = cell(imgNum, 1);
for i = 1:imgNum
    fprintf('img hog %d/%d...\n', i, imgNum);
    img = imread(strcat(PREFIX, imgPaths{i}));
    hogResponses{i} = HOGrgb(img); % blockNum x 36*3 matrix
end

end

function randomResponse = getRandomResponse(response, alpha)
n = size(response, 1);
inds = randperm(n, alpha);

randomResponse = response(inds, :);

end

function dictionary = getDictionary(hogResponses, alpha, K) %return Kx36*3
imgNum = size(hogResponses, 1);

hogResponsesRandom = zeros(alpha*imgNum, 36*3);
for i = 1:imgNum
    hogResponsesRandom(alpha*(i-1)+1:alpha*(i),:) = getRandomResponse(hogResponses{i}, alpha);
end

disp('kmeans...')
[~, dictionary] = kmeans(hogResponsesRandom, K, 'EmptyAction', 'drop', 'MaxIter', 1000);
end

function [wordMap] = getVisualWords(hogResponse, dictionary) %return blockNum x 1 or 1 x blockNum ?
[~, labels] = pdist2(dictionary, hogResponse, 'euclidean', 'Smallest', 1);
wordMap = labels;

end

function wordMaps = getVisualWordsAll(hogResponses, dictionary) %return imgNum x 1 cell array
imgNum = size(hogResponses, 1);

wordMaps = cell(imgNum, 1);
for i = 1:imgNum
    fprintf('word map %d/%d...\n', i, imgNum);
    wordMaps{i} = getVisualWords(hogResponses{i}, dictionary);
end

end

function histogram = getHist(wordMap, K) %return 1 x K matrix

histogram = zeros(1, K);
for i = 1:K
    histogram(i) = sum(wordMap == i);
end
histogram = histogram./numel(wordMap);

end

function histograms = getHistSet(wordMaps, K) %return imgNum x K matrix
imgNum = size(wordMaps, 1);
histograms = zeros(imgNum, K);
    
for i = 1:imgNum
    fprintf('histograms %d/%d...\n', i, imgNum);
    histograms(i, :) = getHist(wordMaps{i}, K);
end

end

function SVMModel = getSVMModel(trainHistSet, train_labels, kernelName)
    
t = templateSVM('Standardize', true, 'KernelFunction',kernelName,'BoxConstraint',1,'KernelScale','auto');
SVMModel = fitcecoc(trainHistSet, train_labels, 'Learners', t);

end

function [accuracy, confusion] = svmEvaluate(SVMModel, testHistSet, test_labels)
classNum = numel(SVMModel.ClassNames);
testNum = size(testHistSet, 1);

predictedClasses = predict(SVMModel, testHistSet);

confusion = zeros(classNum);
for i = 1:testNum
    confusion(test_labels(i), predictedClasses(i)) = confusion(test_labels(i), predictedClasses(i)) + 1;
end

accuracy = trace(confusion)/testNum;

end

function [accuracies, confusions, kBest] = knnEvaluate(trainHistSet, testHistSet, train_labels, test_labels, distanceMethod)
kMax = 40;
classNum = max(train_labels);
testNum = size(testHistSet, 1);

confusions = zeros(classNum, classNum, kMax);
for i = 1:testNum
    dist = getImageDistance(testHistSet(i,:), trainHistSet, distanceMethod);
    [~, inds] = mink(dist,kMax);
    
    trueClass = test_labels(i);
    for k = 1:kMax
        kNearestInds = inds(1:k);
        kNearestClasses = train_labels(kNearestInds);
        predictedClass = mode(kNearestClasses);
        
        confusions(trueClass,predictedClass,k) = confusions(trueClass,predictedClass,k) + 1;
    end
end

accuracies = zeros(1, kMax);
for k = 1:kMax
    accuracies(k) = trace(confusions(:,:,k))/testNum;
end
[~, kBest] = max(accuracies);

end