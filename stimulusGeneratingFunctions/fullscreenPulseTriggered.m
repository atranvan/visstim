function stimulusInfo = fullscreenPulseTriggered(q)
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
%       .triggering             'on'
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
q.input = initialisedio(q);
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
   
                Screen('FillRect', q.window, q.black);
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, q.white,q.photoDiodeRect )
                end
                Screen('Flip',q.window);
                %stimulusInfo.stimuli(currentStimIndex).endTime = toc;
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            

            
            %PostDrift gray screen
            %Record absolute and relative start time
            while inputSingleScan(q.input)
            %for holdFrames = 1:round(q.postDriftGrayTime*q.hz)
                Screen('FillRect', q.window, q.lumscreen);
                
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, q.black,q.photoDiodeRect )
                end
                Screen('Flip',q.window);
            end
             %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            if keyCode(KbName('t'))
                %wait for keypress to end (=key up) before breaking
                while KbCheck
                end
                break
            end
        end
    
    catch err
    if ~strcmp(err.message, 'escape')
        rethrow(err)
    end

end
%Display a black screen at the end
Screen('FillRect', q.window, q.black);
Screen('Flip',q.window);

end
