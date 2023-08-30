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

% Keyboard configuration :
[my_key] = keyConfig(const);

% Experimental design configuration :
[expDes] = designConfig(scr,const);

% Experimental constant :
[const] = constConfig(scr,const, expDes);

% Instruction file :
[textExp] = instructionConfig;

% Main part :
if const.expStart; ListenChar(2);end
[expDes, const] = runTrials(scr,const,expDes,my_key,textExp);

if ~const.expStop; quickplot(const, expDes); end

overDone(const, expDes);

end