function scrollWheel_CALLBACK(src,evnt,parameters)
%scrollWheel_CALLBACK zooms in/out
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

if ~parameters.currEll

    %get sign of scroll
    zoom on;
    currentLoc = get(gca,'CurrentPoint');
    if evnt.VerticalScrollCount == -1 %if down, zoom out
        zoom(1.25);
        %get new axes dimensions
    %     currXLim = get(gca,'Xlim');
    %     currYLim = get(gca,'Ylim');
    %     newXLim = currXLim + mean(currXLim) - currentLoc(1,2);
    %     newYLim = currYLim + mean(currYLim) - currentLoc(1,1);
    % %     if any(newXLim < 0)
    % %         newXLim = newXLim + -1*min(newXLim);
    % %     end
    % %     if any(newYLim < 0)
    % %         newYLim = newYLim + -1*min(newYLim);
    % %     end
    % %     if any(newXLim > size(parameters.currFrame,2))
    % %         newXLim = newXLim - max(newXLim);
    % %     end
    % %     if any(newYLim > size(parameters.currFrame,1))
    % %         newYLim = newYLim - max(newYLim);
    % %     end
    %     newXLim = min(newXLim,size(parameters.currFrame,2));
    %     newYLim = min(newYLim,size(parameters.currFrame,1));
    %     newXLim = max(newXLim,0);
    %     newYLim = max(newYLim,0);
    %     if abs(diff(newXLim)) > 50 && abs(diff(newYLim)) > 50
    %         xlim(newXLim);
    %         ylim(newYLim);
    %     end
    elseif evnt.VerticalScrollCount == 1
        zoom(0.75);
    end
    zoom off;
else
    if evnt.VerticalScrollCount == 1
        shrinkROI_CALLBACK(src,evnt,parameters);
    elseif evnt.VerticalScrollCount == -1
        expandROI_CALLBACK(src,evnt,parameters);
    end
end



%store parameters
set(parameters.ROIFig,'UserData',parameters);
end
