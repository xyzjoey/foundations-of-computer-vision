% function [feature] = HOG(img)
% 
% img = double(img);
% [rows, cols, ~] = size(img);
% 
% Ix=img;
% Iy=img;
% Ix(:,1:end-2) = img(:,1:end-2) - img(:,3:end);
% Iy(1:end-2,:) = img(1:end-2,:) - img(3:end, :);
% 
% angles = atand(Ix./Iy) + 90; % atan --> [-90, 90], +90 --> [0, 180]
% angles(isnan(angles))=0;
% magnitudes = sqrt(Ix.^2 + Iy.^2);
% magnitudes(isnan(magnitudes))=0;
% 
% dir1 = floor((angles+10)/20) + 1; % [1, 10]
% weights1 = ((dir1*20-10) - angles).*magnitudes/20;
% weights2 = (20 - weights1).*magnitudes/20;
% dir1 = uint8(dir1);
% dir1(dir1==10) = 1; % [1, 9]
% dir2 = mod(dir1+7, 9) + 1; % 1 2 3 4 ...9 ==> 9 1 2 3... 8
% 
% blockXNum = floor(cols/8) - 1;
% blockYNum = floor(rows/8) - 1;
% 
% feature = zeros(blockXNum*blockYNum, 9*4);
% % iter each block
% for block = 1:blockXNum*blockYNum
%     [i, j] = ind2sub([blockYNum blockXNum], block);
%         
%     blockFeature = zeros(1, 9*4);
%     for cell = 1:4
%         [y, x] = ind2sub([2 2], cell);
%         cellY = 8*(i+y-2)+1;
%         cellX = 8*(j+x-2)+1;
% 
%         dir1Cell = dir1(cellY:cellY+7,cellX:cellX+7);
%         dir2Cell = dir2(cellY:cellY+7,cellX:cellX+7);
%         weights1Cell = weights1(cellY:cellY+7,cellX:cellX+7);
%         weights2Cell = weights2(cellY:cellY+7,cellX:cellX+7);
% 
%         hist = zeros(1,9);
%         for p = 1:length(dir1Cell)
%             hist(dir1Cell(p)) = hist(dir1Cell(p)) + weights1Cell(p);
%             hist(dir2Cell(p)) = hist(dir2Cell(p)) + weights2Cell(p);
%         end
% 
%         blockFeature(1, 9*(cell-1)+1:9*cell) = hist;
%     end
%     blockFeature=blockFeature/sqrt(norm(blockFeature)^2+.01);
%     feature(block,:) = blockFeature;
% end
% 
% feature=feature/sqrt(norm(feature)^2+.001);
% for z=1:length(feature)
%     if feature(z)>0.2
%          feature(z)=0.2;
%     end
% end
% feature=feature/sqrt(norm(feature)^2+.001); 
% 
% end

function [feature] = HOG(im)
% The given code finds the HOG feature vector for any given image. HOG
% feature vector/descriptor can then be used for detection of any
% particular object. The Matlab code provides the exact implementation of
% the formation of HOG feature vector as detailed in the paper "Pedestrian
% detection using HOG" by Dalal and Triggs
% INPUT => im (input image)
% OUTPUT => HOG feature vector for that particular image
% Example: Running the code
% >>> im = imread('cameraman.tif');
% >>> hog = hog_feature_vector (im);

im=double(im);
rows=size(im,1);
cols=size(im,2);

Ix=im; %Basic Matrix assignment
Iy=im; %Basic Matrix assignment
Ix(:,1:end-2) = im(:,1:end-2) - im(:,3:end);
Iy(1:end-2,:) = im(1:end-2,:) - im(3:end, :);

angle=atand(Ix./Iy) + 90; % Matrix containing the angles of each edge gradient
magnitude=sqrt(Ix.^2 + Iy.^2);
angle(isnan(angle))=0;
magnitude(isnan(magnitude))=0;

blockXNum = floor(cols/8) - 1;
blockYNum = floor(rows/8) - 1;

feature = zeros(blockXNum*blockYNum, 9*4);
% iter each block
for block = 1:blockXNum*blockYNum
    [i, j] = ind2sub([blockYNum blockXNum], block);
    i = i-1;
    j = j-1;
        
        mag_patch = magnitude(8*i+1 : 8*i+16 , 8*j+1 : 8*j+16);
        %mag_patch = imfilter(mag_patch,gauss);
        ang_patch = angle(8*i+1 : 8*i+16 , 8*j+1 : 8*j+16);
        
        block_feature=[];
        
        %Iterations for cells in a block
        for x= 0:1
            for y= 0:1
                angleA =ang_patch(8*x+1:8*x+8, 8*y+1:8*y+8);
                magA   =mag_patch(8*x+1:8*x+8, 8*y+1:8*y+8); 
                histr  =zeros(1,9);
                
                %Iterations for pixels in one cell
                for p=1:8
                    for q=1:8
%                       
                        alpha= angleA(p,q);
                        
                        % Binning Process (Bi-Linear Interpolation)
                        if alpha>10 && alpha<=30
                            histr(1)=histr(1)+ magA(p,q)*(30-alpha)/20;
                            histr(2)=histr(2)+ magA(p,q)*(alpha-10)/20;
                        elseif alpha>30 && alpha<=50
                            histr(2)=histr(2)+ magA(p,q)*(50-alpha)/20;                 
                            histr(3)=histr(3)+ magA(p,q)*(alpha-30)/20;
                        elseif alpha>50 && alpha<=70
                            histr(3)=histr(3)+ magA(p,q)*(70-alpha)/20;
                            histr(4)=histr(4)+ magA(p,q)*(alpha-50)/20;
                        elseif alpha>70 && alpha<=90
                            histr(4)=histr(4)+ magA(p,q)*(90-alpha)/20;
                            histr(5)=histr(5)+ magA(p,q)*(alpha-70)/20;
                        elseif alpha>90 && alpha<=110
                            histr(5)=histr(5)+ magA(p,q)*(110-alpha)/20;
                            histr(6)=histr(6)+ magA(p,q)*(alpha-90)/20;
                        elseif alpha>110 && alpha<=130
                            histr(6)=histr(6)+ magA(p,q)*(130-alpha)/20;
                            histr(7)=histr(7)+ magA(p,q)*(alpha-110)/20;
                        elseif alpha>130 && alpha<=150
                            histr(7)=histr(7)+ magA(p,q)*(150-alpha)/20;
                            histr(8)=histr(8)+ magA(p,q)*(alpha-130)/20;
                        elseif alpha>150 && alpha<=170
                            histr(8)=histr(8)+ magA(p,q)*(170-alpha)/20;
                            histr(9)=histr(9)+ magA(p,q)*(alpha-150)/20;
                        elseif alpha>=0 && alpha<=10
                            histr(1)=histr(1)+ magA(p,q)*(alpha+10)/20;
                            histr(9)=histr(9)+ magA(p,q)*(10-alpha)/20;
                        elseif alpha>170 && alpha<=180
                            histr(9)=histr(9)+ magA(p,q)*(190-alpha)/20;
                            histr(1)=histr(1)+ magA(p,q)*(alpha-170)/20;
                        end
                        
                
                    end
                end
                block_feature=[block_feature histr]; % Concatenation of Four histograms to form one block feature
                                
            end
        end
        % Normalize the values in the block using L1-Norm
        block_feature=block_feature/(norm(block_feature)+eps);
               
    feature(block,:) = block_feature;
end
feature(isnan(feature))=0; %Removing Infinitiy values
% Normalization of the feature vector using L2-Norm
feature=feature/(norm(feature)+eps);
for z=1:length(feature)
    if feature(z)>0.2
         feature(z)=0.2;
    end
end
feature=feature/(norm(feature)+eps);        
% toc;