function play_CALLBACK(src,evnt,parameters)
%play_CALLBACK.m Plays movie at specified frame rate
%
%INPUTS
%parameters - structure of parameters
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%find out if button depressed
if get(parameters.play,'Value')
    
    %change string
    set(parameters.play,'String','Stop'); %change string to stop
    
    %get framerate
    frameRate = str2double(get(parameters.frameRate,'String'));
    
    %load in first 20 frames
    currFrame = get(parameters.frameSlider,'Value');
    if parameters.folderMode
        parameters.movieFrames = loadTiffPartsAM(parameters.filePath,parameters.fileStr,...
            currFrame:currFrame+19);
    else
        parameters.movieFrames = loadtiffAM(parameters.ROIFile,currFrame:currFrame + 19);
    end
    parameters.movieInds = currFrame:currFrame+19;
    parameters.currMovieInd = currFrame-1;
    
    %create timer
    parameters.playTimer = timer('ExecutionMode','FixedSpacing','Period',...
        1/frameRate,'Name','playTimer');
    set(parameters.playTimer,'TimerFcn',{@changeFrame_CALLBACK,parameters});
    
    %start timer
    start(parameters.playTimer);
    
    %set timer as running
    parameters.playing = true;
    
else
    
    %change string
    set(parameters.play,'String','Play'); %change string to play

    %stop timer
    stop(parameters.playTimer);
    
    %set timer as stopped
    parameters.playing = false;
end

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);
