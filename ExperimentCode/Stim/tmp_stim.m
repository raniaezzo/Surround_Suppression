function [expDes, const, frameCounter, vbl] = tmp_stim(my_key, scr, const, expDes, frameCounter, trialID, vbl)


% OUTPUT: win = window Ptr; INPUT: backgroundcolor
backgroundcolor = 0.5;
inner_annulus_sz = 250;
benchmark = 0;
% [win, rect] = PsychImaging('OpenWindow', screenid, backgroundcolor); 

% Initial stimulus params for the grating:
res = 600;
phase = 0;
freq = .02; %.04;
tilt = 0; %225;
contrast = 0.5;

% Build a procedural gabor texture for a grating with a support of tw x th
% pixels, and a RGB color offset of 0.5 -- a 50% gray.
%squarewavetex = CreateProceduralSquareWaveGrating(win, res, res, [.5 .5 .5 0], res/2);
squarewavetex = CreateProceduralSineGrating(const.window, res, res, [.5 .5 .5 0], res/2);

% Draw the grating once, just to make sure the gfx-hardware is ready for the
% benchmark run below and doesn't do one time setup work inside the
% benchmark loop:
Screen('DrawTexture', const.window, squarewavetex, [], [], tilt, [], [], [], [], [], [phase, freq, contrast, 0]);

% Perform initial flip to gray background and sync us to the retrace:
vbl = Screen('Flip', const.window);
tstart = vbl;
count = 0;

% Get the centre coordinate of the window
%[x, y] = RectCenter(rect);
x = scr.windCenter_px(1);
y = scr.windCenter_px(2);

% Animation loop
while GetSecs < tstart + 5
    count = count + 1;
    % update values:
    phase = phase - 5; % determines the direction of drift

    % Draw the grating:
    Screen('DrawTexture', const.window, squarewavetex, [], [], tilt, [], [], [], [], [], [phase, freq, contrast, 0]);
    % Draw the fixation point
    Screen('DrawDots', const.window, [x y], inner_annulus_sz, backgroundcolor, [], 2); % size is the diameter of each dot in pixels (default is 1)
    
    if benchmark > 0
        % Go as fast as you can without any sync to retrace and without
        % clearing the backbuffer -- we want to measure gabor drawing speed,
        % not how fast the display is going etc.
        Screen('Flip', const.window, 0, 2, 2);
    else
        % Go at normal refresh rate for good looking gabors:
        Screen('Flip', const.window);
    end
end