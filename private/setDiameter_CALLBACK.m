function setDiameter_CALLBACK(src,evnt,parameters)
%setDiameter_CALLBACK Gets user input to create new circle and then
%converts into ROI, and appends to ROI array saved in frameAx
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%draw line
hLine = imline(parameters.frameAx);

%get position
linePos = getPosition(hLine);

%calculate diameter
diameter = calcEuclidianDist(linePos(1,:),linePos(2,:));

%set radius
parameters.radius = round(0.6*diameter);

%delete line
delete(hLine);

%notify user
msgbox(sprintf('Radius is %i',parameters.radius));

%store parameters
set(parameters.ROIFig,'UserData',parameters);
