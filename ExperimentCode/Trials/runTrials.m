function [expDes, const] = runTrials(scr,const,expDes,my_key,textExp)
% ----------------------------------------------------------------------
% runTrials(scr,const,expDes,my_key,textExp,button)
% ----------------------------------------------------------------------
% Goal of the function :
% Main trial function, display the trial function and save the experi-
% -mental data in different files.
% ----------------------------------------------------------------------
% Input(s) :
% scr : window pointer
% const : struct containing all the constant configurations.
% expDes : struct containing all the variable design and configurations.
% my_key : keyboard keys names
% textExp : struct contanining all instruction text.
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------

%% General instructions:

if const.DEBUG
    HideCursor(scr.scr_num);
end

keyCode = instructions(scr,const,my_key,textExp.instruction);
tic

% cols: contrast, RT
expDes.task = nan(expDes.nb_trials, 2);

if keyCode(my_key.escape), return, end

FlushEvents('KeyDown');

%% Main Loop
frameCounter=1;
const.expStop = 0;
const.forceQuit = 0;

vbl = Screen('Flip',const.window);
t0=vbl;
expDes.trial_onsets = nan(1,(expDes.nb_trials));
expDes.stimulus_onsets = nan(1,(expDes.nb_trials));

while ~const.expStop
    
    for ni=1:expDes.nb_trials
        expDes.trial_onsets(ni) = vbl-t0; % log the onset of each trial
        [expDes, const, frameCounter, vbl] = my_blank(my_key, scr, const, expDes, frameCounter, vbl);
        expDes.stimulus_onsets(ni) = vbl-t0; % log the onset of each stimulus
        [expDes, const, frameCounter, vbl] = my_stim(my_key, scr, const, expDes, frameCounter, ni, vbl);
    end
    
end


end