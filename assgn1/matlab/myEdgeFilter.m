function [img1] = myEdgeFilter(img0, sigma)
%Your implemention

%prepare kernels
hGaussian = fspecial('gaussian',2*ceil(3*sigma)+1,sigma);
hSobelX = [1 0 -1; 2 0 -2; 1 0 -1];
hSobelY = [1 2 1; 0 0 0; -1 -2 -1];

%apply smoothing
imgSmooth = myImageFilter(img0, hGaussian);

%apply sobel
imgX = myImageFilter(imgSmooth, hSobelX);
imgY = myImageFilter(imgSmooth, hSobelY);

%compute gradient magnitude and direction
imgGrad = (imgX.^2 + imgY.^2).^(1/2);
imgDir = atand(imgY./imgX);
imgDir(isnan(imgDir)) = 90;

%NMS
img1 = NMS(imgGrad, imgDir);

end
    
                
        
        
