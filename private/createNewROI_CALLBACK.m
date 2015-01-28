function createNewROI_CALLBACK(src,evnt,parameters)
%createNewROI_CALLBACK Gets user input to create new circle and then
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
if parameters.automaticallyCreating
    msgbox('Cannot create new ROI manually while creating automatically.');
    return;
end

parameters.manuallyCreating = true;

%set frameAx to current axes
axes(parameters.frameAx);

if parameters.currEll
    delete(parameters.hEll);
end

% switch parameters.roiShape
%     case 'ellipse'
%         %create ellipse object and modify properties
%         %contstrain position if editing
%         if parameters.editing
%             hEll = imellipse(parameters.frameAx,parameters.editPosition);
%             parameters.editing = false;
%             parameters.inEditing = true;
%         else
%             hEll = imellipse(parameters.frameAx);
%         end
%         
%         setColor(hEll,'w'); %set to white
%         % setFixedAspectRatioMode(hEll,true); %constrain to circle
%         fcn = makeConstrainToRectFcn('imellipse',get(parameters.frameAx,'XLim'),...
%             get(parameters.frameAx,'YLim')); %create constraint function keeping it in axes
%         setPositionConstraintFcn(hEll,fcn); %apply function
%     case 'freehand'
        %create ellipse object and modify properties
        %contstrain position if editing
        if parameters.editing
            hEll = impoly(parameters.frameAx,parameters.editPosition);
            parameters.editing = false;
            parameters.inEditing = true;
        else
            hEll = impoly(parameters.frameAx);
        end
        
        setColor(hEll,'r'); %set to white
        % setFixedAspectRatioMode(hEll,true); %constrain to circle
        fcn = makeConstrainToRectFcn('impoly',get(parameters.frameAx,'XLim'),...
            get(parameters.frameAx,'YLim')); %create constraint function keeping it in axes
        setPositionConstraintFcn(hEll,fcn); %apply function
% end



%update parameters
parameters.hEll = hEll;
parameters.currEll = true;

%store parameters
set(parameters.ROIFig,'UserData',parameters);
