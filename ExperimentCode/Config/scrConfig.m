function [scr, const]=scrConfig(const)
% ----------------------------------------------------------------------
% [scr]=scrConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Give all information about the screen and the monitor.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing initial constant params.
% ----------------------------------------------------------------------
% Output(s):
% scr : struct containing all screen configuration.
% const strcut containing some additional params
% ----------------------------------------------------------------------

%% General

% Instructions
const.text_size = 20;
const.text_font = 'Helvetica';

% Color Configuration :
const.white =    [ 1,  1,  1];
const.gray =    [ .5,  .5,  .5];
const.black =   [  0,   0,   0];

% Time
const.my_clock_ini = clock;

%% Screen
computerDetails = Screen('Computer');  % check computer specs

scr.scr_num = max(Screen('Screens')); % use max screen (typically external monitor)

% Size of the display (mm)
[scrX_mm, scrY_mm] = Screen('DisplaySize',scr.scr_num);
scr.scrX_cm = scrX_mm/10; scr.scrY_cm = scrY_mm/10;

filepath = fullfile(const.mainDir, 'parameters.tsv');
params = readtable(filepath, "FileType","text",'Delimiter', '\t');

scr.scrViewingDist_cm = params.scrDist; % load in viewing distance

% save other params to const struct
const.stimOri = params.stimOri; const.surrGap = params.surrGap; 

% parse contrast list from tsv file
contrasts = extractBetween(params.targetContrast{1}, '[',']');
contrasts = strsplit(contrasts{1},',');
const.targetContrast = arrayfun(@(x) str2double(contrasts{x}),1:length(contrasts));

% find screen details
if ~computerDetails.windows
    switch computerDetails.localHostName
        case 'Ranias-MacBook-Pro-2'
            scr.experimenter = 'RE';
            const.keyboard = 'Apple Internal Keyboard / Trackpad';
        otherwise
            scr.experimenter = 'Unknown';
    end
else    % PC (field names are different)
    scr.experimenter = 'Unknown';
end

if strcmp(scr.experimenter, 'Unknown') % default
    disp('Defaulting to first keyboard detected. This might work :)') 
    disp('If not, you can specify it by opening scrConfig.m and setting const.keyboard')
    disp('variable to the name of your keyboard. To print out connected keyboards:')
    disp('In MATLAB: [~, productNames, ~] = GetKeyboardIndices')
    const.keyboard = ''; % <-- add name here if needed
end

% Resolution of the display (pixels):
resolution = Screen('Resolution',scr.scr_num);
scr.scrX_px = resolution.width;
scr.scrY_px = resolution.height;
scr.scrPixelDepth_bpp = resolution.pixelSize; % bits per pixel

[scr.windX_px, scr.windY_px]=Screen('WindowSize', scr.scr_num);

% load in eccentricity values and convert to pixels
const.stimEcc = params.stimEcc; const.stimEccpix = vaDeg2pix(const.stimEcc, scr); 

if const.miniWindow == 1 || const.DEBUG == 1
    %PsychDebugWindowConfiguration(0, 0.5)
    % Window resolution (pixel): [small window]
    scr.windX_px = scr.windX_px/2;
    scr.windY_px = scr.windY_px/2;
    scr_dim = [0, 0, scr.windX_px, scr.windY_px];
    [~] = Screen('Preference', 'SkipSyncTests', 1); % skip timing checks for debugging
else
    % Window resolution is Screen resolution: [fullscreen]
    scr.windX_px = scr.windX_px;
    scr.windY_px = scr.windY_px;
    scr_dim = []; % PTB says better precision when empty
end

PsychDefaultSetup(2); % assert OpenGL, setup unifiedkeys and unit color range
PsychImaging('PrepareConfiguration'); % First step in starting pipeline
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
ListenChar(1);                        % Listen for keyboard input

% open a grey window (size defined above)
[const.window, const.windowRect] = PsychImaging('OpenWindow', scr.scr_num, ...
    [.5 .5 .5], scr_dim, [], [], [], [], []);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(const.windowRect);
scr.windCenter_px = [xCenter, yCenter];

% Flip to clear
scr.vbl = Screen('Flip', const.window);

% Query the frame duration
scr.ifi = Screen('GetFlipInterval', const.window);

% Enable alpha-blending, set it to a blend equation useable for linear
% additive superposition. This allows to linearly
% superimpose gabor patches in the mathematically correct manner, should
% they overlap. Alpha-weighted source means: The 'globalAlpha' parameter in
% the 'DrawTextures' can be used to modulate the intensity of each pixel of
% the drawn patch before it is superimposed to the framebuffer image, ie.,
% it allows to specify a global per-patch contrast value:
%Screen('BlendFunction', const.window, GL_ONE, GL_ONE);
Screen('BlendFunction', const.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Set drawing to maximum priority level
topPriorityLevel = MaxPriority(const.window);
Priority(topPriorityLevel);

% save .mat file with screen parameters used
save(const.scr_fileMat,'scr');

end
