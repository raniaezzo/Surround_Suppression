function [const] = dirSaveFile(const)
% ----------------------------------------------------------------------
% [const]=dirSaveFile(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Make directory and saving files.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing a lot of constant configuration
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing a lot of constant configuration
% ----------------------------------------------------------------------

% Subject name:
if const.DEBUG ~= 1
    const.subjID = input(sprintf('\n\tSubject ID (letters/digits): '),'s');
else
    const.subjID = 'XX';
end

% find out which paradigm we are running
filepath = fullfile(sursuppRootPath, 'parameters.tsv');
params = readtable(filepath, "FileType","text",'Delimiter', '\t');
const.expPar = params.expPar{1};

% Subject Directory
MainDirectory = sursuppRootPath;
datadir = fullfile(MainDirectory, 'Data', const.expPar);
const.subjDir = fullfile(datadir,const.subjID);
const.blockLog = fullfile(datadir,const.subjID, 'blocklog.txt');

if ~isfile(const.blockLog)
    mkdir(const.subjDir);
    const.block = 1;
else
    fid = fopen(const.blockLog, 'r');
    blocks = fscanf(fid, '%s');
    blockarray = split(blocks, 'Block');
    const.block = str2num(blockarray{end})+1;
end

% make run directory
const.blockDir = fullfile(const.subjDir, sprintf('Block%i', const.block));
mkdir(const.blockDir);

% Defines saving file names
%const.scr_fileDat =     fullfile(const.blockDir, sprintf('S%s_scr_file_Block%i.dat',const.subjID, const.block));
const.scr_fileMat =     fullfile(const.blockDir, sprintf('S%s_scr_file_Block%i.mat',const.subjID, const.block));
%const.const_fileDat =   fullfile(const.blockDir, sprintf('S%s_const_file_Block%i.dat',const.subjID, const.block));
const.const_fileMat =   fullfile(const.blockDir, sprintf('S%s_const_file_Block%i.mat',const.subjID, const.block));
%const.expRes_fileCsv =  fullfile(const.blockDir, sprintf('S%s_expRes_Block%i.csv',const.subjID, const.block));
const.design_fileMat =  fullfile(const.blockDir, sprintf('S%s_design_Block%i.mat',const.subjID, const.block));
%const.responses_fileMat =  fullfile(const.blockDir, sprintf('S%s_responses_Block%i.mat',const.subjID, const.block));

if const.makemovie
    const.moviefolder = fullfile(const.blockDir, 'trialmovie');
    if ~isfolder(const.moviefolder)
        mkdir(const.moviefolder);
    end
end

end