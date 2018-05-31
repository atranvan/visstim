function stimulusInfo = DriftTriggered(q)
% This function displays a dynamic grating that changes on a trigger.
%
% Inputs:
%
%   q
%
% Unlike the untriggered version of this function, drift time is determined
% by triggers therefore there is no need to input drift time or baseline
% time
%
%
% Ouput:
%   stimulusInfo
%       .experimentType         'D'
%       .triggering             'on'
%       .directionsNum          Number of different directions displayed
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .type               'Drift'
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


%---------------------------Initialisation---------------------------------
q.input = initialisedio(q);
%q.input

[DG_SpatialPeriod, DG_ShiftPerFrame] = getDGparams(q);

%Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);

%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic

% Display a black screen
runbaseline(q, stimulusInfo);
stimulusInfo.actualBaseLineTime = toc;

%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
try
    currentStimIndex = 0;
for repeat = 1:q.repeats
    for d=1:q.directionsNum
        %Record absolute and relative stimulus start time
        disp(d)
        currentStimIndex = currentStimIndex + 1;
        stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).startTime = toc;
        stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).type = 'Drift';
        thisDirection = stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
        %thisDirection = stimulusInfo.stimuli(currentStimIndex).direction + 90; 
        frameCount = 0;
        % Loop while value is high, in case there is trigger overrun from a
        % previous trigger. Then loop while value is low - so until the
        % next trigger

        while inputSingleScan(q.input)%getvalue(q.input)
            frameCount = frameCount + 1;
            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture:
            xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
            srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
            % Draw grating texture, rotated by "angle":
            
            Screen('DrawTexture', q.window, q.gratingtex, srcRect, [], thisDirection);
            if q.photoDiodeRect(2)
                if frameCount == 1
                    Screen('FillRect', q.window, 255,q.photoDiodeRect )
                else
                    Screen('FillRect', q.window, 0,q.photoDiodeRect )
                end
            end
            Screen('Flip',q.window);
            %Quit only if 'esc' key was pressed, advance if 't' was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            if keyCode(KbName('t')) 
                %wait for keypress to end (=key up) before breaking
                while KbCheck
                end
                break
            end
        end
        while  ~inputSingleScan(q.input)%~getvalue(q.input)
            frameCount = frameCount + 1;
            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture:
            xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
            srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
            % Draw grating texture, rotated by "angle":
            Screen('DrawTexture', q.window, q.gratingtex, srcRect, [], thisDirection);
            if q.photoDiodeRect(2)
                if frameCount == 1
                    Screen('FillRect', q.window, 255,q.photoDiodeRect )
                else
                    Screen('FillRect', q.window, 0,q.photoDiodeRect )
                end
            end
            Screen('Flip',q.window);
            %Record measured stimulus display time
            stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).endTime = toc;
            %Quit only if 'esc' key was pressed, advance if 't' was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            if keyCode(KbName('t')) 
                %wait for keypress to end (=key up) before breaking
                while KbCheck
                end
                break
            end
        end
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

