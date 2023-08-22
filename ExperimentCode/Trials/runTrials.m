function [task, trial_onsets] = runTrials(scr,const,expDes,my_key,textExp)
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

disp('Starting runTrials')

HideCursor(scr.scr_num);
keyCode = instructions(scr,const,my_key,textExp.instruction);

task = my_task(expDes, scr);

if keyCode(my_key.escape), return, end

FlushEvents('KeyDown');

%% Main Loop
frameCounter=1;
const.expStop = 0;
paddingX = 0;

tic
vbl = Screen('Flip',const.window);
t0=vbl;
trial_onsets = nan(1,(expDes.nb_trials));

while ~const.expStop
    
    for ni=1:expDes.nb_trials
        trial_onsets(ni) = vbl-t0; % log the onset of each
        [task, frameCounter, vbl] = my_stim(my_key, scr,const,expDes,task, frameCounter,ni,vbl);
    end
    
end
toc


end