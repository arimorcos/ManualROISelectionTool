function importROI_CALLBACK(src,evnt,parameters)
%importROI_CALLBACK.m Function to import ROIs from another file
%
%INPUTS
%parameters - parameters structure
%
%ASM 11/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%get file from which import
origDir = cd(parameters.filePath);
[fileName,filePath] = uigetfile('*manualROI*.mat','Please select file to import');
cd(origDir);

%ask user whether parameters should be added or replaced
overwriteAns = questdlg('Do you want to overwrite current ROIs or add ROIs?',...
    'Overwrite ROIs?','Overwrite','Add','Cancel','Overwrite');

%decode answers
switch overwriteAns
    case 'Overwrite'
        shouldOverwrite = true;
    case 'Add'
        shouldOverwrite = false;
    case 'Cancel'
        return;
    otherwise
        return;
end

%load in file
load(fullfile(filePath,fileName));

%save parameters
if shouldOverwrite
    parameters.matFile.ROIs = ROIs;
    parameters.matFile.edgeInd = edgeInd;
    parameters.matFile.centroid = centroid;
    parameters.matFile.polyPosition = polyPosition;
    parameters.ROIs = ROIs;
    parameters.edgeInd = edgeInd;
    parameters.centroid = centroid;
    parameters.polyPosition = polyPosition;
else
    parameters.matFile.ROIs = cat(3,parameters.ROIs,ROIs);
    parameters.matFile.edgeInd = cat(2,parameters.edgeInd,edgeInd);
    parameters.matFile.centroid = cat(1,parameters.centroid,centroid);
    parameters.matFile.polyPosition = cat(2,parameters.polyPosition,polyPosition);
    parameters.ROIs = cat(3,parameters.ROIs,ROIs);
    parameters.edgeInd = cat(2,parameters.edgeInd,edgeInd);
    parameters.centroid = cat(1,parameters.centroid,centroid);   
    parameters.polyPosition = cat(2,parameters.polyPosition,polyPosition);
end

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);

%update frame
changeFrame_CALLBACK(src,evnt,parameters);