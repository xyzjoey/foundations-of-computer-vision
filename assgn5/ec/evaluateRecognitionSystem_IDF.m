%% load
load('../data/traintest.mat', 'train_labels', 'test_imagenames', 'test_labels', 'mapping');
testNum = size(test_imagenames, 2);
classNum = size(mapping, 2);

load('visionRandom.mat', 'dictionary', 'filterBank', 'trainFeatures');
dictRandom = dictionary;
filterBankRandom = filterBank;
trainFeaturesRandom = trainFeatures;

%% get test img random histSet
disp('get testFeaturesRandom...')

if ~isfile('testFeaturesRandom.mat')
    prefix = input('enter prefix for loading precomputed wordMap by random dictionary (../data/):\n', 's');
    testFeaturesRandom = createHistSet(test_imagenames, dictRandom, filterBankRandom, prefix);
    save('testFeaturesRandom.mat', 'testFeaturesRandom');
    disp('testFeaturesRandom.mat saved')
end

load('testFeaturesRandom.mat', 'testFeaturesRandom');
disp('testFeaturesRandom done')

%% load idf
if ~isfile('idf.mat')
    computeIDF;
end
load('idf.mat', 'IDF');

%% tfidf
trainFeaturesRandomTFIDF = trainFeaturesRandom .* repmat(IDF, size(trainFeaturesRandom, 1), 1);
testFeaturesRandomTFIDF = testFeaturesRandom .* repmat(IDF, size(testFeaturesRandom, 1), 1);

%% kNN
kMax = 40;
confusions = zeros(classNum, classNum, kMax);
for i = 1:testNum
    fprintf('test img %d/%d...\n', i, testNum);
    dist = getImageDistance(testFeaturesRandomTFIDF(i,:), trainFeaturesRandomTFIDF, 'chi2');
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

%% display result
figure,
plot(1:kMax, accuracies, '.-', 'MarkerSize', 20);
title('Accuracies for k = 1 to 40')

fprintf('best k = %d\n', kBest)
fprintf('accuracy with k = %d\n', kBest)
disp(accuracies(kBest))
fprintf('confusion with k = %d\n', kBest)
disp(confusions(:,:,kBest))

%% linear svm
disp('linear svm...')
t = templateSVM('Standardize', true, 'KernelFunction','linear','BoxConstraint',1,'KernelScale','auto');
svmModelLinear = fitcecoc(trainFeaturesRandomTFIDF, train_labels, 'Learners', t);

predictedClasses = predict(svmModelLinear, testFeaturesRandomTFIDF);
confusion = zeros(classNum);
for i = 1:testNum
    confusion(test_labels(i), predictedClasses(i)) = confusion(test_labels(i), predictedClasses(i)) + 1;
end
accuracy = trace(confusion)/testNum;

%% display
disp('linear')
disp('accuracy:')
disp(accuracy)
disp('confusion:')
disp(confusion)


%% gaussian svm
disp('gaussian svm...')
t = templateSVM('Standardize', true, 'KernelFunction','gaussian','BoxConstraint',1,'KernelScale','auto');
svmModelGaussian = fitcecoc(trainFeaturesRandomTFIDF, train_labels, 'Learners', t);

predictedClasses = predict(svmModelGaussian, testFeaturesRandomTFIDF);
confusion = zeros(classNum);
for i = 1:testNum
    confusion(test_labels(i), predictedClasses(i)) = confusion(test_labels(i), predictedClasses(i)) + 1;
end
accuracy = trace(confusion)/testNum;

%% display
disp('linear')
disp('accuracy:')
disp(accuracy)
disp('confusion:')
disp(confusion)