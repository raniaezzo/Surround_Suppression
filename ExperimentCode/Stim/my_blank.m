function [task, frameCounter, vbl] = my_blank(my_key, scr,const, task, frameCounter, interval, vbl)

try
    waitframes = 1;
    %vbl = Screen('Flip',const.window);
    vblendtime = vbl + interval;

    % Blank period
    while vbl <= vblendtime  

        if task(frameCounter,1)==1
            fixColor = const.lightgray;
        else
            fixColor = const.black;
        end

        % draw stimuli here, better at the start of the drawing loop
        my_fixation(scr,const,fixColor)
        Screen('DrawingFinished',const.window); % small ptb optimisation
        vbl = Screen('Flip',const.window, vbl + (waitframes - 0.5) * scr.ifi);

        % check for keyboard input
        [keyIsDown, ~, keyCode] = KbCheck(my_key.keyboardID);
        if ~keyIsDown
            [keyIsDown, ~, keyCode] = KbCheck(my_key.suppResponseID);
        end
        if keyIsDown && keyCode(my_key.escape)
            ShowCursor; sca; return
        elseif keyIsDown && ~keyCode(my_key.escape) && ~(keyCode(my_key.Trigger) || keyCode(34))
            task(frameCounter,2) = 1;   
        end

        FlushEvents('KeyDown');
        frameCounter=frameCounter+1;
    end
    
catch
    return
end

end