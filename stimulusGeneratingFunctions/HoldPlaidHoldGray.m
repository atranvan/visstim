function  stimulusInfo = HoldPlaidHoldGray(q)
%HOLDPlaidHOLDGrayscreen  This function displays static then drifting Plaid then static
% again, all in the same direction, for specified times. Gray screen is
% displayed in between directions
%
% Inputs:
%
%   q
%
% Ouput:
%   stimulusInfo
%       .experimentType         'HPHG'
%       .triggering             'off'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .directionsNum          Number of different directions displayed
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .type                   'PreDriftHold', 'Drift' or
%                                           'PostDriftHold'
%                   .repeat              Which repetition, within the
%                                           run, this drift was in
%                   .num           Which number, within a repetition
%                                           this drift was
%                   .direction              In degrees, with 0 being upward movement, increasing CW
%                   .startTime      Relative time, in seconds, since the
%                                      start of the experiment, that the
%                                      state started to be shown
%                   .endTime        Relative time, in seconds, since the
%                                      start of the experiment, that the
%                                      state stopped being shown
%
%  The following are added to stimulusInfo by the VisStim program itself,
%  after it is returned:
%       .temporalFreq           the grating temporal frequency
%       .spatialFreq            the grating spatial frequency
% (it's just easier that way. Think of them as outputs.)
%---------------------------Initialisation--------------------------------
[DG_SpatialPeriod, DG_ShiftPerFrame] = getDGparams(q);

%Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);

%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime = toc;

%The Display Loop - Displays the plaid at predefined orientations from
%the switch structure
try
    currentStimIndex = 0;       %keeps track of what index we are up to
    for repeat = 1:q.repeats
        for d=1:q.directionsNum
            currentStimIndex = currentStimIndex + 1;
            %PreDrift Hold
            stimulusInfo.stimuli(currentStimIndex).type = 'PreDriftHold';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            thisDirection = stimulusInfo.stimuli(currentStimIndex).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
            srcRect=[0 0 q.screenRect(3)*2 q.screenRect(4)*2];
            for holdFrames = 1:round(q.preDriftHoldTime*q.hz)
                Screen('FillRect',q.window,WhiteIndex(max(Screen('Screens'))));
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection);
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection+q.plaidAngle); % second grating is rotated by value in plaidAngle in degrees
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 255,q.photoDiodeRect ) % photodiode is white for pre-hold grating
                end
                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            currentStimIndex = currentStimIndex + 1;
            
            %Drift
            stimulusInfo.stimuli(currentStimIndex).type = 'Drift';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            for frameCount= 1:round(q.driftTime * q.hz);
                % Define shifted srcRect that cuts out the properly shifted rectangular
                % area from the texture:
                xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                
                % Draw plaid texture, rotated by "angle":
                Screen('FillRect',q.window,WhiteIndex(max(Screen('Screens'))));
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection);
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection+q.plaidAngle); % second grating is rotated by value in plaidAngle in degrees

                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 0,q.photoDiodeRect ) % photodiode black for drifting grating
                end
                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            
            currentStimIndex = currentStimIndex + 1;
            %PostDrift Hold
            stimulusInfo.stimuli(currentStimIndex).type = 'PostDriftHold';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            for holdFrames = 1:round(q.postDriftHoldTime*q.hz)
                Screen('FillRect',q.window,WhiteIndex(max(Screen('Screens'))));
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection);
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection+q.plaidAngle); % second grating is rotated by value in plaidAngle in degrees

                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 255,q.photoDiodeRect )% photodiode is white for post-hold grating
                end
                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
            end
            
            %PostHold Gray Screen
            stimulusInfo.stimuli(currentStimIndex).type = 'PostHoldGray';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            for holdFrames = 1:round(q.postDriftGrayTime*q.hz)
                Screen('FillRect', q.window, 120);
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 0,q.photoDiodeRect )% photodiode is black for post-hold gray screen
                end
                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
        end
    end
catch err
    if ~strcmp(err.message, 'escape')
        rethrow(err)
    end
end
%Display a black screen at the end
Screen('FillRect', q.window, 0);
Screen('Flip',q.window);

end

