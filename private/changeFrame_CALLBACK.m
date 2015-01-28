function changeFrame_CALLBACK(src,evnt,parameters)
%changeFrame_CALLBACK.m Callback to update frame
%
%frameText - handle of text object
%frameSlider - handle of slider
%frameAx - frame axes
%tiffFile - tiff file name
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%get new value 
newFrame = round(get(parameters.frameSlider,'Value'));

%update frametext
set(parameters.frameText,'String',sprintf('Current Frame: %6.0f',newFrame));

if parameters.playing
    
    %increment currMovieInd
    parameters.currMovieInd = parameters.currMovieInd + 1;
    
    %get index for rolling avg
    if mod(parameters.rollAvg,2) == 0 %if iseven
        allInd = parameters.currMovieInd - parameters.rollAvg/2 + 1:...
            parameters.currMovieInd + parameters.rollAvg/2;
    else
        allInd = parameters.currMovieInd - (parameters.rollAvg-1)/2:...
            parameters.currMovieInd + (parameters.rollAvg-1)/2;
    end
    
    %update value of frameSlider
    set(parameters.frameSlider,'Value',parameters.currMovieInd);
    set(parameters.frameText,'String',sprintf('Current Frame: %6.0f',...
        parameters.currMovieInd));
    
    %get tiff which matches that ind
    tiff = mean(parameters.movieFrames(:,:,ismember(parameters.movieInds,...
        allInd)),3);
    
    %load 10 more frames if necessary
    if parameters.currMovieInd >= max(parameters.movieInds)-10
        if parameters.folderMode
            tempTiff = loadTiffPartsAM(parameters.filePath,parameters.fileStr,...
                parameters.currMovieInd+11:parameters.currMovieInd+20);
        else
            tempTiff = loadtiffAM(parameters.ROIFile,...
                parameters.currMovieInd+11:parameters.currMovieInd+20);
        end
        
        parameters.movieFrames = cat(3,parameters.movieFrames(:,:,...
            11:end),tempTiff);
        parameters.movieInds = parameters.currMovieInd+1:parameters.currMovieInd+20;
    end
    
else  
    %get index for rolling avg
    if mod(parameters.rollAvg,2) == 0 %if iseven
        allInd = newFrame - parameters.rollAvg/2 + 1:...
            newFrame + parameters.rollAvg/2;
    else
        allInd = newFrame - (parameters.rollAvg-1)/2:...
            newFrame + (parameters.rollAvg-1)/2;
    end
    
    %load in new tiff
    if parameters.folderMode
        tiff = mean(loadTiffPartsAM(parameters.filePath,parameters.fileStr,allInd),3);
    else
        tiff = mean(loadtiffAM(parameters.ROIFile,allInd),3);
    end
end

if parameters.dispProj
    tiff = parameters.tiffProj;
    %convert to high contrast
    if get(parameters.highContrastButton,'Value')
%             tiff = highContrastTiff(tiff);
        if ~isempty(parameters.tiffProjHighCont{parameters.projNum})
            tiff = parameters.tiffProjHighCont{parameters.projNum};
        else
            tiff = adapthisteq(tiff,'nbins',1e6 );
            parameters.tiffProjHighCont{parameters.projNum} = tiff;
        end
    end
else
    if get(parameters.highContrastButton,'Value')
        tiff = adapthisteq(tiff,'nbins',1e4 );
        
    end
end



%display
cla(parameters.frameAx); %clear
imshow(tiff,[]);
hold on;

%save currFrame
parameters.currFrame = tiff;

%add on cells
if parameters.shouldShowMasks
    nCells = size(parameters.edgeInd,2);
    % colorProfile = jet(nCells);
    % colorProfile = brighten(colorProfile,0.2);

    %get current limits
    % currXLim = get(parameters.frameAx,'xlim');
    % currYLim = get(parameters.frameAx,'ylim');
    for i = 1:nCells

    %     if parameters.centroid(i,1) < currXLim(1) || parameters.centroid(i,1) > currXLim(2) ||...
    %             parameters.centroid(i,2) < currYLim(1) || parameters.centroid(i,2) > currYLim(2)
    %         continue;
    %     end    

        %plot cell
    %     plot(parameters.edgeInd{1,i},parameters.edgeInd{2,i},'Color',colorProfile(i,:));
        plot(parameters.edgeInd{1,i},parameters.edgeInd{2,i},'Color','g');

        %label
        %     text(parameters.centroid(i,1),parameters.centroid(i,2),num2str(i),'Color',...
        %         colorProfile(i,:),'HorizontalAlignment','Center');
        text(parameters.centroid(i,1),parameters.centroid(i,2),num2str(i),'Color',...
            'g','HorizontalAlignment','Center');
    end
end

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);
