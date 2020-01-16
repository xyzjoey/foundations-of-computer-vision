function [filterResponses] = extractFilterResponses(I, filterBank)

[h, w, channelNum] = size(I);
if channelNum == 1
    I = repmat(I, [1 1 3]);
end
I = RGB2Lab(I);

n = size(filterBank, 1);

filterResponses = zeros(h, w, 3*n);

for channelInd = 1:3%
    for filterInd = 1:n
        i = (channelInd - 1)*n + filterInd;
        filter = filterBank{filterInd};
        filterResponses(:,:,i) = mat2gray(conv2(I(:,:,channelInd), filter, 'same'));
       
%         %display
%         if channelInd == 3 && mod(filterInd-1, 5) == 2
%             figure,
%             imshow(filterResponses(:,:,i)) 
%         end
    end
end

end