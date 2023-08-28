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
const.lightgray =   [  0.75,   0.75,   0.75 ];

% Time
const.my_clock_ini = clock;
scale2screen = 0;
    
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
const.stimOri = params.stimOri; const.gapRatio = params.gapRatio; 

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
            Screen('Preference', 'SkipSyncTests', 1);
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
const.stimEcc_deg = params.stimEcc; const.stimEccpix = vaDeg2pix(const.stimEcc_deg, scr); 
const.stimRadius_deg = params.stimRadius; const.stimRadiuspix = vaDeg2pix(const.stimRadius_deg, scr); 
const.surroundRadius_deg = params.surroundRadius; const.surroundRadiuspix = vaDeg2pix(const.surroundRadius_deg, scr);
const.gapRatio = params.gapRatio;

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

% check if lawful parameter size relative to screen
if const.surroundRadiuspix >= const.stimEccpix
    disp('Surround radius must NOT exceed stimulus eccentricity.')
    scale2screen = 1;
end
if const.surroundRadiuspix >= scr.windY_px/2
    disp('Surround radius must NOT exceed half the screen height.')
    scale2screen = 1;
end
if const.surroundRadiuspix+const.stimEccpix >= scr.windX_px/2
    disp('Surround radius + eccentricity must NOT exceed the screen width.')
    scale2screen = 1;
end
%

if scale2screen % this is mainly for testing
    disp('Scaling params to fit current window..')
    disp('and setting eccentricity to maximize stimulus range..')
    
    const.stimEccpix = scr.windX_px/4;
    const.stimEcc_deg = pix2vaDeg(const.stimEccpix, scr);
    
    radiusConstraints = [scr.windX_px/2, scr.windY_px/2, const.stimEccpix];
    minConstraint = min(radiusConstraints);
    
    scalingFactor = minConstraint/const.surroundRadiuspix;
    const.surroundRadiuspix = minConstraint;
    const.surroundRadius_deg = pix2vaDeg(const.surroundRadiuspix, scr);
    const.stimRadiuspix = const.stimRadiuspix*scalingFactor;
    const.stimRadius_deg = pix2vaDeg(const.stimRadiuspix, scr);
end

if ~((const.gapRatio >= 0) && (const.gapRatio <= 1))
    disp('Gap ratio must be between 0 and 1..')
    disp('Setting to default value of 0.5')
    const.gapRatio = 0.5;
end


%% Fixation Properties

const.fixationRadius_px = 0.01*scr.windY_px;
const.fixationRadius_deg = pix2vaDeg(const.fixationRadius_px, scr);

%%


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

%% load in gamma table for appropriate contrast
if ~const.DEBUG
    gammaVals = load(const.gammaTablePath);
    const.gammaVals = gammaVals.gamma;
    [~, const.calibSuccess] = Screen('LoadNormalizedGammaTable', const.window, const.gammaVals.*[1 1 1]);
    if const.calibSuccess
        disp('Successfully incorporated the gamma table from the config folder.')
        disp('NOTE: if this gamma table was not re-created for your setup, please replace file.')
    else
        disp('Calibration of screen color/contrast values failed.')
    end
end

%%

% Enable alpha-blending, set it to a blend equation useable for linear
% additive superposition. This allows to linearly
% superimpose gabor patches in the mathematically correct manner, should
% they overlap. Alpha-weighted source means: The 'globalAlpha' parameter in
% the 'DrawTextures' can be used to modulate the intensity of each pixel of
% the drawn patch before it is superimposed to the framebuffer image, ie.,
% it allows to specify a global per-patch contrast value:
%Screen('BlendFunction', const.window, GL_ONE, GL_ONE);
%Screen('BlendFunction', const.window, GL_SRC_ALPHA,
%GL_ONE_MINUS_SRC_ALPHA); % put back

% Set drawing to maximum priority level
topPriorityLevel = MaxPriority(const.window);
Priority(topPriorityLevel);

% save .mat file with screen parameters used
save(const.scr_fileMat,'scr');

end
