%% Network defintion
layers = get_lenet();

%% Loading data
fullset = false;
[xtrain, ytrain, xvalidate, yvalidate, xtest, ytest] = load_mnist(fullset);

% load the trained weights
load lenet.mat

%% Testing the network
% Modify the code to get the confusion matrix
confusion = zeros(10);
incorrectPredictions = {};
for i=1:100:size(xtest, 2)
    fprintf('%d/%d\n', i, size(xtest, 2))%
    [output, P] = convnet_forward(params, layers, xtest(:, i:i+99));
    
    [~, predLabels] = max(P);
    confusion = confusion + getConfusion(predLabels, ytest(i:i+99));
    incorrectPredictions = [incorrectPredictions getIncorrect(xtest(:, i:i+99), ytest(i:i+99), predLabels)];
end

fprintf('confusion:\n')
disp(confusion)
fprintf('lower triangular of confusion + transpose(confusion):\n')
disp(tril(confusion+confusion', -1))

showPredictions(incorrectPredictions, 9, 6);

%%
function confusion = getConfusion(predLabels, labels)
N = numel(labels);

confusion = zeros(10);
for i = 1:N
    predLabel = predLabels(i);
    trueLabel = labels(i);
    confusion(trueLabel,predLabel) = confusion(trueLabel,predLabel) + 1;
end
end

function incorrectPredictions = getIncorrect(data, labels, predLabels)
incorrectPredictions = {};
for i = 1:numel(labels)
    predLabel = predLabels(i);
    trueLabel = labels(i);
    if trueLabel ~= predLabel
        prediction.predLabel = predLabel;
        prediction.trueLabel = trueLabel;
        prediction.img = reshape(data(:,i), 28, 28);
        incorrectPredictions{end+1} = prediction;
    end
end
end

function showPredictions(predictions, row, col)
figure,
for i = 1:numel(predictions)
    subplot(row, col, i)
    imshow(predictions{i}.img')
    title(sprintf('%d predicted as %d', predictions{i}.trueLabel-1, predictions{i}.predLabel-1))
end
end
