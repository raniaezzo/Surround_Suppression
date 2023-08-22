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
expDes.rng = rng(const.run);

%% Experimental sequence

expDes.nb_repeat = 4; % number of repeats

% randomize the unique trials expDes.nb_repeat Xs, then concatenate for
% full run
trialtypesMAT = const.targetContrast'; trialsequenceMAT = [];
for tt=1:expDes.nb_repeat
    trialsequenceMAT = [trialsequenceMAT; trialtypesMAT(randperm(size(trialtypesMAT,1)), :)];
end

% save attributes
trialsequence = array2table(trialsequenceMAT,'VariableNames',{'targetContrasts'});
expDes.mainStimTypes = unique(trialsequence.targetContrasts);
[expDes.nb_trials, ~] = size(trialsequence);

% Experimental matrix
trialIDs = 1:expDes.nb_trials;
expDes.trialMat = [trialIDs', table2array(trialsequence)];

%% Experiental timing settings

expDes.stimDur_s  = 0.5;   % 0.5 sec stimulus duration
expDes.itiDur_s  = 2;      % 2 inter-trial interval
expDes.total_s = (expDes.nb_trials*(expDes.stimDur_s+expDes.itiDur_s));

expDes.stimDur_nFrames  =     round(expDes.stimDur_s/scr.ifi); % # frames
expDes.itiDur_nFrames  =      round(expDes.itiDur_s/scr.ifi); % # frames

expDes.totalframes = expDes.stimDur_nFrames*expDes.nb_trials+ ...
    expDes.itiDur_nFrames*expDes.nb_trials;
 
expDes.TrialsStart_frame = 1;
expDes.TrialsEnd_frame = expDes.totalframes;

%% Saving procedure

save(const.design_fileMat,'expDes');

end
