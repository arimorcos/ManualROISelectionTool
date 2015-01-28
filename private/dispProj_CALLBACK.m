function dispProj_CALLBACK(src,evnt,parameters)
%dispProj_CALLBACK.m Callback function to display projection
%
%INPUTS
%parameters - parameters structure
%
%ASM 11/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

if parameters.dispProj
    parameters.dispProj = false;
    
    %save updated parameters
    set(parameters.ROIFig,'UserData',parameters);
    
    set(parameters.projection,'String','Show Projection');
    
    %update frame
    changeFrame_CALLBACK(src,evnt,parameters);
    
    return;
end
    

%create projection name string 
if strcmpi(parameters.projType,'Average')
    projString = [fullfile(parameters.filePath,parameters.fileBase),'_avgProj.tif'];
elseif strcmpi(parameters.projType,'Max')
    projString = [fullfile(parameters.filePath,parameters.fileBase),'_maxProj.tif'];
elseif strcmpi(parameters.projType,'Gaussian')
    projString = [fullfile(parameters.filePath,parameters.fileBase),'_gaussProj.tif'];
end


%check if file exists
if exist(projString,'file')
    projExist = true;
else
    projExist = false;
end

%ask user to create projection if doesn't exist
if ~projExist
    questAns = questdlg('Projection does not exist. Create? This will take several minutes.',...
        'No projection exists','Yes','No','Yes');
    switch questAns
        case 'Yes'
            if parameters.folderMode
                tiffProj = createMultiTiffProjection(parameters.filePath,parameters.fileStr,false);
                saveastiff(tiffProj,projString);
            else
                %load in entire tiff
                tiff = loadtiffAM(parameters.ROIFile);
                
                %project tiff (avg)
                tiffProj = sum(tiff,3)/size(tiff,3);
                
                %save projected tiff
                saveastiff(tiffProj,projString);
            end
        case 'No'
            return;
    end
end

%if tiff projection does exist, load
if projExist
    tiffProj = loadtiffAM(projString);
end

%store projection
parameters.tiffProj = tiffProj;
parameters.dispProj = true;
set(parameters.projection,'String','Hide Projection');

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);

%update frame
changeFrame_CALLBACK(src,evnt,parameters);