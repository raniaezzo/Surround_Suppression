function [expDes, const, frameCounter, vbl] = my_stim(my_key, scr, const, expDes, frameCounter, trialID, vbl)

movieDurationSecs=expDes.stimDur_s;   % Abort after 0.5 seconds.
i = const.phaseLine(trialID);

gratingtex = const.gratingtex; visiblesize = const.visiblesize;
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
    contrast_R = testContrast;
    contrast_L = 0.5;
elseif testLocation == 180 % left
    contrast_R = 0.5;
    contrast_L = testContrast;
end

% % properties matrix
% propertiesMat = [const.phaseLine(1), const.stimSF_cpp, ...
%     const.gaussianSigma, const.contrast, const.aspectRatio, 0, 0, 0];

waitframes = 1;
waitduration = waitframes * scr.ifi;
shiftperframe= const.stimSpeed_cps * const.stimSpeed_ppc * waitduration;

%vbl=Screen('Flip', const.window);
vblendtime = vbl + movieDurationSecs;
%i=0;
  
% Animationloop:
while (vbl < vblendtime)

    if const.expStop==0
        
        xoffset = mod(i*shiftperframe,const.stimSpeed_ppc);

        % this is for motion
    %         if trialType==2   
    %             i=i+1;
    %         end

        srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

        % Set the right blend function for drawing the gabors
        %Screen('BlendFunction', const.window, 'GL_ONE', 'GL_ZERO');

        % Draw grating texture, rotated by "angle":
        Screen('DrawTexture', const.window, gratingtex, [], dstRect_R, const.maporientation(const.stimOri), ...
            [], contrast_R, [], [], []); %, propertiesMat');

        Screen('DrawTexture', const.window, gratingtex, [], dstRect_L, const.maporientation(const.stimOri), ...
            [], contrast_L, [], [], []); %, propertiesMat');

        % surround
        if testLocation == 0
            Screen('DrawTexture', const.window, surroundtex, [], dstRect_surround_R, const.maporientation(const.stimOri), ...
                [], [], [], [], []); %, propertiesMat');
        elseif testLocation == 180
            Screen('DrawTexture', const.window, surroundtex, [], dstRect_surround_L, const.maporientation(const.stimOri), ...
                [], [], [], [], []); %, propertiesMat');
        end

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
