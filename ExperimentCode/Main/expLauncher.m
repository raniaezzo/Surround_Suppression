%% General experimenter launcher %%
%  =============================  %

% Clean up:

sca; Screen('CloseAll'); 
clear functions; clear mex;
close all; clear all; clc;
rng('default');

Screen('Preference', 'TextRenderer', 0);
KbName('UnifyKeyNames')

% Initialization
warning('off');        % do not print warnings
const.DEBUG = 0;       % skips subject details / data saving
const.miniWindow = 0;  % for debugging purposes only

% Try to find correct path:
dir = (which('expLauncher'));  % find main script
cd(fileparts(fileparts(dir))); % go to general experiment directory

% Verify that path is correct
[const.mainDir, ~] = fileparts(pwd);
[~, MainFolder] = fileparts(const.mainDir);
if ~strcmp(MainFolder, 'Surround_Suppression')
    disp('Not in correct directory. Please run code from ExperimentCode directory.')
else
    % Ensure all folders are on path
    addpath(genpath(pwd)); % add folders with experimental code
    
    % Main experimental code
    main(const);
    clear expDes
end
