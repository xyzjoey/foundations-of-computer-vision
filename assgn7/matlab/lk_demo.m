% tracker = [119 104 223 178]         % TODO Pick a bounding box in the format [x y w h]
% You can use ginput to get pixel coordinates
close all

%% Initialize the tracker
PATHFORMAT = '../data/car/frame%04d.jpg';
RESULTPATH = '../results/car_lk.mp4';
FRAMESTART = 20;
FRAMEEND = 280;
tracker = [122.0000  102.0000  229.0000  182.0000]; % LK
% tracker = [165   115   132   157]; % LK robust
% tracker = [143   113   173   160]; % LK pyramid

% PATHFORMAT = '../data/landing/frame%04d_crop.jpg';
% RESULTPATH = '../results/landing_lk.mp4';
% FRAMESTART = 190;
% FRAMEEND = 308;
% tracker = [387.8313   32.7339  237.8816  224.3883]; % LK
% tracker = [341.3546   37.2316  347.3268  230.3853]; % LK robust
% tracker = [345.8523   29.7354  338.3313  246.8771]; % LK pyramid

prev_frame = imread(sprintf(PATHFORMAT, FRAMESTART));

pickBox = input('use preset tracker(1) or ginput(2)? (enter 1 or 2)\n');
if pickBox == 2
tracker = pickBoundingBox(prev_frame);
end

fprintf('initial tracker:\n');
disp(tracker);

%% Start tracking
% video = VideoWriter(RESULTPATH);
% open(video);

figure;
for i = FRAMESTART+1:FRAMEEND
    path = sprintf(PATHFORMAT, i);
    if ~isfile(path)
        continue
    end
    new_frame = imread(path);
    
    [u, v] = LucasKanade(prev_frame, new_frame, tracker);    

    clf;
    hold on;
    imshow(new_frame);   
    rectangle('Position', tracker, 'EdgeColor', [1 1 0]);
    drawnow;

    prev_frame = new_frame;
    tracker(1) = tracker(1) + u;
    tracker(2) = tracker(2) + v;
    
%     writeVideo(video, getframe(gcf));
end

% close(video);
fprintf('done\n');