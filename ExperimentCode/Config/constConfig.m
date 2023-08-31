function [const]=constConfig(scr,const,expDes)
% ----------------------------------------------------------------------
% [const]=constConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute all constant data of this experiment.
% ----------------------------------------------------------------------
% Input(s) :
% scr : window pointer
% const : struct containg previous constant configurations.
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing all constant data.
% ----------------------------------------------------------------------

%% Stimulus Properties             

if strcmp(expDes.stimulus, 'grating')
    
    const.stimOri = 90;                                     % 90 deg (vertical orientation)

    % stimulus spatial frequency
    const.stimSF_cpd = 2;                                   % cycle per degree
    const.stimSF_cpp = const.stimSF_cpd/vaDeg2pix(1, scr);  % cycle per pixel
    const.stimSF_radians = const.stimSF_cpp*(2*pi);         % in radians
    const.stimSF_ppc = ceil(1/const.stimSF_cpp);            % pixel per cycle
elseif strcmp(expDes.stimulus, 'perlinNoise')
    % stimulus scalar for noise
    const.scalar4noiseTarget = 0.05; % unitless
end

const.flicker_hz = 4; % in hertz

% fixed surround contrast
const.contrast_surround = 0.8;

%% Define width of the cosine ramp (and check that smaller than stimulus/surround)

% starting value (set this and the code below will decrease if too large)
const.stimCosEdge_deg = 0.3;
const.stimCosEdge_pix = vaDeg2pix(const.stimCosEdge_deg, scr);

% calculate the amount of area of surround exclusing target
const.nonTargetRadiuspix = const.surroundRadiuspix - const.stimRadiuspix;
const.surround2GapRadiusPix = const.nonTargetRadiuspix*(const.gapRatio); % outer boundary of the gap
const.gap_pxfromBoundary = const.surroundRadiuspix*(const.gapRatio);
const.gapWidth = (const.surroundRadiuspix-const.stimRadiuspix)*const.gapRatio;
const.surroundWidth = const.surroundRadiuspix - const.gapWidth - const.stimRadiuspix;

% cosine ramp is applied at the edge of the center stimulus
% and is applied at the two edges of the surround stimulus
% so need to make sure that rampSize > center, and 2*rampSize > surroundwith

if const.stimCosEdge_pix > const.stimRadiuspix
    disp('The soft edges (cosine ramp) exceeds the stimulus radius..')
    disp('Decreasing the width of the ramp to 1/4 stimRadius..')
    const.stimCosEdge_pix = const.stimRadiuspix/4; % just make ramp 1/4 of the target radius
    const.stimCosEdge_deg = pix2vaDeg(const.stimCosEdge_pix, scr);
end
if 2*const.stimCosEdge_pix > const.surroundWidth
    disp('The soft edges (cosine ramp*2) exceeds the surround radius..')
    disp('Decreasing the width of the ramp to 1/(4*2) surround radius..')
    const.stimCosEdge_pix = const.surroundWidth/(4*2); % just make ramp 1/4 of the target radius
    const.stimCosEdge_deg = pix2vaDeg(const.stimCosEdge_pix, scr);
end

%% CENTER GRATING W/ RAMP

% Initialize displaying of grating (to save time for initial build):

% STIMULUS
const.grating_halfw= const.stimRadiuspix;
const.visiblesize=2*floor(const.grating_halfw)+1;

backgroundColor = [.5 .5 .5 0];

% center stimulus 
if strcmp(expDes.stimulus, 'perlinNoise')
    const.squarewavetex = CreateProceduralScaledNoise(const.window, const.visiblesize, const.visiblesize, 'ClassicPerlin', backgroundColor, const.visiblesize/2);
elseif strcmp(expDes.stimulus, 'grating')
    const.squarewavetex = CreateProceduralSineGrating(const.window, const.visiblesize, const.visiblesize, backgroundColor, const.visiblesize/2, 1);
end

% center ramp
distance_fromRadius = 0;
x = meshgrid(-const.grating_halfw:const.grating_halfw + const.stimSF_ppc, 1);
mask = ones(length(x),length(x)).*0.5;
[mask(:,:,2), filterparam] = create_cosRamp(mask, distance_fromRadius, const.stimCosEdge_pix, 1, [], []); % 1 for initialize mask
const.centermask=Screen('MakeTexture', const.window, mask);

%% SURROUND GRATING X/ RAMP

% SURROUND
const.surround_halfw= const.surroundRadiuspix;
const.visiblesize_surr=2*floor(const.surround_halfw)+1;

% surround stimulus 
if strcmp(expDes.stimulus, 'perlinNoise')
    const.surroundwavetex = CreateProceduralScaledNoise(const.window, const.visiblesize_surr, const.visiblesize_surr, 'ClassicPerlin', backgroundColor, const.visiblesize_surr/2);
elseif strcmp(expDes.stimulus, 'grating')
    const.surroundwavetex = CreateProceduralSineGrating(const.window, const.visiblesize_surr, const.visiblesize_surr, backgroundColor, const.visiblesize_surr/2, 1);
end

% initialize gray background mask
distance_fromRadius = 0;
x = meshgrid(-const.surround_halfw:const.surround_halfw + const.stimSF_ppc, 1);
maskSurr = ones(length(x),length(x)).*0.5;

% this is the outer ramp
[surroundmask, ~] = create_cosRamp(maskSurr, distance_fromRadius, const.stimCosEdge_pix, 1, [], []); 
maskSurr(:,:,2) = surroundmask;  

const.surroundmask=Screen('MakeTexture', const.window, maskSurr);

% scalar for surround (this needs to be computed relative to the texture
% size - due to OpenGL code)
const.scalar4noiseSurround = const.scalar4noiseTarget*(const.surroundRadiuspix/const.stimRadiuspix);

%% GAP
% add a solid circle to mask for surround gap
const.gapRadius_px = round(const.stimRadiuspix+(const.gapWidth));

gap = ones(const.visiblesize_surr, const.visiblesize_surr).*0.5;
gap(:,:,2) = createGap(gap, const.stimRadiuspix, const.gapRadius_px, const.stimCosEdge_pix); %const.surroundwavetex
size(gap)
disp(const.stimRadiuspix)
disp(const.gapRadius_px)
const.gapTexture=Screen('MakeTexture', const.window, gap);


%%
% prepare input for stimulus
const.phaseLine = rand(3, expDes.nb_trials) .* 360;

%% PTB orientation/direction conversion
% 
orientationids = 0:45:315; ptborientation = {90, 45, 0, 135, 90, 45, 0, 135};
const.maporientation = containers.Map(orientationids,ptborientation);
 
directionids = 0:45:315; ptbdirection = {180, 135, 90, 45, 0, 315, 270, 225};
const.mapdirection = containers.Map(directionids,ptbdirection);

%% Saving procedure :

const.expStart = 0;

% .mat file
save(const.const_fileMat,'const');


end