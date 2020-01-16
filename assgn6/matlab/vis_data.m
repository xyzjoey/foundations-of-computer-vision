layers = get_lenet();
load lenet.mat
% load data
% Change the following value to true to load the entire dataset.
fullset = false;
[xtrain, ytrain, xvalidate, yvalidate, xtest, ytest] = load_mnist(fullset);
xtrain = [xtrain, xvalidate];
ytrain = [ytrain, yvalidate];
m_train = size(xtrain, 2);
batch_size = 64;
 
 
layers{1}.batch_size = 1;
img = xtest(:, 1);
img = reshape(img, 28, 28);
imshow(img')
 
%[cp, ~, output] = conv_net_output(params, layers, xtest(:, 1), ytest(:, 1));
output = convnet_forward(params, layers, xtest(:, 1));
output_1 = reshape(output{1}.data, 28, 28);
% Fill in your code here to plot the features.

%%
subplotRow = 4;
subplotCol = 5;
for l = 2:3
    showOutput(output{l}, layers{l}, subplotRow, subplotCol, l);
%     showOutputGray(output{l}, layers{l}, subplotRow, subplotCol, l);
end

%%
function img = getImg(data, h, w, ind)
imgs = reshape(data, h, w, []);
img = imgs(:,:,ind)';
end

function showOutput(output, layer, subplotRow, subplotCol, layerInd)
h = output.height;
w = output.width;

figure,
for i = 1:subplotRow
    for j = 1:subplotCol
        ind = sub2ind([subplotRow subplotCol], i, j);
        outputImg = getImg(output.data, h, w, ind);
        subplot(subplotRow, subplotCol, ind)
        imshow(outputImg)
    end
end
suptitle(sprintf('layer %d, type %s', layerInd, layer.type))
end

function showOutputGray(output, layer, subplotRow, subplotCol, layerInd)
h = output.height;
w = output.width;

figure,
for i = 1:subplotRow
    for j = 1:subplotCol
        ind = sub2ind([subplotRow subplotCol], i, j);
        outputImg = getImg(output.data, h, w, ind);
        subplot(subplotRow, subplotCol, ind)
        imshow(mat2gray(outputImg))
    end
end
suptitle(sprintf('layer %d, type %s (mat2gray applied)', layerInd, layer.type))
end
