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

const.stimCosEdge_deg = 1; %1.5;
const.stimCosEdge_pix = vaDeg2pix(const.stimCosEdge_deg, scr);

% fixed stimulus contrast
const.contrast = .5;
const.contrast_surround = 0.8;

% Initialize displaying of grating (to save time for initial build):

% STIMULUS
const.grating_halfw= const.stimRadiuspix;
const.visiblesize=2*const.grating_halfw+1;

% x = meshgrid(-const.grating_halfw:const.grating_halfw + const.stimSF_ppc, 1);
% signal=cos(const.stimSF_radians*x);
% signal = (signal - min(signal)) / ( max(signal) - min(signal) ); % normalize from 0-1
% gratingtex = repmat(signal, [length(signal),1]);
% distance_fromRadius = 0;
% gratingmask = create_cosRamp(gratingtex, distance_fromRadius, const.stimCosEdge_pix);
% gratingtex(:,:,2) = gratingmask;
% const.gratingtex=Screen('MakeTexture', const.window, gratingtex);

%% CENTER GRATING W/ RAMP
% center grating
const.squarewavetex = CreateProceduralSineGrating(const.window, const.visiblesize, const.visiblesize, [.5 .5 .5  0], const.visiblesize/2, 1);
%const.gratingtex=Screen('DrawTexture', const.window, squarewavetex);

% center ramp
distance_fromRadius = 0;
x = meshgrid(-const.grating_halfw:const.grating_halfw + const.stimSF_ppc, 1);
mask = ones(length(x),length(x)).*0.5;
mask(:,:,2) = create_cosRamp(mask, distance_fromRadius, const.stimCosEdge_pix);
const.centermask=Screen('MakeTexture', const.window, mask);


% calculate the amount of area of surround exclusing target
const.nonTargetRadiuspix = const.surroundRadiuspix - const.stimRadiuspix;
const.surround2GapRadiusPix = const.nonTargetRadiuspix*(1-const.gapRatio);

% SURROUND
const.surround_halfw= const.surroundRadiuspix;
const.visiblesize_surr=2*const.surround_halfw+1;

x = meshgrid(-const.surround_halfw:const.surround_halfw + const.stimSF_ppc, 1);
signal=cos(const.stimSF_radians*x);
signal = (signal - min(signal)) / ( max(signal) - min(signal) ); % normalize from 0-1
surroundtex = repmat(signal, [length(signal),1]);
distance_fromRadius = 0;
surroundmask = create_cosRamp(surroundtex, distance_fromRadius, const.stimCosEdge_pix);

distance_fromRadius = const.surround2GapRadiusPix;
surroundmask2 = create_cosRamp(surroundmask, distance_fromRadius, const.stimCosEdge_pix);
surroundtex(:,:,2) = surroundmask2;
const.surroundtex=Screen('MakeTexture', const.window, surroundtex);


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