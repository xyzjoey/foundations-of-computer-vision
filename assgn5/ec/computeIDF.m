load('visionRandom.mat', 'trainFeatures');
imgNum = size(trainFeatures, 1);

DF = sum(trainFeatures ~= 0);
IDF = log(imgNum./(1 + DF));

save('idf.mat', 'IDF');