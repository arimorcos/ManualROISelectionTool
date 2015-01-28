function confirmROI_CALLBACK(src,evnt,parameters)
%confirmROI_CALLBACK Callback which confirms ROI and adds into ROI array
%stored in frameAx
%
%INPUTS
%ROIFig - handle of ROIFig
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%return if no currEl
if ~parameters.currEll
    return;
end

%create mask of current ellipse
mask = logical(createMask(parameters.hEll));

%convert to logical
if ~islogical(parameters.ROIs)
    parameters.ROIs = logical(parameters.ROIs);
end

%get nCurrCells
nCurrCells = size(parameters.ROIs,3);
if isempty(parameters.ROIs);nCurrCells = 0; end;

%add to ROIs
parameters.ROIs = cat(3,parameters.ROIs,mask);

%remove overlapping regions
parameters.ROIs = removeOverlappingRegions(parameters.ROIs);

%create contour and add to ROI Outlines
nEdges = size(parameters.edgeInd,2);
[parameters.edgeInd{1,nEdges+1},parameters.edgeInd{2,nEdges+1}] =...
    findEdges(mask);

%get centroid
properties = regionprops(mask,'Centroid');
parameters.centroid = cat(1,parameters.centroid,properties.Centroid);

%get polyPosition
parameters.polyPosition{nCurrCells+1} = getPosition(parameters.hEll);

%save to matFile
if nCurrCells < 2
    parameters.matFile.ROIs = parameters.ROIs;
    parameters.matFile.edgeInd = parameters.edgeInd;
    parameters.matFile.centroid = parameters.centroid;
    parameters.matFile.polyPosition = parameters.polyPosition;
else
    parameters.matFile.ROIs(:,:,nCurrCells+1) = logical(mask);
    parameters.matFile.edgeInd = parameters.edgeInd;
    parameters.matFile.centroid(nCurrCells+1,:) = properties.Centroid;
    parameters.matFile.polyPosition = parameters.polyPosition;
end


    
%delete hEll
delete(parameters.hEll);

%update currEll
parameters.currEll = false;
parameters.inEditing = false;
parameters.automaticallyCreating = false;
parameters.manuallyCreating = false;

%reset pointer to arrow
set(parameters.ROIFig,'Pointer','Arrow');

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);

%update frame
changeFrame_CALLBACK(src,evnt,parameters);