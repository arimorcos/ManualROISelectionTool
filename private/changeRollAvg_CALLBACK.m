function changeRollAvg_CALLBACK(src,evnt,parameters)
%changeRollAvg_CALLBACK.m Changes the rolling avg of video playback
%
%INPUTS
%parameters - structure of parameters
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%get new avg
newAvg = str2double(get(parameters.rollingAvg,'String'));

%store
parameters.rollAvg = newAvg;

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);

%update frame
changeFrame_CALLBACK(src,evnt,parameters);