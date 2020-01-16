imgPaths = getImagePaths();
imgNum = numel(imgPaths);
inputImgSze = [28 28];
[layers, params, labelMap] = getConvNet();

% for i = 1:imgNum
for i = 4
    fprintf('%s...\n', imgPaths{i});
    imgOrigin = imread(imgPaths{i});
    
    [imgsFiltered, boundingBoxes] = extractNumberImgs(imgOrigin, inputImgSze);
    P = predict(params, layers, imgsFiltered, inputImgSze);
    showResult(imgOrigin, imgsFiltered, boundingBoxes, P, labelMap, imgPaths{i});
end


%%
function imgPaths = getImagePaths()
imgPaths = {};
imgPaths{end+1} = '../images/image1.JPG';
imgPaths{end+1} = '../images/image2.JPG';
imgPaths{end+1} = '../images/image3.png';
imgPaths{end+1} = '../images/image4.jpg';
end

function [layers, params, labelMap] = getConvNet()
layers = get_lenet();
load('lenet.mat', 'params');
labelMap = 0:9;
end

function P = predict(params, layers, imgs, imgSze)
imgNum = numel(imgs);
inputdata = zeros(imgSze(1)*imgSze(2), imgNum);
for i = 1:imgNum
    inputdata(:,i) = reshape(imgs{i}', [], 1);
end

layers{1}.batch_size = imgNum;
[~, P] = convnet_forward(params, layers, inputdata);
end

function imgEdge = edgeFilter(img)
threshold = 0.3;

img = rgb2gray(img);
img = mat2gray(img);

imgEdge = (1-img);
imgEdge(imgEdge<threshold) = 0;
end

function boundingBox = CCtoBox(pixelInds, imgSze) % CC: connected component
[Y, X] = ind2sub(imgSze, pixelInds);

xmin = min(X);
ymin = min(Y);
w = max(X) - xmin + 1;
h = max(Y) - ymin + 1;

boundingBox = [xmin ymin w h];
end

function boundingBoxes = CCstoBoxes(CCs)
boundingBoxes = cell(1, CCs.NumObjects);
for i = 1:CCs.NumObjects   
    boundingBoxes{i} = CCtoBox(CCs.PixelIdxList{i}, CCs.ImageSize);
end
end

function imgs = CCstoImgs(CCs, imgEdge, szeOut)
margin = 5;
szeIn = size(imgEdge);

imgs = cell(1, CCs.NumObjects);
for i = 1:CCs.NumObjects
    pixelInds = CCs.PixelIdxList{i};
    [Y, X] = ind2sub(szeIn, pixelInds);

    % bounding
    xmin = min(X);
    ymin = min(Y);
    w = max(X) - xmin + 1;
    h = max(Y) - ymin + 1;

    % move to origin
    X = X - xmin + 1;
    Y = Y - ymin + 1;

    % create img
    img = zeros(h, w);
    for j = 1:numel(pixelInds)
        img(Y(j),X(j)) = imgEdge(pixelInds(j));
    end

    % resize img
    img = imresize(img, [szeOut(1)-margin NaN]);
    if size(img, 2) > szeOut(2)-margin
        img = imresize(img, [NaN szeOut(2)-margin]);
    end

    % pad img
    dh = szeOut(1) - size(img, 1);
    dw = szeOut(2) - size(img, 2);
    up = ceil(dh/2);
    down = dh - up;
    left = ceil(dw/2);
    right = dw - left;
    img = padarray(img, [up left], 0, 'pre');
    img = padarray(img, [down right], 0, 'post');
    
    imgs{i} = img;
end
end

function boxNew = expandBox(box)
margin = (box(3).^2 + box(4).^2).^(0.3);

boxNew = box;
boxNew(1:2) = boxNew(1:2) - margin; % x, y
boxNew(3:4) = boxNew(3:4) + 2*margin; % w, h
end

function isSubset = isSubsetBox(box1, box2)
x1min = box1(1);
y1min = box1(2);
x1max = x1min + box1(3) - 1;
y1max = y1min + box1(4) - 1;

x2min = box2(1);
y2min = box2(2);
x2max = x2min + box2(3) - 1;
y2max = y2min + box2(4) - 1;

isSubset = x1min <= x2min & y1min <= y2min & x1max >= x2max & y1max >= y2max;
end

function mergeInds = whichToMerge(pixelList, boundingBoxes, ind)
% add margin
boundingBoxI = expandBox(boundingBoxes{ind});

mergeInds = [];
for n = 1:numel(pixelList)
    if n == ind continue, end
    if isSubsetBox(boundingBoxI, boundingBoxes{n}) | ...
       isSubsetBox(boundingBoxes{n}, boundingBoxI)
        mergeInds(end+1) = n; % merge if is subset
    end
end
end

function CCsNew = mergeCCs(CCs, imgSze)
boundingBoxes = CCstoBoxes(CCs);
pixelList = CCs.PixelIdxList;

for i = 1:CCs.NumObjects
    if isempty(pixelList{i}) continue, end % if removed, skip
    
    mergeInds = whichToMerge(pixelList, boundingBoxes, i);
    for j = mergeInds
        pixelList{i} = [pixelList{i}; pixelList{j}]; % merge
        pixelList{j} = []; % remove another one
    end
    boundingBoxes{i} = CCtoBox(pixelList{i}, imgSze); % update box
end

% assign to CCsNew
CCsNew.PixelIdxList = {};
for i = 1:CCs.NumObjects
    if ~isempty(pixelList{i})
        CCsNew.PixelIdxList{end+1} = pixelList{i};
    end
end
CCsNew.NumObjects = numel(CCsNew.PixelIdxList);
CCsNew.ImageSize = CCs.ImageSize;
CCsNew.Connectivity = CCs.Connectivity;
end

function [imgsFiltered, boundingBoxes] = extractNumberImgs(img, szeOut)
minPixelNum = 5;

% get edge
imgEdge = edgeFilter(img);

% get connected components
imgBW = imgEdge > 0;
imgBW = bwareaopen(imgBW, minPixelNum);
CCs = bwconncomp(imgBW);

% merge connected components
CCs = mergeCCs(CCs, size(imgEdge));

% CC to output
imgsFiltered = CCstoImgs(CCs, imgEdge, szeOut);
boundingBoxes = CCstoBoxes(CCs);
end

function showResult(img_origin, imgs_in, boundingBoxes, P, labelMap, imgPath)
imgNum = numel(imgs_in);

% make folder for results
if ~exist('../results', 'dir')
    mkdir('../results');
end

for i = 1:imgNum
    [~, predInd] = max(P(:,i));
    predLabel = labelMap(predInd);
    
    figure,
    subplot(2,2,[1,2]);
    imshow(img_origin);
    title(sprintf('%s %d', imgPath, i))
    
    subplot(2,2,[1,2]);
    rectangle('Position', boundingBoxes{i}, 'EdgeColor', 'r');
    
    subplot(2,2,3);
    imshow(imgs_in{i});
    title('filtered image')
    
    subplot(2,2,4);
    bar(labelMap, P(:,i)')
    ylim([0 1])
    title('probabilities of labels')
    text(1.5,0.9,sprintf('predicted number: %d', predLabel),'Color','red','FontSize',8)
    
    % save resulting images
    [~, filename, ~] = fileparts(imgPath);
    saveas(gcf,sprintf('../results/Q6_%s_%02d.png', filename, i));
end
end