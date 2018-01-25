function stimulusInfo =  PlaidGrayTriggered(q)
% PLAIDGRAY displays a moving plaid (2 overlaid gratings), angle between two
% gratings determined by plaidAngle parameters (in degree, default = 90),
% followed by a gray screen for a defined period, until next trigger
%
% Inputs:
%
%   q
%
% Ouput:
%   stimulusInfo
%       .experimentType         'PG'
%       .triggering             'on'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .directionsNum          Number of different directions displayed
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .type           'Plaid'
%                   .repeat         Which repetition, within the run, this
%                                      drift was in
%                   .num            Which number, within a repetition this
%                                      drift was
%                   .direction      In degrees, with 0 being upward movement, increasing CW
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
q.input = initialisedio(q); 
[DG_SpatialPeriod, DG_ShiftPerFrame, DG_DirectionFrames] = getDGparams(q);

%Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);

stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime = toc;
%Priority(MaxPriority(q.window));                           % Needed to ensure maximum performance


%The Display Loop - Displays the grating at predefined orientations from
%the switch structure

try

    currentStimIndex = 0;  
    for repeat = 1:q.repeats
        for d=1:q.directionsNum
            currentStimIndex = currentStimIndex + 1;
            %Record absolute and relative stimulus start time
%             stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).startTime = toc;
%             stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).type='Drift';
%             thisDirection = stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).direction + 90 %0, the first orientation, corresponds to movement towards the top of the screen
            thisDirection = stimulusInfo.stimuli(currentStimIndex).direction + 90;
            for frameCount= 1:round(q.driftTime * q.hz);
           %for frameCount= 1:DG_DirectionFrames;
                %Define shifted srcRect that cuts out the properly shifted rectangular
                %area from the texture:
                xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                
                %Draw grating texture, rotated by "angle":
                Screen('FillRect',q.window,WhiteIndex(max(Screen('Screens'))));
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection);
                Screen('DrawTexture', q.window, q.gratingplaidtex, srcRect, [], thisDirection+q.plaidAngle); % second grating is rotated by value in plaidAngle in degrees

                if q.photoDiodeRect(2)
                    %if frameCount == 1
                        Screen('FillRect', q.window, 255,q.photoDiodeRect )
                    %else
                        %Screen('FillRect', q.window, 0,q.photoDiodeRect )
                    %end
                end
                Screen('Flip',q.window);
                %Record measured stimulus display time
                stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).endTime = toc;
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            currentStimIndex = currentStimIndex + 1;
            
            %PostDrift gray screen
            %Record absolute and relative start time
            stimulusInfo.stimuli(currentStimIndex).type = 'PostDriftGray';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            while inputSingleScan(q.input)
                Screen('FillRect', q.window, 127);
                
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 0,q.photoDiodeRect )
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