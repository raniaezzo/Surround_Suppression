function [my_key]=keyConfig(const, scr)
% ----------------------------------------------------------------------
% [my_key]=keyConfig
% ----------------------------------------------------------------------
% Goal of the function :
% Unify key names and return a structure containing each key names.
% ----------------------------------------------------------------------
% Input(s) :
% none
% ----------------------------------------------------------------------
% Output(s):
% my_key : structure containing all keyboard names.
% ----------------------------------------------------------------------

% keyboard
[keyboardIndices, productNames, ~] = GetKeyboardIndices;
for i=1:length(productNames)                  % for each possible devices
    if strcmp(productNames{i},const.keyboard) % compare the name to the name you want
        my_key.keyboardID=keyboardIndices(i); % grab the correct id, and exit loop
        disp('DETECTED KEYBOARD PROVIDED')
    else 
        my_key.keyboardID=keyboardIndices(1); % otherwise use first keyboard detected
    end
end

my_key.escape       = KbName('ESCAPE');
my_key.space        = KbName('Space');

enter_keyCodes      = KbName('Return');
if strcmp(scr.OS, 'PC') && length(enter_keyCodes) > 1
    my_key.enter        = enter_keyCodes(2); % check that works with PC
else
    my_key.enter        = enter_keyCodes(1); % for mac
end

if strcmp(scr.experimenter, 'StanfordPC')
    my_key.rightArrow   = KbName('Right'); % check with them what occurs with code below and create more general solution
    my_key.leftArrow    = KbName('Left');
else
    my_key.rightArrow   = KbName('RightArrow');
    my_key.leftArrow    = KbName('LeftArrow');
end

end