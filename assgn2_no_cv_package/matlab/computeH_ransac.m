function [ bestH2to1, inliers] = computeH_ransac( locs1, locs2)
%COMPUTEH_RANSAC A method to compute the best fitting homography given a
%list of matching points.
%Q2.2.3

N = size(locs1, 1);
minN = 4;
iter = 50;
minDist = 5;

inlierIndsBest = cell(1);

for i = 1:iter
	randInds = randperm(N,minN);
	H = computeH_norm(locs1(randInds, :),locs2(randInds, :));

    locs1New = ([locs2 ones(N, 1)]*H.');
    locs1New = locs1New(:, 1:2)./repmat(locs1New(:, 3), 1, 2);
    dist = eucliDist(locs1New-locs1);

	inlierInds = find(dist < minDist);
    
    if length(inlierInds) > length(inlierIndsBest{1})
        inlierIndsBest{1} = inlierInds;
    end
end

inlierInds = inlierIndsBest{1};
inliers = zeros(1, N);
inliers(inlierInds) = 1;
bestH2to1 = computeH_norm(locs1(inlierInds, :),locs2(inlierInds, :));

end
