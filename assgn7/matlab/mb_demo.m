% tracker = [1 1 100 100]         % TODO Pick a bounding box in the format [x y w h]
% You can use ginput to get pixel coordinates

%% Initialize the tracker
PATHFORMAT = '../data/car/frame%04d.jpg';
RESULTPATH = '../results/car_mb.mp4';
FRAMESTART = 20;
FRAMEEND = 280;
tracker = [138.0000  111.0000  193.0000  170.0000];

% PATHFORMAT = '../data/landing/frame%04d_crop.jpg';
% RESULTPATH = '../results/landing_mb.mp4';
% FRAMESTART = 190;
% FRAMEEND = 308;
% tracker = [395.3276   52.2241  228.8861  153.9235];

% TODO run the Matthew-Baker alignment in both landing and car sequences
prev_frame = imread(sprintf(PATHFORMAT, FRAMESTART));

pickBox = input('use preset tracker(1) or ginput(2)? (enter 1 or 2)\n');
if pickBox == 2
tracker = pickBoundingBox(prev_frame);
end

template = imcropRect(prev_frame, tracker); % TODO

context = initAffineMBTracker(prev_frame, tracker);
Win = eye(3);

fprintf('initial tracker:\n');
disp(tracker);

%% Start tracking
% video = VideoWriter(RESULTPATH);
% open(video);

figure;
new_tracker = tracker;
for i = FRAMESTART+1:FRAMEEND
    path = sprintf(PATHFORMAT, i);
    if ~isfile(path)
        continue
    end
    new_frame = imread(path);
    
    Wout = affineMBTracker(new_frame, template, tracker, Win, context);

    new_tracker = warpRect(Wout, tracker); % TODO calculate the new bounding rectangle
    
    clf;
    hold on;
    imshow(new_frame);   
    rectangle('Position', new_tracker, 'EdgeColor', [1 1 0]);
    drawnow;

    prev_frame = new_frame;
    tracker = new_tracker;
    
%     writeVideo(video, getframe(gcf));
end

% close(video);
fprintf('done\n');

%% helper
function img2 = imcropRect(img1, rect)
[x1, y1, x2, y2, ~, ~] = getRectInfo(rect);
img2 = imcrop(img1, x1:x2, y1:y2);
end

function rectNew = warpRect(W, rect)
[x1, y1, x2, y2, w, h] = getRectInfo(rect);
% [x1new, y1new, ~, x2new, y2new, ~] = split(W * [x1 x2; y1 y2; 1 1]);
% rectNew = [x1new y1new x2new-x1new+1 y2new-y1new+1];

xcenter = (x1+x2)/2;
ycenter = (y1+y2)/2;
[xcenterNew, ycenterNew, ~] = split(W * [xcenter ycenter 1]');

scale = (norm(W(:,1)) + norm(W(:,2)))/2;

rectNew = [x1+(xcenterNew-xcenter) y1+(ycenterNew-ycenter) w h];
rectNew = scaleRect(rectNew, scale);
end

function rectNew = scaleRect(rect, scale)
[x, y, w, h] = split(rect);
wnew = w * scale;
hnew = h * scale;
xnew = x - (wnew - w)/2;
ynew = y - (hnew - h)/2;
rectNew = [xnew ynew wnew hnew];
end
