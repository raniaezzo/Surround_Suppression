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

% stimulus size:
stimSize = round(scr.windY_px/10);
const.stimRadius_xpix = stimSize; % constrain X by Y
const.stimRadius_ypix = stimSize;
const.stimRadius_deg =  pix2vaDeg(const.stimRadius_xpix,scr);

% 
const.stimCosEdge_deg = 1; %1.5;
const.stimCosEdge_pix = vaDeg2pix(const.stimCosEdge_deg, scr);

% stimulus location
const.stimCenterEcc_deg = const.stimEcc;

% fixed stimulus contrast
const.contrast = .5;

% Initialize displaying of grating (to save time for initial build):
const.grating_halfw= stimSize;
const.visiblesize=2*const.grating_halfw+1;

%gratingtex=ones(2*(const.grating_halfw) +const.stimSF_ppc+1, ...
%    2*(const.grating_halfw) +const.stimSF_ppc+1, 2) * 0.5;
x = meshgrid(-const.grating_halfw:const.grating_halfw + const.stimSF_ppc, 1);
signal=0.5 + 0.5.*cos(const.stimSF_radians*x);
signal = signal.*0.5+0.25; % new
gratingtex = repmat(signal, [length(signal),1]);
gratingmask = create_cosRamp(gratingtex, const.stimCosEdge_pix);
gratingtex(:,:,2) = gratingmask;
%gratingtex(:,:,1) = grating;
%gratingtex(:,:,2) = grating.*const.contrast;
const.gratingtex=Screen('MakeTexture', const.window, gratingtex);


%%
% prepare input for stimulus
const.phaseLine = rand(1, expDes.nb_trials) .* 360;
% const.aspectRatio = 1;
% const.gaussianSigma = 0;

%% Fixation Properties

%const.fixationRadius_deg = 0.1;
%const.fixationRadius_px = vaDeg2pix(const.fixationRadius_deg,scr);
const.fixationRadius_px = 0.03*const.stimRadius_ypix;
const.fixationRadius_deg = pix2vaDeg(const.fixationRadius_px, scr);

const.expStart = 0;

%% PTB orientation/direction conversion
% 
orientationids = 0:45:315; ptborientation = {90, 45, 0, 135, 90, 45, 0, 135};
const.maporientation = containers.Map(orientationids,ptborientation);
 
directionids = 0:45:315; ptbdirection = {180, 135, 90, 45, 0, 315, 270, 225};
const.mapdirection = containers.Map(directionids,ptbdirection);

%% Saving procedure :

% .mat file
save(const.const_fileMat,'const');

%%

function mask = create_cosRamp(gratingtex, rampSize)
    [~,imsize] = size(gratingtex);
    %filterparam = stimSize;
    %imsize = filterparam*2+1;
    filterparam = (imsize-1) / 2;

    [xN, yN] = meshgrid(-imsize/2+0.5:imsize/2-0.5, -imsize/2+0.5:imsize/2-0.5);
    [~, r] = cart2pol(xN,yN);

    mask = zeros(imsize,imsize);

    inner_radius = filterparam - rampSize;
    outer_radius = filterparam;

    cosX = linspace(-pi, 0, 1001);
    cosY = (cos(cosX)+1)/2;
    aa = r - inner_radius;
    test = aa(aa < outer_radius-inner_radius);
    test = test(test > inner_radius-inner_radius);
    maxR = max(test); minR = min(test);

    for ii = 1:imsize
        for jj = 1:imsize
            if r(ii,jj) < inner_radius
                mask(ii,jj) = 0;
            elseif r(ii,jj) < outer_radius
                dist = r(ii,jj)-inner_radius;
                pick = (dist - minR) / (maxR - minR) *1000;
                choose = round(pick);
                mask(ii,jj) = cosY(choose+1);
                %alpha(ii,jj) = (1-cosd(r(ii,jj)-inner_radius))/2;
            else
                mask(ii,jj) = 1;
            end
        end
    end
    
    mask = 1-mask;
    
end


end