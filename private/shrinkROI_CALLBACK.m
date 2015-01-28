function shrinkROI_CALLBACK(src,evnt,parameters)
%shrinkROI_CALLBACK shrinks current ROI by a nPixels
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%return if no currEl
if ~parameters.currEll || parameters.expanding || parameters.shrinking
    return;
end

parameters.shrinking = true;
%store parameters
set(parameters.ROIFig,'UserData',parameters);

%number of pixels to change by 
nPixels = 10;

%get current position
currPos = getPosition(parameters.hEll);

% %get properties
% props = regionprops(poly2mask(currPos(:,1),currPos(:,2),size(parameters.currFrame,1),...
%     size(parameters.currFrame,1)),'Centroid','Perimeter','Area');
% center = props.Centroid;
% 
% %get target area
% newArea = props.Area - nPixels;
% 
% currArea = props.Area;
% tempRow = currPos(:,1);
% tempCol = currPos(:,2);
% incSize = 0.1;
% while abs(currArea-newArea) >= 4
%     oldRow = tempRow;
%     oldCol = tempCol;
%     tempRow(tempRow <= center(1)) = tempRow(tempRow <= center(1)) + incSize;
%     tempCol(tempCol <= center(2)) = tempCol(tempCol <= center(2)) + incSize;
%     tempRow(tempRow >= center(1)) = tempRow(tempRow >= center(1)) - incSize;
%     tempCol(tempCol >= center(2)) = tempCol(tempCol >= center(2)) - incSize;
%     
%     %calculate new area
%     props = regionprops(poly2mask(tempRow,tempCol,size(parameters.currFrame,1),...
%         size(parameters.currFrame,1)),'Area');
%     currArea = props.Area;
%     if (currArea - newArea) < -4 %if more than 4 off
%         tempRow = oldRow;
%         tempCol = oldCol;
%         incSize = incSize/2;
%     end        
% end
    
% newPos = cat(2,tempRow,tempCol);
newPos = resizePolygon(currPos,-0.5);

%set new position
setPosition(parameters.hEll,newPos);

parameters.shrinking = false;

%store parameters
set(parameters.ROIFig,'UserData',parameters);
end

function pos = resizePolygon(pos, offs)
meanPos = mean(pos);
pos = bsxfun(@minus, pos, meanPos);
[theta, rho] = cart2pol(pos(:,1), pos(:,2));
[pos(:,1), pos(:,2)] = pol2cart(theta, rho+offs);
pos = bsxfun(@plus, pos, meanPos);
end
