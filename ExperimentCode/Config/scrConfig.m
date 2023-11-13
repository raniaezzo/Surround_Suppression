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

% Time
const.my_clock_ini = clock;

% Set default to 0, but is overwritten later to 1 if Stanford PC
const.TRIGGERCHECK = 0;
    
%% Screen
computerDetails = Screen('Computer');  % check computer specs

scr.scr_num = max(Screen('Screens')); % use max screen (typically external monitor)

% Size of the display (mm)
[scrX_mm, scrY_mm] = Screen('DisplaySize',scr.scr_num);
scr.scrX_cm = scrX_mm/10; scr.scrY_cm = scrY_mm/10;

% fix: second time loading in (previously in dirSaveFile)
filepath = fullfile(sursuppRootPath, 'parameters.tsv');
params = readtable(filepath, "FileType","text",'Delimiter', '\t');

scr.scrViewingDist_cm = params.scrDist; % load in viewing distance

% save other params to const struct
const.gapRatio = params.gapRatio; 
const.stimType = params.stimType;

% parse polar angle list from tsv file
polarangles = extractBetween(params.stimPaLocs{1}, '[',']');
polarangles = strsplit(polarangles{1},',');
params.stimPaLocs = arrayfun(@(x) str2double(polarangles{x}),1:length(polarangles));

% these are the polar angles read in from tsv parameter file (1-2 values)
const.paLocTarget = params.stimPaLocs';
const.paLocTarget = sort(const.paLocTarget); % order from least to greatest

% if tsv parameter input is NOT 1-2 values print error:
if ~ (0 < length(const.paLocTarget) && length(const.paLocTarget) <= 2)
    error('Number of stimulus polar angle (stimPaLocs) in parameters.tsv must rangle from 1-2.')
else % otherwise
    % check that all values are valid (between 0 and 360)
    if any(const.paLocTarget<0) || any(const.paLocTarget>=360)
        error('Invalid range of polar angle locations (stimPaLocs. Must be > 0 and < 360.')
    end
    
    % compute the symmetric value relative to the vertical meridian
    if const.paLocTarget(1) < 180
        addedTargetLoc = 90 + (90 - const.paLocTarget(1));
    elseif const.paLocTarget >= 180
        addedTargetLoc = 270 + (270 - const.paLocTarget(1));
        if addedTargetLoc >= 360 % make sure a 360 value is interpretted as 0
            addedTargetLoc = addedTargetLoc - 360;
        end
    end
    
    if length(const.paLocTarget) == 2 % if 2 inputs:
        % these values must be equidistant.
        if const.paLocTarget == addedTargetLoc
            const.paLocs = const.paLocTarget;
        else
            error('If two polar angle values (stimPaLocs) are given in parameters.tsv, they must be the same angular distance from vertical meridian.')
        end
        
    elseif length(const.paLocTarget) == 1 % if 1 input:
        % put add the second value that is mirror symmetric w/ respect to
        % vertical meridian
        const.paLocs = [const.paLocTarget, addedTargetLoc];
    end

    % at this point, check that there is one polar angle location per
    % hemifield
    
     % EXTRA CHECKS BELOW: Not necessary, but keeping in case:
     % log all existing values in each hemifield (LHemi, RHemi)
    rh_PA = const.paLocs(const.paLocs < 90 | const.paLocs > 270);
    lh_PA = const.paLocs(const.paLocs > 90 & const.paLocs < 270);
    
    if isempty(lh_PA) || isempty(rh_PA)
        error('Invalid range of polar angle locations (stimPaLocs. Must be > 0 and < 360.')
    end  
    
    % final check: that paLocs are two values between 0-360
    if length(const.paLocs) ~= 2
        error('Number of stimulus polar angle (stimPaLocs) must be two.')

    end
end

% this warns experimenter that this is the behavioral paradigm that
% typically is run with canonical locations 0 and 180.
if strcmp(const.expPar, 'behavioral')
    if ~ (any(const.paLocs == 0) && any(const.paLocs == 180))
        input('WARNING: Behavioral task but not R/L locations. Press ENTER to continue anyway..', 's');
    end
end

% parse contrast list from tsv file
centerContrasts = extractBetween(params.targetContrast{1}, '[',']');
centerContrasts = strsplit(centerContrasts{1},',');
const.targetContrast = arrayfun(@(x) str2double(centerContrasts{x}),1:length(centerContrasts));

surroundContrasts = extractBetween(params.surroundContrast{1}, '[',']');
surroundContrasts = strsplit(surroundContrasts{1},',');
const.surroundContrast = arrayfun(@(x) str2double(surroundContrasts{x}),1:length(surroundContrasts));

[scr.frameRate] = Screen('FrameRate', scr.scr_num);

% find screen details
if ~computerDetails.windows
    switch computerDetails.localHostName
        case 'Ranias-MacBook-Pro-2'
            scr.experimenter = 'RE';
            const.keyboard = 'Apple Internal Keyboard / Trackpad';
            if scr.scr_num == 1
                scr.scrX_cm = 62; scr.scrY_cm = 34;
            end
            Screen('Preference', 'SkipSyncTests', 1);
        otherwise
            scr.experimenter = 'Unknown';
    end
else    % PC (field names are different)
    switch computerDetails.system
        case 'NT-11.0.9200 - '
            scr.experimenter = 'StanfordPC';
            const.TRIGGERCHECK = 1;
        otherwise
            scr.experimenter = 'Unknown';
    end
end

% try to detect framerate: if not, set to a default and print warning..
if ~scr.frameRate
    disp('PTB could not detect framerate. Setting default to 60 hz.')
    scr.frameRate = 60;
end
scr.frame_duration =1/scr.frameRate; 

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
    [~] = Screen('Preference', 'SkipSyncTests', 1); % skip timing checks for debugging
end

% CHECK DIMENSIONS PRIOR TO EXPERIMENT:

[xCheck,yCheck] = pol2cart(deg2rad(const.paLocs(1)),const.stimEccpix);

% CHECK IF LAWFUL PARAMETERS OF STIMULI (SURROUND SHOULD NEVER CROSS
% VERTICAL MERIDIAN) - this is the one check that is automatically fixed if
% not met. It is attempted to be fixed by placing stimuli diagonally opposite to one
% another.

% check if stimulus crosses vertical meridian
if const.surroundRadiuspix >= abs(xCheck) % if surround radius (px) is larger than horizontal distance from center
    if length(const.paLocTarget) == 1
        disp('Stimuli are too close to the vertical meridian, changing to diagonal configuration.')
        % ensure the two pa Locs are 180 degrees apart: 
        %if max(const.paLocs) - min(const.paLocs) ~= 180
        %     error('Polar angle positions (stimPaLocs) must be 180 degrees apart.')
        % end
        addedTarget = const.paLocTarget + 180;
        if addedTarget >= 360
            addedTarget = addedTarget - 360;
        end
        
        const.paLocs = [const.paLocTarget, addedTarget];
        const.configVerticalAsymmetry = 0; % if not vertical, assume diagonal
        
    else
        error('Stimuli are too close to the vertical meridian to use default mirror symmetry. Code can attempt a fix if you input only one value only in the parameters tsv file.')
    end
else
    const.configVerticalAsymmetry = 1; % stimuli are symmetrically displayed relative to vertical meridian
end

% these are the finalized polar angles
const.paLocs = sort(const.paLocs); % order from least to greatest
const.paIdx1 = const.paLocs(1); const.paIdx2 = const.paLocs(2);

% CHECK IF LAWFUL PARAMETERS RELATIVE TO SCREEN

% this ensures the surround will not go past the fixation point
if const.surroundRadiuspix >= const.stimEccpix && ~const.scale2screen
    error('Surround radius must NOT exceed stimulus eccentricity.')
    %const.scale2screen = 1;
end

% this ensures the surround will not be cut off
if const.surroundRadiuspix >= scr.windY_px/2 && ~const.scale2screen
    error('Surround radius must NOT exceed half the screen height.')
    %const.scale2screen = 1;
end

% check x and y distances (based on target eccentricity) + surround do not
% exceed screen
if const.surroundRadiuspix+xCheck >= scr.windX_px/2 && ~const.scale2screen
    error('Surround radius + xDist must NOT exceed the screen width. Adjust stim size or eccentricity.')
elseif const.surroundRadiuspix+yCheck >= scr.windY_px/2 && ~const.scale2screen
    error('Surround radius + yDist must NOT exceed the screen width. Adjust stim size or eccentricity.')
end
%

if const.scale2screen % this is mainly for testing
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
if strcmp(const.expPar, 'behavioral')
    const.fixationRadius_px = 0.01*scr.windY_px;
elseif strcmp(const.expPar, 'neural')
    const.fixationRadius_px = 0.005*scr.windY_px;
end
const.fixationRadius_deg = pix2vaDeg(const.fixationRadius_px, scr);

%%


%PsychDefaultSetup(2); % assert OpenGL, setup unifiedkeys and unit color range
%PsychImaging('PrepareConfiguration'); % First step in starting pipeline
%PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

ListenChar(1);                        % Listen for keyboard input

% open a grey window (size defined above)
[const.window, const.windowRect] = PsychImaging('OpenWindow', scr.scr_num, [.5 .5 .5], scr_dim, [], [], [], [], []);

% need to add this to put back the gradient (see if it works for ekin)
Screen('ColorRange', const.window, 1, [], 1);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(const.windowRect);
scr.windCenter_px = [xCenter, yCenter];

% Flip to clear
scr.vbl = Screen('Flip', const.window);

% Query the frame duration
scr.ifi = Screen('GetFlipInterval', const.window);

%% load in gamma table for appropriate contrast

% this saves path, the values are loaded in later (in scrConfig)
MainDirectory = sursuppRootPath;
if strcmp(scr.experimenter, 'StanfordPC')
    const.gammaTablePath = fullfile(MainDirectory, 'ExperimentCode', 'Config', 'gammaStanford_20231109T091813.mat');
else
    disp('YOUR COMPUTER IS USING AN EXAMPLE GAMMA TABLE.')
    disp('AFTER CALIBRATING MONITOR, ADD gamma.mat PATH TO dirSaveFile.m')
    const.gammaTablePath = fullfile(MainDirectory, 'ExperimentCode', 'Config', 'gammaExample.mat');
end

const.CALIBRATE_MONITOR = 1;
if const.CALIBRATE_MONITOR
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

% read in color values after calibration
const.white = WhiteIndex(scr.scr_num);
const.black = BlackIndex(scr.scr_num);
const.gray  = GrayIndex(scr.scr_num);
const.lightgray =   WhiteIndex(scr.scr_num) * 0.75;

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
