function rootPath=sursuppRootPath()
% Return the path to the root surround suppression directory
%
% This function must reside in the directory at the base of the surround
% suppression directory structure.  It is used to determine the location of
% various sub-directories.
% 
% Example:
%   fullfile(sursuppRootPath,'Data')

rootPath=which('sursuppRootPath');

rootPath=fileparts(rootPath);

return
