function keypress_CALLBACK(src,evnt,parameters,onOff)
%keypress_CALLBACK zooms in/out
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%key identity
if onOff
    switch evnt.Key
        case 'space'
            pan on;
            hManager = uigetmodemanager(parameters.ROIFig);
            set(hManager.WindowListenerHandles,'Enable','off');
            set(parameters.ROIFig,'WindowScrollWheelFcn',{@scrollWheel_CALLBACK,parameters},...
                'KeyPressFcn',{@keypress_CALLBACK,parameters,true},...
                'KeyReleaseFcn',{@keypress_CALLBACK,parameters,false});
        case 'p'
            dispProj_CALLBACK(src,evnt,parameters);
        case 'c'
            set(parameters.highContrastButton,'Value',~get(parameters.highContrastButton,'Value'));
            set(parameters.ROIFig,'UserData',parameters);
            changeFrame_CALLBACK(src,evnt,parameters);
        case 'r'
            zoom out;
        case 'return'
            confirmROI_CALLBACK(src,evnt,parameters);
        case 'a'
            createNewROIAutomatic_CALLBACK(src,evnt,parameters);
        case 'm'
            createNewROI_CALLBACK(src,evnt,parameters);
        case 'delete'
            deleteROI_CALLBACK(src,evnt,parameters);
        case 'e'
            editROI_CALLBACK(src,evnt,parameters);
        case 'uparrow'
            expandROI_CALLBACK(src,evnt,parameters);
        case 'downarrow'
            shrinkROI_CALLBACK(src,evnt,parameters);
        case 'z'
            showMasks_CALLBACK(src,evnt,parameters);
    end
else
    switch evnt.Key
        case 'space'
            pan off;
    end
end

%store parameters
% set(parameters.ROIFig,'UserData',parameters);
end
