function main(const)
% ----------------------------------------------------------------------
% main(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Main code of experiment
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing subject information and saving files.
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------

% File directory :
[const] = dirSaveFile(const);

% Screen configuration :
[scr, const] = scrConfig(const);

if const.TRIGGERCHECK
    %% RTBox setup
    % RTBox('fake',1); % set RTBox to fake mode: use keyboard to simulate
    RTBox('clear'); % Open RT box if hasn't
    %RTBox('ButtonNames', {'left' 'left' 'right' 'right'}); % make first 2 and last 2 equivalent
    %RTBox(inf); % wait for any button press
    RTBox('TTLWidth', .02);
    RTBox('enable','light');
end

% Keyboard configuration :
[my_key] = keyConfig(const, scr);

% Experimental design configuration :
[expDes] = designConfig(scr,const);

% Experimental constant :
[const] = constConfig(scr,const, expDes);

% Instruction file :
[textExp] = instructionConfig;

% Main part :
if const.expStart; ListenChar(2);end
[expDes, const] = runTrials(scr,const,expDes,my_key,textExp);

if ~const.expStop && strcmp(const.expPar, 'behavioral'); quickplot(const, expDes); end

overDone(const, expDes);

end