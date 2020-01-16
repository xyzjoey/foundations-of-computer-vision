load('../data/traintest.mat', 'train_labels', 'test_imagenames', 'test_labels', 'mapping');
testNum = size(test_imagenames, 2);
classNum = size(mapping, 2);

load('visionRandom.mat', 'dictionary', 'filterBank', 'trainFeatures');
dictRandom = dictionary;
filterBankRandom = filterBank;
trainFeaturesRandom = trainFeatures;

%% get svm model
disp('get svm model...')

if isfile('visionSVM.mat')
    load('visionSVM.mat', 'svmModelGaussian', 'svmModelLinear');
else
    t = templateSVM('Standardize', true, 'KernelFunction','gaussian','BoxConstraint',1,'KernelScale','auto');
    svmModelGaussian = fitcecoc(trainFeaturesRandom, train_labels, 'Learners', t);
    t = templateSVM('Standardize', true, 'KernelFunction','linear','BoxConstraint',1,'KernelScale','auto');
    svmModelLinear = fitcecoc(trainFeaturesRandom, train_labels, 'Learners', t);
    save('visionSVM.mat', 'svmModelGaussian', 'svmModelLinear');
end

disp('svm model done')

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

%% predict (gaussian)
predictedClasses = predict(svmModelGaussian, testFeaturesRandom);
confusion = zeros(classNum);
for i = 1:testNum
    confusion(test_labels(i), predictedClasses(i)) = confusion(test_labels(i), predictedClasses(i)) + 1;
end
accuracy = trace(confusion)/testNum;

%% display
disp('gaussian')
disp('accuracy:')
disp(accuracy)
disp('confusion:')
disp(confusion)

%% predict (linear)
predictedClasses = predict(svmModelLinear, testFeaturesRandom);
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