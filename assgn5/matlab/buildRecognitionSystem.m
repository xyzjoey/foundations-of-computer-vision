load('../data/traintest.mat', 'train_imagenames', 'train_labels');
trainLabels = train_labels;
imgNum = size(train_imagenames, 2);

%% random
PATH_PREFIX = input('enter prefix for loading precomputed wordMap by random dictionary (../data/):\n', 's');
load('dictionaryRandom.mat', 'dictionary', 'filterBank');

dictSize = size(dictionary, 1);
trainFeatures = zeros(imgNum, dictSize);

for i = 1:imgNum
    fprintf('img %d/%d...\n', i, imgNum);
    load([PATH_PREFIX, strrep(train_imagenames{i},'.jpg','.mat')], 'wordMap');
    trainFeatures(i,:) = getImageFeatures(wordMap, dictSize);
end

save('visionRandom.mat', 'dictionary', 'filterBank', 'trainFeatures', 'trainLabels');
disp('visionRandom.mat saved')

%% harris
PATH_PREFIX = input('enter prefix for loading precomputed wordMap by harris dictionary (../data/):\n', 's');
load('dictionaryHarris.mat', 'dictionary', 'filterBank');

dictSize = size(dictionary, 1);
trainFeatures = zeros(imgNum, dictSize);

for i = 1:imgNum
    fprintf('img %d/%d...\n', i, imgNum);
    load([PATH_PREFIX, strrep(train_imagenames{i},'.jpg','.mat')], 'wordMap');
    trainFeatures(i,:) = getImageFeatures(wordMap, dictSize);
end

save('visionHarris.mat', 'dictionary', 'filterBank', 'trainFeatures');
disp('visionHarris.mat saved')
