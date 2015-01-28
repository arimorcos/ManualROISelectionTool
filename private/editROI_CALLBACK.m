function editROI_CALLBACK(src,evnt,parameters)
%editROI_CALLBACK Allows the editing of a previously obtained ROI
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%if no ROIs return
if isempty(parameters.ROIs)
    return;
end

%get location of mask
[x,y] = ginput(1);

%calculate distance to each centroid
nCells = size(parameters.centroid,1);
distances = zeros(1,nCells);
for i = 1:nCells %for each centroid
    distances(i) = calcEuclidianDist([x y], parameters.centroid(i,:));
end

%get minimum distance
[minDist,cellInd] = min(distances);

%if greater than 0.05*width, return
if minDist > size(parameters.ROIs,1)
    return;
end

%save
parameters.ellInd = cellInd;
parameters.editing = true;
parameters.editPosition = parameters.polyPosition{cellInd};

%get new array area
newInd = setdiff(1:nCells,cellInd);

%delete points in parameters
parameters.centroid = parameters.centroid(newInd,:);
parameters.ROIs = parameters.ROIs(:,:,newInd);
parameters.edgeInd = parameters.edgeInd(:,newInd);
parameters.polyPosition(cellInd) = [];

%delete points in matFile
if nCells > 2
    parameters.matFile.ROIs = parameters.ROIs;
    parameters.matFile.edgeInd = parameters.edgeInd;
    parameters.matFile.centroid = parameters.centroid;
    parameters.matFile.polyPosition = parameters.polyPosition;
end

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);

%update frame
changeFrame_CALLBACK(src,evnt,parameters);

%create new ROI
createNewROI_CALLBACK(src,evnt,parameters);