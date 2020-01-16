function [ locs, desc ] = getFeaturePoints_ec( I, threshold )

if nargin < 2
  threshold = 55;
end

if ndims(I) == 3 I = (rgb2gray(I)); end
locs = fast_corner_detect_9(I, threshold);
[desc, locs] = computeBrief(I, locs);

end

