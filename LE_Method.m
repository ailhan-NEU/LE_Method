clear;
clear all;
clc;

% Read the image (should be 2D grayscale)
img = imread('C:\Users\Ahmet\Desktop\LE_Method\brain.png');
        
% Average filter
filteredImg = averagefilter(img,[5 5]);
                     
if sum(filteredImg(:)) > 0

	% Convert image from uint8 to double
	doubleImg = im2double(filteredImg);

	% Frequency of the pixels
	hst = uint16(imhist(doubleImg(doubleImg > 0)));
     
	% Calculate the average of frequencies
	mnHist = round(mean2(hst(hst > 0)));

	% Find the most frequent region
	newHist = hst > mnHist;
                    
	stats = regionprops(newHist,'Area');
	maxObj = max([stats.Area]);
    
	if isempty(maxObj)
        
        newHist = hst > 0;
        reg = uint8(newHist);
                
    else
                
        reg = uint8(bwareaopen(newHist,maxObj));
                
    end

	% Find the limits of the most frequent region
	regVals = find(reg == 1);
	minVal = min(regVals(:))/255;
	maxVal = max(regVals(:))/255;

	% Determine background and roi pixels
	background = doubleImg((doubleImg > minVal)&(doubleImg < maxVal));
	roi = doubleImg(doubleImg > maxVal);
 
	% Calculate standard deviation for each class
	stdBack = std2(background);
	stdRoi = std2(roi);
 
	% Image enhancement
	if stdBack < stdRoi
    
        for m = 1:size(doubleImg,1)
            for n = 1:size(doubleImg,2)
                if doubleImg(m,n) <= maxVal
                    doubleImg(m,n) = 0;   
                elseif doubleImg(m,n) > maxVal
                    doubleImg(m,n) = (doubleImg(m,n) - maxVal)/stdRoi;
                end
            end
        end
            
    else
    
        maxVal = mean2(doubleImg(doubleImg > minVal));
        stdRoi = std2(doubleImg(doubleImg > minVal));
        for m = 1:size(doubleImg,1)
            for n = 1:size(doubleImg,2)
                if doubleImg(m,n) <= maxVal
                    doubleImg(m,n) = 0;
                elseif doubleImg(m,n) > maxVal
                    doubleImg(m,n) = (doubleImg(m,n) - maxVal)/stdRoi;
                end
            end
        end
        
    end
        
	% Convert image from double to uint8
	enhancedImg = uint8(255*mat2gray(doubleImg));
        
	% Final image
	finalImg = filteredImg + enhancedImg;
    
    figure,imshow(finalImg)
                    
else
                
    fprintf("Error !!")
    fprintf("\n\n")
    fprintf("The method could not be applied !!")
    fprintf("\n\n")
            
end




