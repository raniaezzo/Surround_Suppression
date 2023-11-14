function [expDes, const, frameCounter, vbl] = my_stim(my_key, scr, const, expDes, frameCounter, trialID, vbl)

disp('My stim')

iL = const.phaseLine(1,trialID);
iR = const.phaseLine(2,trialID);

% determine location of the Sm (isolated) and St (embedded)
testLocation = expDes.trialMat(trialID,3); % RH or LH for embedded stimulus
testContrast = expDes.trialMat(trialID,2); % contrast value
surroundContrast = expDes.trialMat(trialID,4); % surround contrast levels added
adjustedContrast = expDes.startingContrasts(1,trialID);

% for the letter detection task:
% eccentricity
dstRect_surround_R = const.rectPointsSurr{1};
dstRect_surround_L = const.rectPointsSurr{2};

dstRect_R = const.rectPoints{1};
dstRect_L = const.rectPoints{2};

waitframes = 1;
startTime = vbl;

flicker_time = 1/const.flicker_hz;
flipphase = -1; phasenow = 1;
responded=0;
responseTime = NaN;
movieframe_n = 1;

frameCounter_init = frameCounter;
% Animationloop:
while ~(const.expStop) && ~(responded)
    
    if ~const.expStop

        if mod((frameCounter-frameCounter_init), flicker_time*(scr.frameRate)) == 0
            phasenow = phasenow*flipphase;
        end

        if testLocation == const.paIdx1 % right
            contrast_R = testContrast; contrast_L = adjustedContrast;
        elseif testLocation == const.paIdx2 % left
            contrast_R = adjustedContrast; contrast_L = testContrast;
        end

        if strcmp(expDes.stimulus, 'perlinNoise')
            auxParamsR = [contrast_R, iR+((90)*phasenow), const.scalar4noiseTarget, 0];
            auxParamsL = [contrast_L, iL+((90)*phasenow), const.scalar4noiseTarget, 0];
            if testLocation == const.paIdx1
                auxParamsS = [surroundContrast, iR+((90)*phasenow*-1), const.scalar4noiseSurround, 0];
            elseif testLocation == const.paIdx2
                auxParamsS = [surroundContrast, iL+((90)*phasenow*-1), const.scalar4noiseSurround, 0];
            end
        elseif strcmp(expDes.stimulus, 'grating')
            auxParamsR = [iR+((90)*phasenow), const.stimSF_cpp, contrast_R, 0];
            auxParamsL = [iL+((90)*phasenow), const.stimSF_cpp, contrast_L, 0];
            if testLocation == const.paIdx1
                auxParamsS = [iR+((90)*phasenow*-1), const.stimSF_cpp, surroundContrast, 0];
            elseif testLocation == const.paIdx2
                auxParamsS = [iL+((90)*phasenow*-1), const.stimSF_cpp, surroundContrast, 0];
            end
        end

        % Set the right blend function for drawing the gabors
        Screen('BlendFunction', const.window, 'GL_ONE', 'GL_ZERO');

        % surround
        if testLocation == const.paIdx1
            Screen('DrawTexture', const.window, const.surroundwavetex, [], dstRect_surround_R, const.maporientation(const.stimOri), ...
                [], [], [], [], [], auxParamsS);
        elseif testLocation == const.paIdx2
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

        if testLocation == const.paIdx1
            Screen('DrawTexture', const.window, const.centermask, [], dstRect_L, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.surroundmask, [], dstRect_surround_R, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.gapTexture, [], dstRect_surround_R, [], [], [], [], [], []);
        elseif testLocation == const.paIdx2
            Screen('DrawTexture', const.window, const.centermask, [], dstRect_R, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.surroundmask, [], dstRect_surround_L, [], [], [], [], [], []);
            Screen('DrawTexture', const.window, const.gapTexture, [], dstRect_surround_L, [], [], [], [], [], []);
        end

        % Draw fixation regardless
        my_fixation(scr,const,const.black)
        
        % Draw stimuli here, better at the start of the drawing loop
        if strcmp(const.expPar, 'neural')
            % for letter detection
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
        elseif strcmp(const.expPar, 'neural')
            if vbl-startTime >= expDes.stimDur_s
                responded = 1; % no response is registered, but the experiment needs to move on
            elseif keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.space)
                responseTime = vbl-startTime;
                expDes.letterResponse(frameCounter) = 1;
            end
        elseif strcmp(const.expPar, 'behavioral')
            if ~keyIsDown % if finger is lifted off key do not set a time contraint
                reset = 1;
            elseif keyIsDown && keyCode(my_key.escape)
                ShowCursor;
                const.forceQuit=1;
                const.expStop=1;
            elseif keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.space)
                responseTime = vbl-startTime;
                responded = 1;
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
        end
        
        if const.makemovie && mod(frameCounter,15) == 0
            M = Screen('GetImage', const.window,[],[],0,3);
            imwrite(M,fullfile(const.moviefolder, [num2str(movieframe_n),'.png']));
            movieframe_n = movieframe_n + 1;
        end

        % FlushEvents('KeyDown');
        frameCounter=frameCounter+1;
        
        % NO LONGER NEED BELOW BECAUSE I MOVED THE CONST.LETTER_SEQ INTO
        % THE FOR LOOP ABOVE
%         % for behavioral condition (with unlimited response time), extend
%         % the framerate array 
%         if length(const.letter_seq) <= frameCounter
%             const.letter_seq = [const.letter_seq; const.letter_seq];
%             expDes.letterResponse = [expDes.letterResponse; zeros(length(expDes.letterResponse),1)];
%         end
        
    else
        break
    end

end

% save submitted contrast & RT if behavioral condition:
if ~ strcmp(const.expPar, 'neural')
    expDes.response(trialID, 1) = adjustedContrast;
    expDes.response(trialID, 2) = responseTime;
end

end
