function [parameters] = checkForROIFile(parameters)
%checkForROIFile.m Checks if previous ROI file exists for tiff and asks if
%should load in old data
%
%INPUTS
%parameters - structure of data
%
%OUTPUTS
%parameters - structure of data
%
%ASM 10/13

%create ROIFilename
if parameters.folderMode
    saveFile = [fullfile(parameters.filePath,parameters.fileBase),'_manualROI.mat'];
else
    [tiffPath,tiffName] = fileparts(parameters.ROIFile); %break up filename
    saveFile = fullfile(tiffPath,[tiffName,'_manualROI.mat']);
end

%check if file exists
fileExists = exist(saveFile,'file');

%return if file doesn't exist
if ~fileExists
    return;
end

%ask user if should load in data
userAns = questdlg('Previous save file found. Do you want to load in old data?',...
    'Old data found','Yes','No','Yes');
if strcmp(userAns,'No')
    userAns2 = questdlg('Do you want to overwrite old data?',...
    'Old data found','Yes','Exit','Exit');
    if strcmp('Yes',userAns2)
        delete(saveFile);
    else
        parameters.exit = true;
    end
    return;
end

%load in data
load(saveFile);

%save in parameters
parameters.ROIs = ROIs;
parameters.centroid = centroid;
parameters.edgeInd = edgeInd;


    