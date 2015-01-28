function changeShape_CALLBACK(src,evnt,parameters)
%changeShape_CALLBACK.m Changes the roi shape
%
%INPUTS
%parameters - structure of parameters
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%get state of button
buttVal = get(parameters.roiShapeButton,'Value');

%store
if buttVal
    parameters.roiShape = 'freehand';
else
    parameters.roiShape = 'ellipse';
end

%change text
if buttVal
    set(parameters.roiShapeButton,'String','ROI Shape: Polygon');
else
    set(parameters.roiShapeButton,'String','ROI Shape: Ellipse');
end

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);