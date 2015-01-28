function createNewROIAutomatic_CALLBACK(src,evnt,parameters)
%createNewROIAutomatic_CALLBACK Gets user input to create new circle and then
%converts into ROI, and appends to ROI array saved in frameAx
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

if parameters.inEditing
    msgbox('Cannot create new ROI while editing.');
    return;
end
if parameters.playing
    msgbox('Cannot create new ROI while playing.');
    return;
end
if parameters.shifting
    msgbox('Cannot create new ROI while shifting.');
    return;
end
if parameters.manuallyCreating
    msgbox('Cannot create new ROI automatically while creating manually.');
    return;
end


parameters.automaticallyCreating = true;

%set frameAx to current axes
axes(parameters.frameAx);

if parameters.currEll
    delete(parameters.hEll);
end

%get cell location
[col,row] = ginput(1);

%find ROI
impolyCoord = findROIAutomatically(parameters.currFrame, row, col, parameters.radius, 0);

%create ellipse with coordinates
hEll = impoly(parameters.frameAx,impolyCoord);
setColor(hEll,'r'); %set to white
% setFixedAspectRatioMode(hEll,true); %constrain to circle
fcn = makeConstrainToRectFcn('impoly',[1 size(parameters.currFrame,2)],...
    [1 size(parameters.currFrame,1)]); %create constraint function keeping it in axes
setPositionConstraintFcn(hEll,fcn); %apply function

%update parameters
parameters.hEll = hEll;
parameters.currEll = true;

%store parameters
set(parameters.ROIFig,'UserData',parameters);
