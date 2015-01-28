function changeFrameRate_CALLBACK(src,evnt,parameters)
%changeFrameRate_CALLBACK.m Changes the framerate of video playback
%
%INPUTS
%parameters - structure of parameters
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%find out if timer is running
if ~parameters.playing
    return;
end

%get frameRate
frameRate = str2double(get(parameters.frameRate,'String'));

%if timer is running, change framerate
stop(parameters.playTimer);
set(parameters.playTimer,'Period',1/frameRate);
start(parameters.playTimer);

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);
