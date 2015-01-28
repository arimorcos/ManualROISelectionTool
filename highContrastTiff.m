function hcTiff = highContrastTiff(tiff,nSideSeg)
%highContrastTiff.m Divides tiff into a 10 x 10 grid and adjusts contrast
%independently in each grid 
%
%INPUTS
%tiff - tiff to adjust contrast of
%nSideSeg - number of segments on a side
%
%OUTPUTS
%hcTiff - high contrast tiff
%
%ASM 5/14

%nSeg on each side
if nargin < 2 || isempty(nSideSeg)
    nSideSeg = 5;
end

%get size of tiff
[height,width] = size(tiff);

%convert to gray
tiff = mat2gray(tiff);

%calculate segment start and stops
heightRanges = round(linspace(1,height,nSideSeg+1));
widthRanges = round(linspace(1,width,nSideSeg+1));

%initialize hcTiff
hcTiff = zeros(size(tiff));

%loop through each segment
for heightInd = 1:nSideSeg
    for widthInd = 1:nSideSeg
        
        %get tiff subset
        tiffSub = tiff(heightRanges(heightInd):heightRanges(heightInd+1),...
            widthRanges(widthInd):widthRanges(widthInd+1));
        
        %equalize
        tiffSub = histeq(tiffSub);
        
        %store
        hcTiff(heightRanges(heightInd):heightRanges(heightInd+1),...
            widthRanges(widthInd):widthRanges(widthInd+1)) = tiffSub;
        
    end
end
        
        