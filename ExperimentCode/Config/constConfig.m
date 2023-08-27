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

% stimulus spatial frequency
const.stimSF_cpd = 1;                                   % cycle per degree
const.stimSF_cpp = const.stimSF_cpd/vaDeg2pix(1, scr);  % cycle per pixel
const.stimSF_radians = const.stimSF_cpp*(2*pi);         % in radians
const.stimSF_ppc = ceil(1/const.stimSF_cpp);            % pixel per cycle

% stimulus speed
const.stimSpeed_cpd = 8;                                    % cycles per degree
const.stimSpeed_cps = const.stimSpeed_cpd*const.stimSF_cpd; % cycles per sec
const.stimSpeed_ppc = 1/const.stimSF_cpp;                   % pixel per cycle (without ceil, for precise speed)

const.stimCosEdge_deg = 0.5; %1.5;
const.stimCosEdge_pix = vaDeg2pix(const.stimCosEdge_deg, scr);

% fixed stimulus contrast
const.contrast = .5;
const.contrast_surround = 0.8;

%% CENTER GRATING W/ RAMP

% Initialize displaying of grating (to save time for initial build):

% STIMULUS
const.grating_halfw= const.stimRadiuspix;
const.visiblesize=2*const.grating_halfw+1;

% center grating
const.squarewavetex = CreateProceduralSineGrating(const.window, const.visiblesize, const.visiblesize, [.5 .5 .5  0], const.visiblesize/2, 1);
%const.gratingtex=Screen('DrawTexture', const.window, squarewavetex);

% center ramp
distance_fromRadius = 0;
x = meshgrid(-const.grating_halfw:const.grating_halfw + const.stimSF_ppc, 1);
mask = ones(length(x),length(x)).*0.5;
[mask(:,:,2), filterparam] = create_cosRamp(mask, distance_fromRadius, const.stimCosEdge_pix, 1, [], []); % 1 for initialize mask
const.centermask=Screen('MakeTexture', const.window, mask);

%% SURROUND GRATING X/ RAMP

% calculate the amount of area of surround exclusing target
const.nonTargetRadiuspix = const.surroundRadiuspix - const.stimRadiuspix;
const.surround2GapRadiusPix = const.nonTargetRadiuspix*(const.gapRatio); % outer boundary of the gap
const.gap_pxfromBoundary = const.surroundRadiuspix*(const.gapRatio);

% SURROUND
const.surround_halfw= const.surroundRadiuspix;
const.visiblesize_surr=2*const.surround_halfw+1;

% surround grating
const.surroundwavetex = CreateProceduralSineGrating(const.window, const.visiblesize_surr, const.visiblesize_surr, [.5 .5 .5  0], const.visiblesize_surr/2, 1);

% initialize gray background mask
distance_fromRadius = 0;
x = meshgrid(-const.surround_halfw:const.surround_halfw + const.stimSF_ppc, 1);
maskSurr = ones(length(x),length(x)).*0.5;

% this is the outer ramp
disp('creating outer ramp of surround')
[surroundmask, ~] = create_cosRamp(maskSurr, distance_fromRadius, const.stimCosEdge_pix, 1, [], []); 

% then create the inner target ramp ?????????????????????
% distance_fromRadius = 0; %length(surroundmask)/2-const.stimRadiuspix; %const.nonTargetRadiuspix;
% disp('creating outer ramp of embedded target')
% [surroundmask2, ~] = create_cosRamp(surroundmask, distance_fromRadius, const.stimCosEdge_pix, 0, [], filterparam); % 0 to account for previous mask

% then create the ramp for surround-to-gap
%distance_fromRadius = const.surround2GapRadiusPix; %const.gap_pxfromBoundary; %const.nonTargetRadiuspix; %
%[surroundmask3, ~]  = create_cosRamp(surroundmask2, distance_fromRadius, const.stimCosEdge_pix, 0, 'outer2inner', []); % 0 to account for previous mask

%maskSurr(:,:,2) = surroundmask3;
maskSurr(:,:,2) = surroundmask;  

const.surroundmask=Screen('MakeTexture', const.window, maskSurr);

%% GAP
% add a solid circle to mask for surround gap
const.gapRadius_px = round(const.stimRadiuspix+((const.surroundRadiuspix-const.stimRadiuspix)*const.gapRatio));

gap = ones(length(x),length(x)).*0.5;
gap(:,:,2) = createGap(gap, const.stimRadiuspix, const.gapRadius_px, const.stimCosEdge_pix);
const.gapTexture=Screen('MakeTexture', const.window, gap);

% TO DO
% even if there is no gap (0), still make this the cosine ramp.


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