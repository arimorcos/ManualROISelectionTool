function shiftROIButtons_CALLBACK(src,evnt,parameters)
%shiftROIButtons_CALLBACK.m Callback function for shift ROI buttons
%
%INPUTS
%parameters - parameters structure
%
%ASM 11/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%update shift text boxes if necessary
switch src
    case parameters.xShiftUp
        currVal = str2double(get(parameters.xShift,'String'));
        set(parameters.xShift,'String',num2str(currVal + 1));
    case parameters.xShiftDown
        currVal = str2double(get(parameters.xShift,'String'));
        set(parameters.xShift,'String',num2str(currVal - 1));
    case parameters.yShiftUp
        currVal = str2double(get(parameters.yShift,'String'));
        set(parameters.yShift,'String',num2str(currVal + 1));
    case parameters.yShiftDown
        currVal = str2double(get(parameters.yShift,'String'));
        set(parameters.yShift,'String',num2str(currVal - 1));
    case parameters.rotateUp
        currVal = str2double(get(parameters.rotate,'String'));
        set(parameters.rotate,'String',num2str(currVal + 1));
    case parameters.rotateDown
        currVal = str2double(get(parameters.rotate,'String'));
        set(parameters.rotate,'String',num2str(currVal - 1));
end

%get values to perform shift
xShift = str2double(get(parameters.xShift,'String'));
yShift = str2double(get(parameters.yShift,'String'));
rotation = str2double(get(parameters.rotate,'String'));

%round x and yshift
xShift = round(xShift);
yShift = round(yShift);
set(parameters.yShift,'String',num2str(yShift));
set(parameters.xShift,'String',num2str(xShift));

%get old data
newROIs = parameters.oldROIs;
newEdgeInds = parameters.oldEdgeInd;
newCentroids = parameters.oldCentroid;

%shift ROIs
newROIs = circshift(newROIs,[yShift xShift 0]);
if xShift > 0 
    newROIs(:,1:xShift,:) = 0;
elseif xShift < 0 
    newROIs(:,1:end+xShift,:) = 0;
end
if yShift > 0
    newROIs(1:yShift,:,:) = 0;
elseif yShift < 0
    newROIs(end+yShift:end,:,:) = 0;
end

%rotate ROIs
newROIs = imrotate(newROIs,-rotation,'nearest','crop');

%get centroids and edgeInd
includeInds = []; %initialize
for i = 1:size(newROIs,3) %for each ROI
    
    %check if ROI has vanished
    if sum(sum(newROIs(:,:,i))) > 0
        includeInds = [includeInds i]; %#ok<AGROW>
    else
        continue;
    end
    
    %get new edge inds
    [newEdgeInds{1,i}, newEdgeInds{2,i}] = findEdges(newROIs(:,:,i)); %get new edge inds
    
    %get new centroids
    properties = regionprops(newROIs(:,:,i),'Centroid');
    newCentroids(i,:) = properties.Centroid;
end

%exclude any vanished ROIs
newROIs = newROIs(:,:,includeInds);
newCentroids = newCentroids(includeInds,:);
newEdgeInds = newEdgeInds(:,includeInds);

%save parameters
parameters.ROIs = newROIs;
parameters.edgeInd = newEdgeInds;
parameters.centroid = newCentroids;

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);

%update frame
changeFrame_CALLBACK(src,evnt,parameters);