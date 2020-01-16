load('../data/traintest.mat', 'train_labels', 'test_imagenames', 'test_labels', 'mapping');
testNum = size(test_imagenames, 2);
classNum = size(mapping, 2);

load('visionRandom.mat', 'dictionary', 'filterBank', 'trainFeatures');
dictRandom = dictionary;
filterBankRandom = filterBank;
trainFeaturesRandom = trainFeatures;

load('visionHarris.mat', 'dictionary', 'filterBank', 'trainFeatures');
dictHarris = dictionary;
filterBankHarris = filterBank;
trainFeaturesHarris= trainFeatures;

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

%% get test img harris histSet
disp('get testFeaturesHarris...')

if ~isfile('testFeaturesHarris.mat')
    prefix = input('enter prefix for loading precomputed wordMap by harris dictionary (../data/):\n', 's');
    testFeaturesHarris = createHistSet(test_imagenames, dictHarris, filterBankHarris, prefix);
    save('testFeaturesHarris.mat', 'testFeaturesHarris');
    disp('testFeaturesHarris.mat saved')
end

load('testFeaturesHarris.mat', 'testFeaturesHarris');
disp('testFeaturesHarris done')

%% test random & euclidean
disp('test random & euclidean...')

confusion1 = zeros(classNum, classNum);
for i = 1:testNum
    fprintf('test img %d/%d...\n', i, testNum);
    dist = getImageDistance(testFeaturesRandom(i,:), trainFeaturesRandom, 'euclidean');
    [~, ind] = min(dist);
    
    predictedClass = train_labels(ind);
    trueClass = test_labels(i);
    
    confusion1(trueClass,predictedClass) = confusion1(trueClass,predictedClass) + 1;
end

%% test random & chi2
disp('test random & chi2...')

confusion2 = zeros(classNum, classNum);
for i = 1:testNum
    fprintf('test img %d/%d...\n', i, testNum);
    dist = getImageDistance(testFeaturesRandom(i,:), trainFeaturesRandom, 'chi2');
    [~, ind] = min(dist);
    
    predictedClass = train_labels(ind);
    trueClass = test_labels(i);
    
    confusion2(trueClass,predictedClass) = confusion2(trueClass,predictedClass) + 1;
end

%% test harris & euclidean
disp('test harris & euclidean...')

confusion3 = zeros(classNum, classNum);
for i = 1:testNum
    fprintf('test img %d/%d...\n', i, testNum);
    dist = getImageDistance(testFeaturesHarris(i,:), trainFeaturesHarris, 'euclidean');
    [~, ind] = min(dist);
    
    predictedClass = train_labels(ind);
    trueClass = test_labels(i);
    
    confusion3(trueClass,predictedClass) = confusion3(trueClass,predictedClass) + 1;
end

%% test harris & chi2
disp('test harris & chi2...')

confusion4 = zeros(classNum, classNum);
for i = 1:testNum
    fprintf('test img %d/%d...\n', i, testNum);
    dist = getImageDistance(testFeaturesHarris(i,:), trainFeaturesHarris, 'chi2');
    [~, ind] = min(dist);
    
    predictedClass = train_labels(ind);
    trueClass = test_labels(i);
    
    confusion4(trueClass,predictedClass) = confusion4(trueClass,predictedClass) + 1;
end

%% print results (random)
disp('random & euclidean result:')
disp('accuracy:')
disp(trace(confusion1)/testNum)
disp('confusion:')
disp(confusion1)

disp('random & chi2 result:')
disp('accuracy:')
disp(trace(confusion2)/testNum)
disp('confusion:')
disp(confusion2)

%% print results (harris)
disp('harris & euclidean result:')
disp('accuracy:')
disp(trace(confusion3)/testNum)
disp('confusion:')
disp(confusion3)

disp('harris & chi2 result:')
disp('accuracy:')
disp(trace(confusion4)/testNum)
disp('confusion:')
disp(confusion4)
