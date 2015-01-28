function mouseClick_CALLBACK(src,evnt,parameters)
%mouseClick_CALLBACK callback for mouse click
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

% if parameters.currEll %if currently editing
%     confirmROI_CALLBACK(src,evnt,parameters);
% end
    
%store parameters
% set(parameters.ROIFig,'UserData',parameters);
end
