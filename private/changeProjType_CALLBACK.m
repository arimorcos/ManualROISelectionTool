function changeProjType_CALLBACK(src,evnt,parameters)
%changeProjType_CALLBACK.m changes projection type
%
%INPUTS
%frameAx - axes handle
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%display menu with projection options
options = {'Average','Max','Gaussian'};
selection = menu('Select Projection Type',options);

%set type
parameters.projType = options{selection};
parameters.projNum = selection;

%store parameters
set(parameters.ROIFig,'UserData',parameters);

dispProj_CALLBACK(src,evnt,parameters)

end

