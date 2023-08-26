function [expDes, const, frameCounter, vbl] = my_stim(my_key, scr, const, expDes, frameCounter, trialID, vbl)

movieDurationSecs=expDes.stimDur_s;   % Abort after 0.5 seconds.
iL = const.phaseLine(1,trialID);
iR = const.phaseLine(2,trialID);
iS = const.phaseLine(3,trialID);

gratingtex = const.squarewavetex; visiblesize = const.visiblesize;
surroundtex = const.surroundtex; visiblesize_surr = const.visiblesize_surr;

% determine location of the Sm (isolated) and St (embedded)
testContrast = expDes.trialMat(trialID,2); % contrast value
testLocation = expDes.trialMat(trialID,3); % RH or LH for embedded stimulus

% eccentricity
xDist = const.stimEccpix; yDist = 0;

dstRect_R = create_dstRect(visiblesize, xDist, yDist, scr, 1); % right side
dstRect_L = create_dstRect(visiblesize, xDist, yDist, scr, 0); % left side

dstRect_surround_R = create_dstRect(visiblesize_surr, xDist, yDist, scr, 1); % right side
dstRect_surround_L = create_dstRect(visiblesize_surr, xDist, yDist, scr, 0); % left side

if testLocation == 0 % right
    contrast_R = testContrast; contrast_L = 0.8;
elseif testLocation == 180 % left
    contrast_R = 0.8; contrast_L = testContrast;
end

waitframes = 1;
waitduration = waitframes * scr.ifi;
shiftperframe= const.stimSpeed_cps * const.stimSpeed_ppc * waitduration;

%vbl=Screen('Flip', const.window);
vblendtime = vbl + movieDurationSecs;

flicker_time = movieDurationSecs/(movieDurationSecs*4); % 4 hz  
increment = flicker_time; 
flipphase = -1; phasenow = 1;

% Animationloop:
while (vbl < vblendtime)

    if ~const.expStop  
         
        if (movieDurationSecs-(vblendtime-vbl)) > flicker_time
            phasenow = phasenow*flipphase;
            flicker_time = flicker_time+increment;
        end
         
        % Set the right blend function for drawing the gabors
        Screen('BlendFunction', const.window, 'GL_ONE', 'GL_ZERO');
        
        %if phasenow - should i just present counterphase this way?
        % Draw grating texture, rotated by "angle":
        Screen('DrawTexture', const.window, const.squarewavetex, [], dstRect_R, const.maporientation(const.stimOri), ...
            [], [], [], [], [], [iR+((90)*phasenow), const.stimSF_cpp, contrast_R, 0]);
        % should not be 90 - should be randomized (but not 0) ^^
        
        Screen('DrawTexture', const.window, const.squarewavetex, [], dstRect_L, const.maporientation(const.stimOri), ...
            [], [], [], [], [], [iL+((90)*phasenow), const.stimSF_cpp, contrast_L, 0]);
       
        Screen('BlendFunction', const.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
        Screen('DrawTexture', const.window, const.centermask, [], dstRect_R, [], [], [], [], [], []);
        
        Screen('DrawTexture', const.window, const.centermask, [], dstRect_L, [], [], [], [], [], []);

        % surround
        %if testLocation == 0
        %    Screen('DrawTexture', const.window, surroundtex, [], dstRect_surround_R, const.maporientation(const.stimOri), ...
        %        [], const.contrast_surround, [], [], []); %, propertiesMat');
        %elseif testLocation == 180
        %    Screen('DrawTexture', const.window, surroundtex, [], dstRect_surround_L, const.maporientation(const.stimOri), ...
        %        [], const.contrast_ surround, [], [], []); %, propertiesMat');
        %end

        % Draw stimuli here, better at the start of the drawing loop
        my_fixation(scr,const,const.black)

        Screen('DrawingFinished',const.window); % small ptb optimisation

        vbl = Screen('Flip',const.window, vbl + (waitframes - 0.5) * scr.ifi);

        % check for keyboard input
        [keyIsDown, ~, keyCode] = KbCheck(my_key.keyboardID);
        if keyIsDown && keyCode(my_key.escape)
            ShowCursor; 
            const.forceQuit=1;
            const.expStop=1;
        elseif keyIsDown && ~keyCode(my_key.escape)
            expDes.task(frameCounter,2) = 1;   
        end

        FlushEvents('KeyDown');
        frameCounter=frameCounter+1;
    else
        break
    end
     
end

%%

function dstRect = create_dstRect(visiblesize, xDist, yDist, scr, rightside)
    if ~rightside
        xDist = -xDist;
    end
    xDist = scr.windCenter_px(1)+xDist-(visiblesize/2); % center + (+- distance added in pixels)
    yDist = scr.windCenter_px(2)+yDist-(visiblesize/2);  % check with -(vis part.. 
    dstRect=[xDist yDist visiblesize+xDist visiblesize+yDist];
end

end
