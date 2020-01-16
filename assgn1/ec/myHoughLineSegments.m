function [lines] = myHoughLineSegments(lineRho, lineTheta, Im)

minLength = 20;
[h, w] = size(Im);

Im = myImageFilter(Im, ones(3));
% sigma = 2;
% Im = myImageFilterX(Im, fspecial('gaussian',2*ceil(3*sigma)+1,sigma));

getY = @(x, theta, rho) round(-x/tan(theta) + rho/sin(theta));
getLength = @(start, stop) sqrt((start(1)-stop(1))^2 + (start(2)-stop(2))^2);
isValidRange = @(x, y) x >= 1 && x <= w && y >= 1 && y <= h;
isValidPixel = @(x, y) isValidRange(x, y) && Im(y, x) > eps;

lines = [];

%check each pair of theta & rho
for i = 1:numel(lineRho)
    
    isDrawing = false;
    currStart = [1 1];
    currStop = [1 1];
    
    for x = 1:w+1
        y = getY(x, lineTheta(i), lineRho(i));
        
        if isDrawing && isValidPixel(x, y) 
            currStop = [x y];
            continue
        end
        if ~isDrawing && ~isValidPixel(x, y) continue, end;
        
        %stop drawing
        if isDrawing && ~isValidPixel(x, y)
            if isValidRange(x, y)
                currStop = [x y];
            end
            %add line segment
            if getLength(currStart, currStop) > minLength
                lineSegment.point1 = currStart;
                lineSegment.point2 = currStop;
                lines = [lines lineSegment];
            end
            isDrawing = false;
        end
        %start drawing
        if ~isDrawing && isValidPixel(x, y)
            currStart = [x y];
            isDrawing = true;
        end
    end
end

end