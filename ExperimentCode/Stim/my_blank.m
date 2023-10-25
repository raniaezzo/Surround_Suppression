function [expDes, const, frameCounter, vbl] = my_blank(my_key, scr, const, expDes, frameCounter, vbl)

try
    waitframes = 1;
    %vbl = Screen('Flip',const.window);
    vblendtime = vbl + expDes.itiDur_s;
    % Blank period
    while vbl <= vblendtime  
        if ~const.expStop
            
            % draw fixation regardless
            my_fixation(scr,const,const.black)
            
            % Draw stimuli here, better at the start of the drawing loop
            if strcmp(const.expPar, 'neural')
                if const.letter_seq(frameCounter) == 1
                    trialLetterString = const.target_letter;
                else
                    trialLetterString = const.pedestal_letter;
                end
                my_letter_detection_task(scr, const, const.white, trialLetterString)
            end
            
            Screen('DrawingFinished',const.window); % small ptb optimisation
            vbl = Screen('Flip',const.window, vbl + (waitframes - 0.5) * scr.ifi);
            
            % check for keyboard input
            [keyIsDown, ~, keyCode] = KbCheck(my_key.keyboardID);
            if keyIsDown && keyCode(my_key.escape)
                ShowCursor; 
                const.forceQuit=1;
                const.expStop=1;
            elseif keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.space) && strcmp(const.expPar, 'neural')
                expDes.letterResponse(frameCounter) = 1; % log from the start of experiment (for letter detection)
            end
            FlushEvents('KeyDown');
            
            frameCounter=frameCounter+1;

        else
            break
        end
    end
    
catch
    return
end

end