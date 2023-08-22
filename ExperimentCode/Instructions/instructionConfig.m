function [textExp] = instructionConfig
% ----------------------------------------------------------------------
% [textExp] = instructionConfig
% ----------------------------------------------------------------------
% Goal of the function :
% Write text of calibration and general instruction for the experiment.
% ----------------------------------------------------------------------
% Input(s) :
% (none)
% ----------------------------------------------------------------------
% Output(s):
% textExp : struct containing all text of general instructions.
% ----------------------------------------------------------------------

%% Main instruction :

instruction = '-----------------  Ready to start? [space]  -----------------';

textExp.instruction= {instruction};

end