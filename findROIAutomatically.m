function impolyCoord = findROIAutomatically(img, row, col, radius, roiSizeOffset)
% See anatomicalRoiGui.m for usage notes.

%convert image to double
img = double(img);
%get height and width of image
[height, width] = size(img);

% Extract pixels in polar coordinates from clicked point:
nRays = 300;

% nPoints determines the radius of the captured circle. This should contain
% the entire cell:
nPoints = radius;
theta = linspace(0, 2*pi, nRays);
rho = nPoints:-1:1;
[thetaGrid, rhoGrid] = meshgrid(theta, rho);
[polX, polY] = pol2cart(thetaGrid, rhoGrid);

% Make sure all of the points are within the image bounds:
rowSub = max(min(round(polY(:)+row), height), 1);
colSub = max(min(round(polX(:)+col), width), 1);
i = sub2ind(size(img), rowSub, colSub);
ray = reshape(img(i), nPoints, []);


% Find "inside" of the cell, defined as the area contained within the
% maximum intensity pixel along each ray:
[~, rayMaxI] = max(ray);

% Fit a sinusoidal boundary to delineate the "inside" of the cell:
% offset = median(rayMaxI);
[~, offset] = max(mean(ray-mean(ray(:)), 2));
objFun = @(x) doughnutObjectiveFun(x, offset,ray, nRays, nPoints);
x = fminsearch(objFun, [10, 1]);
boundInd = round(median(rayMaxI) + x(1)*cos(x(2)+linspace(0, 2*pi, nRays)));
maskOutside = bsxfun(@gt, boundInd, (1:nPoints)');

% Get column-wise regional minima:
colMin = reshape(imregionalmin(ray(:), 4), size(ray, 1), []);

% Find pixels that are lower than the SD cutoff:
sdThresh = 1;
imgMean = mean(img(:));
imgSd = std(img(:));
darkPix = (ray-imgMean)/imgSd < sdThresh;

% Combine all these masks to get the boundary: the boundary is constrained
% to be beyond the first maximum, but before either the first dark pixel,
% or the first regional minimum:
mask = maskOutside & (colMin | darkPix);
mask = flipud(cumsum(flipud(mask)))>0;

% Find boundary indices:
% (Summing of the 1's in each column gives the index of where the 1's end.)
boundInd = sum(mask, 1);

% Columns with no boundary are invalid:
boundInd(boundInd==0) = NaN;

% Pad boundInd to avoid boundary effects:
boundInd = [boundInd(round(nRays/2):nRays) boundInd, boundInd(1:round(nRays/2)-1)];

% Iteratively discard "outliers" (diff>median+3*std):
boundIndOld = NaN;
while ~isequaln(boundInd, boundIndOld)
    boundIndOld = boundInd;
    
    % Use difference of neighboring boundary points:
    boundIndDiff = diff(boundInd([end, 1:end]));
    
    % Discard boundary points that are too far from their neighbors:
    boundInd(abs(boundIndDiff)>nanmedian(abs(boundIndDiff))+1*nanstd(abs(boundIndDiff))) = NaN;
    notNan = ~isnan(boundInd);
    x = 1:(nRays*2);
    
    % Interpolate across discarded points:
    boundInd = interp1(x(notNan), boundInd(notNan), x);
end

% Unpad:
boundInd = boundInd(round(nRays/2)+1:round(nRays/2)+nRays);

% Adjust boundary size as per user input:
boundInd = boundInd + roiSizeOffset;

% Exclude pixels that already belong to another ROI:
% % rayOtherRois = flipud(cumsum(flipud(reshape(gui.roiLabels(i), nPoints, []))))~=0;
% boundOtherRois = sum(rayOtherRois);
% boundInd = max(boundInd, boundOtherRois);

% Convert back to image coordinates:
[cartX, cartY] = pol2cart(theta, nPoints-boundInd(1:end));


% Make sure all of the points are within the image bounds:
rowSub = max(min(round(cartY(:)+row), height), 1);
colSub = max(min(round(cartX(:)+col), width), 1);
i = sub2ind(size(img), rowSub, colSub);


%% Draw imPoly to allow the user to adjust the ROI:
% TODO: make the number of vertices variable...
impolyCoord = [round(cartX(1:30:end)+col); round(cartY(1:30:end)+row)]';
% gui.imPoly(end+1) = impoly(gui.hAxMain, [round(cartX(1:30:end)+col); round(cartY(1:30:end)+row)]');

% figure
% imgBound = false(size(img));
% imgBound(i) = 1;

% Fill ROI before downsampling (a one-pixel-boundary might vanish during
% downsampling):
% % roiMask = imfill(imgBound, [row, col], 4);

% Downsample:
% imgRoi = imresize(imgRoi, 1/gui.usFac, 'nearest');
% imagesc(md./imgGaussBlur(md, 1)-1*imgRoi)
% set(gca, 'dataa', [1 1 1]);


% TODO:
% - investigate pixel shift
% - plot all stages along the way to monitor effect of parameters


end

function score = doughnutObjectiveFun(x, offset, ray, nRays, nPoints)

rowSub = round(offset + x(1)*cos(x(2)+linspace(0, 2*pi, nRays)));
rowSub(rowSub<1) = 1;
rowSub(rowSub>nPoints) = nPoints;
ind = sub2ind([nPoints, nRays], rowSub, 1:nRays);
score = -mean(ray(ind));
end