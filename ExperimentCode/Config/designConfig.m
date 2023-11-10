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

expDes.nb_repeat = 10; % number of unique repeats (for a contrast at a location)

expDes.locations = const.paLocs;

% grating or perlinNoise
if strcmp(const.stimType, 'noise')
    expDes.stimulus = 'perlinNoise';
elseif strcmp(const.stimType, 'grating')
    expDes.stimulus = 'grating';
end

expDes.center_contrasts = const.targetContrast';
expDes.surround_contrasts = const.surroundContrast';
%const.contrast = .5; % what to do with this?

expDes.mainStimTypes = [];
for j = 1:length(expDes.surround_contrasts)
    for i=1:numel(expDes.locations)
        tmp = [expDes.center_contrasts, ones(length(expDes.center_contrasts),1)*expDes.locations(i), ones(length(expDes.center_contrasts),1)*expDes.surround_contrasts(j)];
        expDes.mainStimTypes = [expDes.mainStimTypes; tmp];
    end
end

trialsequenceMAT = repmat(expDes.mainStimTypes, expDes.nb_repeat, 1);
trialsequenceMAT = trialsequenceMAT(randperm(length(trialsequenceMAT)), :);

[expDes.nb_trials, ~] = size(trialsequenceMAT);

expDes.mainStimTypes = array2table(expDes.mainStimTypes,'VariableNames',{'targetContrasts', 'horizontalLoc', 'surroundContrasts'});

%letter fixation task params:


% Experimental matrix
trialIDs = 1:expDes.nb_trials;
expDes.trialMat = [trialIDs', trialsequenceMAT];

% starting contrasts per trial (for matching stimulus)
% make the contrasts different (for adjustment)
if strcmp(const.expPar, 'behavioral')
    expDes.startingContrasts = rand(1,expDes.nb_trials);
% make the contrasts between the two stimuli the same (no adjustment/discrimination)
elseif strcmp(const.expPar, 'neural') 
    expDes.startingContrasts = expDes.trialMat(:,2)';
end


%% Experiental timing settings

expDes.stimDur_s  = 0.5;   % 0.5 sec stimulus duration % based on Hermes et al., 2014
expDes.itiDur_s  = 2;      % 2 inter-trial interval (fixation)
expDes.exp_dur = (expDes.nb_trials*(expDes.stimDur_s+expDes.itiDur_s)); % in seconds
expDes.NumBlocks = 5;
expDes.ApprxTrialperBlock = round(expDes.nb_trials/expDes.NumBlocks);
expDes.block_dur = (expDes.ApprxTrialperBlock*(expDes.stimDur_s+expDes.itiDur_s)); % in seconds

%% Saving procedure

save(const.design_fileMat,'expDes');

end
