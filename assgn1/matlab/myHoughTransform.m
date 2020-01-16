function [H, rhoScale, thetaScale] = myHoughTransform(Im, threshold, rhoRes, thetaRes)
%Your implementation here

[h, w] = size(Im);

%prepare matrices
rhoScale = 0:rhoRes:ceil(sqrt(w^2 + h^2));
thetaScale = 0:thetaRes:2*pi - thetaRes;
H = zeros(numel(rhoScale), numel(thetaScale));

thetaInds = 1:numel(thetaScale);

cosTheta = cos(thetaScale);
sinTheta = sin(thetaScale);

%compute rho & accumulate
for y=1:h
    for x=1:w
        if Im(y, x) < threshold continue, end
        
        rhos = x*cosTheta + y*sinTheta;
        rhos = interp1(rhoScale, rhoScale, rhos, 'nearest');
        
        rhoInds = rhos/rhoRes + 1;
        HInds = rmmissing((thetaInds - 1)*numel(rhoScale) + rhoInds);

        H(HInds) = H(HInds) + Im(y, x);
    end
end

end
        
        