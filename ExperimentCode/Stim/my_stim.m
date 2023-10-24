function [expDes, const, frameCounter, vbl] = my_stim(my_key, scr, const, expDes, frameCounter, trialID, vbl)

iL = const.phaseLine(1,trialID);
iR = const.phaseLine(2,trialID);

% determine location of the Sm (isolated) and St (embedded)
testLocation = expDes.trialMat(trialID,3); % RH or LH for embedded stimulus
testContrast = expDes.trialMat(trialID,2); % contrast value
adjustedContrast = expDes.startingContrasts(1,trialID);

% for the letter detection task:
trialLetterString = expDes.letter_detection_sequence(trialID); 
% eccentricity
dstRect_surround_R = const.rectPointsSurr{1};
dstRect_surround_L = const.rectPointsSurr{2};

dstRect_R = const.rectPoints{1};
dstRect_L = const.rectPoints{2};

%xDist = const.stimEccpix; yDist = 0;

%dstRect_R = create_dstRect(const.visiblesize, xDist, yDist, scr, 1); % right side
%dstRect_L = create_dstRect(const.visiblesize, xDist, yDist, scr, 0); % left side

%dstRect_surround_R = create_dstRect(const.visiblesize_surr, xDist, yDist, scr, 1); % right side
%dstRect_surround_L = create_dstRect(const.visiblesize_surr, xDist, yDist, scr, 0); % left side

waitframes = 1;
startTime = vbl;

flicker_time = 1/const.flicker_hz; 
flipphase = -1; phasenow = 1;
responded=0;
responseTime = NaN;
movieframe_n = 1;

frameCounter_init = frameCounter;

% stimulus timing:
t2wait = 0.5; % based on Hermes et al., 2014 

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
                auxParamsS = [const.contrast_surround, iR+((90)*phasenow*-1), const.scalar4noiseSurround, 0];
            elseif testLocation == const.paIdx2
                auxParamsS = [const.contrast_surround, iL+((90)*phasenow*-1), const.scalar4noiseSurround, 0];
            end
        elseif strcmp(expDes.stimulus, 'grating')
            auxParamsR = [iR+((90)*phasenow), const.stimSF_cpp, contrast_R, 0];
            auxParamsL = [iL+((90)*phasenow), const.stimSF_cpp, contrast_L, 0];
            if testLocation == const.paIdx1
                auxParamsS = [iR+((90)*phasenow*-1), const.stimSF_cpp, const.contrast_surround, 0];
            elseif testLocation == const.paIdx2
                auxParamsS = [iL+((90)*phasenow*-1), const.stimSF_cpp, const.contrast_surround, 0];
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

        % Draw stimuli here, better at the start of the drawing loop
        if strcmp(const.expPar, 'neural')
            my_letter_detection_task(scr, const, const.black, trialLetterString)
        elseif strcmp(const.expPar, 'behavioral')
            my_fixation(scr,const,const.black)
        end

        Screen('DrawingFinished',const.window); % small ptb optimisation
        time_to_start = GetSecs;
        vbl = Screen('Flip',const.window, vbl + (waitframes - 0.5) * scr.ifi);

        if strcmp(const.expPar, 'neural')
            timedOut = 0;
            while ~timedOut
                [keyIsDown, ~, keyCode] = KbCheck(my_key.keyboardID);
                if keyIsDown && keyCode(my_key.escape)
                    ShowCursor;
                    const.forceQuit=1;
                    const.expStop=1;
                elseif keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.space)
                    responseTime = vbl-startTime;
                end
                % count from the stimulus onset (time_to_start)
                time_to_count = GetSecs;
                if time_to_count > t2wait + time_to_start
                    timedOut = 1;
                    responded = 1; % no response is registered, but the experiment needs to move on
                end
            end

        elseif strcmp(const.expPar, 'behavioral')
            % check for keyboard input
            [keyIsDown, ~, keyCode] = KbCheck(my_key.keyboardID);
            if ~keyIsDown % if finger is lifted off key do not set a time contraint
                reset = 1;
            elseif keyIsDown && keyCode(my_key.escape)
                ShowCursor;
                const.forceQuit=1;
                const.expStop=1;
            elseif keyIsDown && ~keyCode(my_key.escape) && keyCode(my_key.space)
                responseTime = vbl-startTime;
                responded=1;
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
    else
        break
    end
     
end

% save submitted contrast:
expDes.response(trialID, 1) = adjustedContrast;
expDes.response(trialID, 2) = responseTime;

%%

% function dstRect = create_dstRect(visiblesize, xDist, yDist, scr, rightside)
%     if ~rightside
%         xDist = -xDist;
%     end
%     xDist = scr.windCenter_px(1)+xDist-(visiblesize/2); % center + (+- distance added in pixels)
%     yDist = scr.windCenter_px(2)+yDist-(visiblesize/2);  % check with -(vis part.. 
%     dstRect=[xDist yDist visiblesize+xDist visiblesize+yDist];
% end

end
