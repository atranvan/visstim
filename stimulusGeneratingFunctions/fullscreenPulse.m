function stimulusInfo = fullscPulse(q)
% fullscPulse Displays a full screen (gray, luminance input by user)
% after/before black screen
%
% Inputs:
%
% q
%
% Ouput:
%   stimulusInfo
%       .experimentType         'fsPulse'
%       .triggering             'off'
%       .pulseTime
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .repeat              Which repetition, within the
%                                           run, this drift was in
%                   .num           Which number, within a repetition
%                                           this drift was
%                   
%                   .startTime      Relative time, in seconds, since the
%                                      start of the experiment, that the
%                                      state started to be shown
%                   .endTime        Relative time, in seconds, since the
%                                      start of the experiment, that the
%                                      state stopped being shown
%


%---------------------------Initialisation--------------------------------
%[DG_SpatialPeriod, DG_ShiftPerFrame] = getDGparams(q);

%Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);

%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)


%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
try

    for repeat = 1:q.repeats

           % stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            for frameCount= 1:round(q.blackscreenTime * q.hz);
   
                Screen('FillRect', q.window, 0);
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 255,q.photoDiodeRect )
                end
                Screen('Flip',q.window);
                %stimulusInfo.stimuli(currentStimIndex).endTime = toc;
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            

            
            %PostDrift gray screen
            %Record absolute and relative start time
            for holdFrames = 1:round(q.pulsescreenTime*q.hz)
                Screen('FillRect', q.window, q.lumscreen);
                
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 0,q.photoDiodeRect )
                end
                Screen('Flip',q.window);
            end
             %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
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
