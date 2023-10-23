function [expDes]=designConfig(scr,const)
% ----------------------------------------------------------------------
% [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Load trial sequence matrix containing condition labels
% used in the experiment.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing all constant configurations.
% ----------------------------------------------------------------------
% Output(s):
% expDes : struct containg all trial sequence data.
% ----------------------------------------------------------------------

% save random number generator / seed for each run
expDes.rng = rng(const.block);

%% Experimental sequence

expDes.nb_repeat = 2; % number of unique repeats (for a contrast at a location)

expDes.locations = const.paLocs; 

% grating or perlinNoise
if strcmp(const.stimType, 'noise')
    expDes.stimulus = 'perlinNoise';
elseif strcmp(const.stimType, 'grating')
    expDes.stimulus = 'grating';
end

expDes.contrasts = const.targetContrast';
%const.contrast = .5; % what to do with this?

expDes.mainStimTypes = [];
for i=1:numel(expDes.locations)
    tmp = [expDes.contrasts, ones(length(expDes.contrasts),1)*expDes.locations(i)];
    expDes.mainStimTypes = [expDes.mainStimTypes; tmp];
end

trialsequenceMAT = repmat(expDes.mainStimTypes, expDes.nb_repeat, 1);
trialsequenceMAT = trialsequenceMAT(randperm(length(trialsequenceMAT)), :);

[expDes.nb_trials, ~] = size(trialsequenceMAT);

expDes.mainStimTypes = array2table(expDes.mainStimTypes,'VariableNames',{'targetContrasts', 'horizontalLoc'});

% Experimental matrix
trialIDs = 1:expDes.nb_trials;
expDes.trialMat = [trialIDs', trialsequenceMAT];

% starting contrasts per trial (for matching stimulus)
expDes.startingContrasts = rand(1,expDes.nb_trials);

%% Experiental timing settings

expDes.stimDur_s  = 1;   % 0.5 sec stimulus duration
expDes.itiDur_s  = 2;      % 2 inter-trial interval (fixation)
%expDes.total_s = (expDes.nb_trials*(expDes.stimDur_s+expDes.itiDur_s));

%expDes.stimDur_nFrames  =     round(expDes.stimDur_s/scr.ifi); % # frames
%expDes.itiDur_nFrames  =      round(expDes.itiDur_s/scr.ifi); % # frames

%expDes.totalframes = expDes.stimDur_nFrames*expDes.nb_trials+ ...
%    expDes.itiDur_nFrames*expDes.nb_trials;
 
%expDes.TrialsStart_frame = 1;
%expDes.TrialsEnd_frame = expDes.totalframes;

%% Saving procedure

save(const.design_fileMat,'expDes');

end
