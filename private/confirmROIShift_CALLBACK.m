function confirmROIShift_CALLBACK(src,evnt,parameters)
%confirmROIShift_CALLBACK.m Function to close shift mode
%
%ASM 11/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%delete shift buttons
delete(parameters.xShiftUp,parameters.xShift,parameters.xShiftDown,...
        parameters.yShift,parameters.yShiftDown,parameters.yShiftUp,...
        parameters.confirmROIShift,parameters.xShiftText,parameters.yShiftText,...
        parameters.rotate,parameters.rotateUp,parameters.rotateDown,...
        parameters.rotateText);
parameters = rmfield(parameters,{'xShiftUp','xShift','xShiftDown','yShift','yShiftUp',...
    'yShiftDown','confirmROIShift','xShiftText','yShiftText','rotate','rotateUp',...
    'rotateDown','rotateText'});

%stop shifting
parameters.shifting = false;

%save to matFile
parameters.matFile.ROIs = parameters.ROIs;
parameters.matFile.edgeInd = parameters.edgeInd;
parameters.matFile.centroid = parameters.centroid;
parameters.matFile.polyPosition = parameters.polyPosition;

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);