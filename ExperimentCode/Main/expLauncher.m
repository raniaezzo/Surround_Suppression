%% General experimenter launcher %%
%  =============================  %
% before you run the experiment, make sure to input the directory to the
% experiment and Psychtoolbox in the parameters.tsv files first and second
% columns! 
params = readtable('parameters.tsv', "FileType","text",'Delimiter', '\t');
addpath(genpath(params.path2project{1}))
addpath(genpath(params.path2ptb{1}))

% Clean up:
sca; Screen('CloseAll'); 
clear functions; clear mex;
close all; clear all; clc;
rng('default');

Screen('Preference', 'TextRenderer', 0);
KbName('UnifyKeyNames')

% Initialization
warning('off');        % do not print warnings
const.DEBUG = 1;       % skips subject details / data saving
const.miniWindow = 0;  % for debugging purposes only
const.makemovie =0;   % capture movie of trial (slows down performance)

% Verify that path is correct
if isempty(which('instructions'))
    % Ensure all folders are on path
    addpath(genpath(fullfile(sursuppRootPath, 'ExperimentCode'))); % add folders with experimental code
end
        
% Main experimental code
main(const);
clear expDes

