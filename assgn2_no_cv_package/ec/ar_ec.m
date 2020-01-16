% Q3.3.1
clc;
clear all;
close all;

%%
MOVSRC_PATH = '../data/ar_source.mov';
MOVDEST_PATH = '../data/book.mov';
TEMPLATEIMG_PATH = '../data/cv_cover.jpg';
OUTPUT_PATH = '../results/ar_ec.avi';
SRC_MARGINY = 45;
SCALE = 0.4;
%Src: source, Dest:destination

%% Load Data
disp('loading vidoes...');
movSrc = loadVid(MOVSRC_PATH);
movDest = loadVid(MOVDEST_PATH);
templateImg = imread(TEMPLATEIMG_PATH);
disp('loading done');

%% Preprocess
disp('preprocessing...');

frameNumS = length(movSrc);
frameNumD = length(movDest);

% trim src --> remove black margin
for i=1:frameNumS
    movSrc(i).cdata = movSrc(i).cdata(SRC_MARGINY:end-SRC_MARGINY+1,:,:);
end

[hs, ws, colors] = size(movSrc(1).cdata);
[ht, wt, colort] = size(templateImg);

%prepare trim point
s = hs/ht;
if floor(wt*s) > ws s = ws/wt; end
srcYstart = 1 + floor((hs - floor(ht*s))/2);
srcYend = hs - srcYstart;
srcXstart = 1 + floor((ws - floor(wt*s))/2);
srcXend = ws - srcXstart;

% trim src --> suit template image ratio
for i=1:frameNumS
    movSrc(i).cdata = movSrc(i).cdata(srcYstart:srcYend,srcXstart:srcXend,:);
end

% scale dest
disp('scaling video...');
movDestScaled = movDest;
for i=1:length(movDest)
    if mod(i, 100) == 0 fprintf('%d/%d\n',i,length(movDest)); end
    movDestScaled(i).cdata = imresize(movDest(i).cdata, SCALE);
end

% scale template img
templateImg = imresize(templateImg, SCALE);

disp('preprocess done');

%%
%get size
[hs, ws, colors] = size(movSrc(1).cdata);
[hd, wd, colord] = size(movDest(1).cdata);
[hdScaled, wdScaled, ~] = size(movDestScaled(1).cdata);
[ht, wt, colort] = size(templateImg);

%initialize output
result(1:frameNumD) = struct('cdata', zeros(hd, wd, 3, 'uint8'), 'colormap', []);

%% Processing
% const
n = frameNumD;
destMargin = 0;
destMin = 50;
recomputeFequency = 7;

%get template features
[locs1_0, desc1] = getFeaturePoints_ec(templateImg);

%scaling matrix
S1 = [wt/ws 0 0; 0 ht/hs 0; 0 0 1];
S2 = [SCALE 0 0; 0 SCALE 0; 0 0 1];

destXRng = [1 wdScaled];
destYRng = [1 hdScaled];
warpMask = uint8(zeros([hs, ws, colort]));

time0 = getTimeStr();

disp('start processing...');
for i=1:n
   
    % if range too small
    if destXRng(2) - destXRng(1) < destMin destXRng = [1 wdScaled]; end
    if destYRng(2) - destYRng(1) < destMin destYRng = [1 hdScaled]; end
    
    % get frame
    frameD = movDest(i).cdata;
    frameDScaled = movDestScaled(i).cdata;
    frameDTrimmed = frameDScaled(destYRng(1):destYRng(2), destXRng(1):destXRng(2), :);
    frameS = movSrc(mod(i-1, frameNumS)+1).cdata;
    
    % compute
    if mod(i-1, recomputeFequency) == 0
        % match features
        [locs2, desc2] = getFeaturePoints_ec(frameDTrimmed);
        [locs1, locs2] = matchFeatures_ec(locs1_0, locs2, desc1, desc2);
        locs2 = locs2 + repmat([destXRng(1) destYRng(1)], size(locs2, 1), 1);

        % compute H
        [H, ~] = computeH_ransac(locs1, locs2);
        HUnscaled = inv(S1)*H*S2;
        
        % prepare next trimming range
        tform = maketform( 'projective', inv(H)'); 
        [~, destXRng, destYRng] = imtransform( ones([ht wt]), tform, 'nearest');
        destXRng = [max(1, floor(destXRng(1))-destMargin) min(wd, ceil(destXRng(2))+destMargin)];
        destYRng = [max(1, floor(destYRng(1))-destMargin) min(hd, ceil(destYRng(2))+destMargin)];
    end
    
    % composite frames
    tform = maketform( 'projective', inv(HUnscaled)'); 
    warpedSrc = imtransform( frameS, tform, 'nearest', 'XData', [1 wd], 'YData', [1 hd], 'Size', [hd wd]);
    warpedMask = imtransform( warpMask, tform, 'nearest', 'XData', [1 wd], 'YData', [1 hd], 'Size', [hd wd], 'FillValues', 1);
    result(i).cdata = warpedSrc + warpedMask.*frameD;
        
    %display time
    [deltaTimeStr, deltaTimeSec] = getTimeDiff(time0, getTimeStr());
    fprintf('%d/%d\t%s\ttotal FPS: %d\n',i,frameNumD,deltaTimeStr, (i-1)/deltaTimeSec);
end
disp('finish processing');

%% Save
disp('saving...');
saveVid(OUTPUT_PATH, result(1:n));
disp('saved');



