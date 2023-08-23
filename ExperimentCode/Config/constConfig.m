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

% Initialize displaying of grating (to save time for initial build):

% STIMULUS
const.grating_halfw= const.stimRadiuspix;
const.visiblesize=2*const.grating_halfw+1;

x = meshgrid(-const.grating_halfw:const.grating_halfw + const.stimSF_ppc, 1);
signal=0.5 + 0.5.*cos(const.stimSF_radians*x);
signal = signal.*0.5+0.25; % new
gratingtex = repmat(signal, [length(signal),1]);
gratingmask = create_cosRamp(gratingtex, const.stimCosEdge_pix);
gratingtex(:,:,2) = gratingmask;
const.gratingtex=Screen('MakeTexture', const.window, gratingtex);

% calculate the amount of area of surround exclusing target
const.nonTargetRadiuspix = const.surroundRadiuspix - const.stimRadiuspix;
const.surround2GapRadiusPix = const.nonTargetRadiuspix*(1-const.gapRatio);

% SURROUND
const.surround_halfw= const.surroundRadiuspix;
const.visiblesize_surr=2*const.surround_halfw+1;

x = meshgrid(-const.surround_halfw:const.surround_halfw + const.stimSF_ppc, 1);
signal=0.5 + 0.5.*cos(const.stimSF_radians*x);
signal = signal.*0.5+0.25; % new
surroundtex = repmat(signal, [length(signal),1]);
surroundmask = create_cosRamp(surroundtex, const.stimCosEdge_pix);
surroundmask2 = create_cosRamp2(surroundtex, surroundmask, const.surround2GapRadiusPix, const.stimCosEdge_pix);
surroundtex(:,:,2) = surroundmask2;
const.surroundtex=Screen('MakeTexture', const.window, surroundtex);



%%
% prepare input for stimulus
const.phaseLine = rand(1, expDes.nb_trials) .* 360;


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