function showMasks_CALLBACK(src,evnt,parameters)
%showMasks_CALLBACK.m shows or hides masks
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

if parameters.shouldShowMasks %if currently on
    parameters.shouldShowMasks = false;
    set(parameters.showMasks,'String','Show Masks');
else
    parameters.shouldShowMasks = true;
    set(parameters.showMasks,'String','Hide Masks');
end

%store parameters
set(parameters.ROIFig,'UserData',parameters);

changeFrame_CALLBACK(src,evnt,parameters);
end

