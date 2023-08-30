function [expDes, const, frameCounter, vbl] = my_stim(my_key, scr, const, expDes, frameCounter, trialID, vbl)

movieDurationSecs=expDes.stimDur_s;   % Abort after 0.5 seconds.
iL = const.phaseLine(1,trialID);
iR = const.phaseLine(2,trialID);
iS = const.phaseLine(3,trialID);

% determine location of the Sm (isolated) and St (embedded)
testLocation = expDes.trialMat(trialID,3); % RH or LH for embedded stimulus
testContrast = expDes.trialMat(trialID,2); % contrast value
adjustedContrast = expDes.startingContrasts(1,trialID); % these can either be random or some starting value

% eccentricity
xDist = const.stimEccpix; yDist = 0;

dstRect_R = create_dstRect(const.visiblesize, xDist, yDist, scr, 1); % right side
dstRect_L = create_dstRect(const.visiblesize, xDist, yDist, scr, 0); % left side

dstRect_surround_R = create_dstRect(const.visiblesize_surr, xDist, yDist, scr, 1); % right side
dstRect_surround_L = create_dstRect(const.visiblesize_surr, xDist, yDist, scr, 0); % left side

waitframes = 1;
waitduration = waitframes * scr.ifi;
shiftperframe= const.stimSpeed_cps * const.stimSpeed_ppc * waitduration;

%vbl=Screen('Flip', const.window);
vblendtime = vbl + movieDurationSecs;

flicker_time = movieDurationSecs/(movieDurationSecs*4); % 4 hz  
increment = flicker_time;
flipphase = -1; phasenow = 1;
const.responded=0;

% Animationloop:
%while (vbl < vblendtime)
while ~(const.expStop) && ~(const.responded)

    if ~const.expStop  
         
        if (movieDurationSecs-(vblendtime-vbl)) > flicker_time
            phasenow = phasenow*flipphase;
            flicker_time = flicker_time+increment;
        end
        
        if testLocation == 0 % right
            contrast_R = testContrast; contrast_L = adjustedContrast;
        elseif testLocation == 180 % left
            contrast_R = adjustedContrast; contrast_L = testContrast;
        end
        
        if strcmp(expDes.stimulus, 'perlinNoise')
            auxParamsR = [contrast_R, iR+((90)*phasenow), const.scalar4noiseTarget, 0];
            auxParamsL = [contrast_L, iL+((90)*phasenow), const.scalar4noiseTarget, 0];
            auxParamsS = [const.contrast_surround, iS+((90)*phasenow), const.scalar4noiseSurround, 0];
        elseif strcmp(expDes.stimulus, 'grating')
            auxParamsR = [iR+((90)*phasenow), const.stimSF_cpp, contrast_R, 0];
            auxParamsL = [iL+((90)*phasenow), const.stimSF_cpp, contrast_L, 0];
            auxParamsS = [iS+((90)*phasenow), const.stimSF_cpp, const.contrast_surround, 0];
        end
        
        % Set the right blend function for drawing the gabors
        Screen('BlendFunction', const.window, 'GL_ONE', 'GL_ZERO');
        
        % surround
        if testLocation == 0
           Screen('DrawTexture', const.window, const.surroundwavetex, [], dstRect_surround_R, const.maporientation(const.stimOri), ...
               [], [], [], [], [], auxParamsS);
        elseif testLocation == 180
           Screen('DrawTexture', const.window, const.surroundwavetex, [], dstRect_surround_L, const.maporientation(const.stimOri), ...
               [], [], [], [], [], auxParamsS);
        end
        
        %if phasenow - should i just present counterphase this way?
        % Draw grating texture, rotated by "angle":
        Screen('DrawTexture', const.window, const.squarewavetex, [], dstRect_R, const.maporientation(const.stimOri), ...
            [], [], [], [], [], auxParamsR);

        Screen('DrawTexture', const.window, const.squarewavetex, [], dstRect_L, const.maporientation(const.stimOri), ...
            [], [], [], [], [], auxParamsL);
        
        % add grey gradient masks
        Screen('BlendFunction', const.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        
        if testLocation == 0
            Screen('DrawTexture', const.window, const.centermask, [], dstRect_L, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.surroundmask, [], dstRect_surround_R, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.gapTexture, [], dstRect_surround_R, [], [], [], [], [], []);
        elseif testLocation == 180
            Screen('DrawTexture', const.window, const.centermask, [], dstRect_R, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.surroundmask, [], dstRect_surround_L, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.gapTexture, [], dstRect_surround_L, [], [], [], [], [], []);
        end

        % Draw stimuli here, better at the start of the drawing loop
        my_fixation(scr,const,const.black)

        Screen('DrawingFinished',const.window); % small ptb optimisation

        vbl = Screen('Flip',const.window, vbl + (waitframes - 0.5) * scr.ifi);

        % check for keyboard input
        [keyIsDown, ~, keyCode] = KbCheck(my_key.keyboardID);
        if ~keyIsDown % if finger is lifted off key do not set a time contraint
            reset = 1;
        elseif keyIsDown && keyCode(my_key.escape)
            ShowCursor; 
            const.forceQuit=1;
            const.expStop=1;
        elseif keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.space) 
            const.responded=1; 
        elseif (keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.rightArrow)) && reset
            adjustedContrast = adjustedContrast+0.01;
            reset = 0;
            if adjustedContrast>1
                adjustedContrast=1;
            end
        elseif (keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.leftArrow)) && reset
            adjustedContrast = adjustedContrast-0.01;
            reset = 0;
            if adjustedContrast<0
                adjustedContrast=0;
            end
        end

        % FlushEvents('KeyDown');
        frameCounter=frameCounter+1;
    else
        break
    end
     
end

% save submitted contrast:
expDes.response(trialID, 1) = adjustedContrast;

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
