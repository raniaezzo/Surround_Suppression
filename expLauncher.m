%% General experimenter launcher %%
%  =============================  %

% Clean up:
sca; Screen('CloseAll'); 
clear functions; clear mex;
close all; clear all; clc;
rng('default');

Screen('Preference', 'TextRenderer', 0);
KbName('UnifyKeyNames')
%PsychDebugWindowConfiguration(0, 0.5);
% Initialization
warning('off');        % do not print warnings
const.DEBUG = 0;       % skips subject details / data saving
const.miniWindow = 0;  % for debugging purposes only
const.makemovie =0;   % capture movie of trial (slows down performance)
const.scale2screen = 0;

% make sure to turn off the scaling if the experiment started:
if const.DEBUG == 0
    const.scale2screen = 0;
end

% Verify that path is correct
if isempty(which('instructions'))
    % Ensure all folders are on path
    addpath(genpath(fullfile(sursuppRootPath, 'ExperimentCode'))); % add folders with experimental code
end

% Main experimental code
main(const);
clear expDes

