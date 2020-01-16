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

%% kNN
kMax = 40;
confusions = zeros(classNum, classNum, kMax);
for i = 1:testNum
    fprintf('test img %d/%d...\n', i, testNum);
    dist = getImageDistance(testFeaturesRandom(i,:), trainFeaturesRandom, 'chi2');
    [~, inds] = mink(dist,kMax);
    
    trueClass = test_labels(i);
    for k = 1:kMax
        kNearestInds = inds(1:k);
        kNearestClasses = train_labels(kNearestInds);
        predictedClass = mode(kNearestClasses);
        
        confusions(trueClass,predictedClass,k) = confusions(trueClass,predictedClass,k) + 1;
    end
end

%% calculate accuracies from confusions
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

