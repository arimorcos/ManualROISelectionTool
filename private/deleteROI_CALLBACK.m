function deleteROI_CALLBACK(src,evnt,parameters)
%deleteROI_CALLBACK.m Finds valid handles of ellipses and deletes
%
%ASM 10/13

%get parameters
parameters = get(parameters.ROIFig,'UserData');

%delete
delete(parameters.hEll);

%update currELl
parameters.currEll = false;

%set as no longer editing
parameters.editing = false;
parameters.inEditing = false;
parameters.manuallyCreating = false;
parameters.automaticallyCreating = false;

%reset pointer to arrow
set(parameters.ROIFig,'Pointer','Arrow');

%save updated parameters
set(parameters.ROIFig,'UserData',parameters);
