function manuallySelectROIs(folderMode,ROIFile,fileStr)
%manuallySelectROIs.m Launches a gui to manually select ROIs for dF/F
%extraction
%
%INPUTS
%ROIFile - file to manually select ROIs from. If empty, asks for file
%
%
%ASM 10/13

%initialize parameters
parameters.ROIs = [];
parameters.edgeInd = {};
parameters.centroid = [];
parameters.currEll = false;
parameters.editing = false;
parameters.inEditing = false;
parameters.exit = false;
parameters.playing = false;
parameters.shifting = false;
parameters.dispProj = false;
parameters.rollAvg = 3;
parameters.polyPosition = {};
parameters.radius = 10;
parameters.manuallyCreating = false;
parameters.automaticallyCreating = false;
parameters.expanding = false;
parameters.shrinking = false;
parameters.shouldShowMasks = true;
parameters.projType = 'Average';
parameters.tiffProjHighCont = cell(1,3);
parameters.projNum = 1;


%ask for file if not provided
if nargin < 1 || isempty(folderMode)
    parameters.folderMode = true;
else
    parameters.folderMode = folderMode;
end
if nargin < 2 || isempty(ROIFile) %if filename not given
    baseDir = 'W:\ResScan\'; %set base directory
    if ~isdir(baseDir)
        baseDir = 'C:\';
    end
    origDir = cd(baseDir); %change to base directory
    if parameters.folderMode
        parameters.filePath = uigetdir(baseDir,'Select Folder');
        parameters.fileStr = inputdlg('Enter file filter string','File Filter String',1);
        slashLoc = strfind(fileStr,'\');
        deleteChar = [min(slashLoc)-1 slashLoc slashLoc + 1];
        fileBase = fileStr;
        fileBase(deleteChar) = [];
        [~,fileBase]=fileparts(fileBase); %remove .tif
    else
        [fileName,parameters.filePath] = uigetfile({'*.tif';'*manualROI*.mat'}); %get file from user
        if fileName == 0 %if no file selected
            return;
        end
        fileBase = fileName(1:regexp(fileName,'.tif')-1);
        parameters.ROIFile = fullfile(parameters.filePath,fileName);
    end
    cd(origDir); %change back to original directory
else
    if parameters.folderMode
        parameters.filePath = ROIFile;
        parameters.fileStr = fileStr;        
        fileList = getMatchingFileList(ROIFile,fileStr);
        fileBase = fileList{1};
        [~,fileBase]=fileparts(fileBase); %remove .tif
        digitStart = regexp(fileBase,'(?<=\w\w\d\d\d_.*)\d\d\d_');
        parameters.fileBase = fileBase([1:digitStart-1 digitStart + 4:end]);
        fileName = [parameters.fileBase,'.tif'];
    else
        parameters.ROIFile = ROIFile;
        [parameters.filePath,fileName,ext] = fileparts(ROIFile); %break up full file
        fileBase = fileName;
        fileName = [fileName,ext]; %add on extension
        parameters.fileBase = fileBase;
    end
end

%check for file
[parameters] = checkForROIFile(parameters);
if parameters.exit
    return
end

%create figure for navigating
parameters.ROIFig = figure('Name',sprintf('Select ROIs for file %s',fileName),...
    'MenuBar','none','Toolbar','figure');

%create menu with zoom
% parameters.menu = uimenu(parameters.ROIFig,

%maximize figure
maxfig(parameters.ROIFig,1);

%create axes
parameters.frameAx = axes;
axis(parameters.frameAx,'square');

%get nFrames
if parameters.folderMode
    parameters.nFrames = getNPagesMultiFile(parameters.filePath,parameters.fileStr);
else
    parameters.nFrames = getNPages(parameters.ROIFile);
end
currFrame = round(0.5*parameters.nFrames);

%add in uicontrol slider
parameters.frameText = uicontrol('Style','Text','Units','Normalized','Position',...
    [0.9 0.05 0.05 0.05],'String',sprintf('Current Frame: %d',currFrame));
parameters.frameSlider = uicontrol('Style','Slider','Min',1,'Max',...
    parameters.nFrames,'Value',currFrame,'Units','Normalized',...
    'Position',[0.2 0.05 0.65 0.05]);
set(parameters.frameSlider,'Callback',{@changeFrame_CALLBACK,parameters},...
    'SliderStep',[1/parameters.nFrames 1000/parameters.nFrames]);

%add create new ROI button
parameters.createNewAutomatic = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.75 0.805 0.1 0.095],'String','Create New ROI Automatically');
set(parameters.createNewAutomatic,'Callback',{@createNewROIAutomatic_CALLBACK,parameters});
parameters.createNew = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.75 0.705 0.1 0.095],'String','Create New ROI Manually');
set(parameters.createNew,'Callback',{@createNewROI_CALLBACK,parameters});

%add set radius button
parameters.setDiameter = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.86 0.805 0.1 0.095],'String','Set Diameter');
set(parameters.setDiameter,'Callback',{@setDiameter_CALLBACK,parameters});

%add shrink/expand buttons
parameters.shrinkROI = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.86 0.705 0.1 0.095],'String','Shrink ROI');
set(parameters.shrinkROI,'Callback',{@shrinkROI_CALLBACK,parameters});
parameters.expandROI = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.86 0.605 0.1 0.095],'String','Expand ROI');
set(parameters.expandROI,'Callback',{@expandROI_CALLBACK,parameters});

%add show masks button
parameters.showMasks = uicontrol('Style','pushButton','Units','Normalized','Position',...
    [0.86 0.505 0.1 0.095],'String','Hide Masks');
set(parameters.showMasks,'Callback',{@showMasks_CALLBACK,parameters});

%add projection type button
parameters.projTypeButton = uicontrol('Style','pushbutton','Units','Normalized','Position',...
    [0.86 0.405 0.1 0.095],'String','Projection Type');
set(parameters.projTypeButton,'Callback',{@changeProjType_CALLBACK,parameters});

%add confirm ROI button
parameters.confirmROI = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.75 0.605 0.1 0.095],'String','Confirm New ROI','Callback',...
    {@confirmROI_CALLBACK,parameters});

%add edit ROI button
parameters.editROI = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.75 0.505 0.1 0.095],'String','Edit ROI','Callback',...
    {@editROI_CALLBACK,parameters});

%add delete ROI button
parameters.deleteROI = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.75 0.405 0.1 0.095],'String','Delete Current ROI','CALLBACK',...
    {@deleteROI_CALLBACK,parameters});

%add shape type
% parameters.roiShapeButton = uicontrol('Style','togglebutton','Units','Normalized','Position',...
%     [0.75 0.705 0.1 0.095],'String','ROI Shape: Ellipse','Value',0,'CALLBACK',...
%     {@changeShape_CALLBACK,parameters});

%add play button
parameters.play = uicontrol('Style','togglebutton','Units','Normalized','Position',...
    [0.06 0.05 0.05 0.05],'String','Play','CALLBACK',...
    {@play_CALLBACK,parameters});
parameters.frameRate = uicontrol('Style','edit','Units','Normalized','Position',...
    [0.12 0.05 0.03 0.05],'String','10','Callback',{@changeFrameRate_CALLBACK,...
    parameters});
uicontrol('Style','Text','Units','Normalized','Position',...
    [0.12 0.11 0.03 0.02],'String','Frame Rate');
parameters.rollingAvg = uicontrol('Style','edit','Units','Normalized','Position',...
    [0.16 0.05 0.03 0.05],'String','3','Callback',{@changeRollAvg_CALLBACK,...
    parameters});
uicontrol('Style','Text','Units','Normalized','Position',...
    [0.16 0.11 0.03 0.02],'String','Rolling Avg');

%add import button
parameters.import = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.1 0.605 0.1 0.095],'String','Import ROIs','CALLBACK',...
    {@importROI_CALLBACK,parameters});

%add shift button
parameters.shift = uicontrol('Style','PushButton','Units','Normalized','Position',...
    [0.1 0.505 0.1 0.095],'String','Shift ROIs','CALLBACK',...
    {@shiftROIs_CALLBACK,parameters});

%add projection button
parameters.projection = uicontrol('Style','PushButton','Units','Normalized',...
    'Position',[0.75 0.305 0.1 0.095],'String','Show Projection','CALLBACK',...
    {@dispProj_CALLBACK,parameters});

%add contrast button
parameters.highContrastButton = uicontrol('Style','ToggleButton','Units','Normalized',...
    'Position',[0.75 0.205 0.1 0.095],'String','High Contrast','CALLBACK',...
    {@changeFrame_CALLBACK,parameters},'Value',0);

%create matFile for saving
parameters.matFile = matfile(fullfile(parameters.filePath,[parameters.fileBase,'_manualROI.mat']),...
    'Writable',true);

%set scroll wheel callback
set(parameters.ROIFig,'WindowScrollWheelFcn',{@scrollWheel_CALLBACK,parameters},...
    'KeyPressFcn',{@keypress_CALLBACK,parameters,true},...
    'KeyReleaseFcn',{@keypress_CALLBACK,parameters,false},...
    'WindowButtonDownFcn',{@mouseClick_CALLBACK,parameters});

%get data if it exists

%store parameters
set(parameters.ROIFig,'UserData',parameters);

%plot current frame
changeFrame_CALLBACK([],[],parameters);

% %create axis
% ROIAx = axes;
% axis(ROIAx,'square');



