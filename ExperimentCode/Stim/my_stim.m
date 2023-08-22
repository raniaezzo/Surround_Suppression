function [task, frameCounter, vbl] = my_stim(my_key, scr,const,expDes, task, frameCounter, trialID, vbl)

try
    trialType = expDes.trialMat(trialID,2); % contrast value

    movieDurationSecs=expDes.stimDur_s;   % Abort after 0.5 seconds.
    i = const.phaseLine(trialID);

    % included: ~~~~~
% 
%     grating_halfw = const.grating_halfw;
    visiblesize = const.visiblesize;
%     gratingtex = const.gratingtex;
%     maskOutertex = const.maskOutertex;
%     maskInnertex = const.maskInnertex;

    % eccentricity
    xDist = const.stimEccpix; yDist = 0;
    xDist = scr.windCenter_px(1)+xDist-(visiblesize/2); % center + (+- distance added in pixels)
    yDist = scr.windCenter_px(2)+yDist-(visiblesize/2);  % check with -(vis part.. 
    dstRect=[xDist yDist visiblesize+xDist visiblesize+yDist];

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

        if task(frameCounter,1)==1
            fixColor = const.lightgray;
        else
            fixColor = const.black;
        end

        xoffset = mod(i*shiftperframe,const.stimSpeed_ppc);

        if trialType==2   
            i=i+1;
        end

        srcRect=[xoffset 0 xoffset + visiblesize visiblesize];

        % Set the right blend function for drawing the gabors
        %Screen('BlendFunction', const.window, 'GL_ONE', 'GL_ZERO');

        % Draw grating texture, rotated by "angle":
        Screen('DrawTexture', const.window, gratingtex, srcRect, dstRect, const.stimOri, ...
            [], [], [], [], []); %, propertiesMat');

%         % outer and inner masks
%         Screen('DrawTexture', const.window, maskOutertex, [], [], []); %[0 0 scr.windX_px scr.windY_px], []);
%         Screen('DrawTexture', const.window, maskInnertex, [], dstRect, []);

        % Draw stimuli here, better at the start of the drawing loop
        my_fixation(scr,const,fixColor)

        Screen('DrawingFinished',const.window); % small ptb optimisation

        vbl = Screen('Flip',const.window, vbl + (waitframes - 0.5) * scr.ifi);

        % check for keyboard input
        [keyIsDown, ~, keyCode] = KbCheck(my_key.keyboardID);
        if ~keyIsDown
            [keyIsDown, ~, keyCode] = KbCheck(my_key.suppResponseID);
        end
        if keyIsDown && keyCode(my_key.escape)
            ShowCursor; sca; clear mex; clear fun; return
        elseif keyIsDown && ~keyCode(my_key.escape) && ~(keyCode(my_key.Trigger) || keyCode(34))
            task(frameCounter,2) = 1;   
        end

        FlushEvents('KeyDown');
        frameCounter=frameCounter+1;

    end

    % shared code for baseline & also intertrial interval
    [task, frameCounter, vbl] = my_blank(my_key, scr,const, task, frameCounter, expDes.itiDur_s*1, vbl);
    
catch
    return
end

end
