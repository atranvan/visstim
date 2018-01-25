function  stimulusInfo = SpotDrifting(q)
% SpotDrifting  This function displays a gray screen, a spot with a
% rotated drifting grating is displayed of the screen
% It holds this last gray screen until a trigger is detected.
%
% Inputs:
%
%   q
%
% Ouput:
%   stimulusInfo
%       .experimentType         'SrDG'
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
q.input = initialisedio(q);
[DG_SpatialPeriod, DG_ShiftPerFrame] = getDGparams(q);
Screen('Preference', 'SkipSyncTests', 0)
%Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);

%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime = toc;
texsize=300; % Half-Size of the grating image.
visiblesize=(2*texsize+1)/2;
whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
grey = round((white+black) / 2);
% This makes sure that on floating point framebuffers we still get a
% well defined gray. It isn't strictly neccessary in this demo:
if grey == white
    grey=white / 2;
end
inc=white-grey;
%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
try
    currentStimIndex = 0;       %keeps track of what index we are up to
    AssertOpenGL;
    
    for repeat = 1:q.repeats
        for d=1:q.directionsNum
            currentStimIndex = currentStimIndex + 1;
            %% gray screen
            stimulusInfo.stimuli(currentStimIndex).type = 'PreDriftHold';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            thisDirection = stimulusInfo.stimuli(currentStimIndex).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
            srcRect=[0 0 q.screenRect(3)*2 q.screenRect(4)*2];

            for holdFrames = 1:round(q.preDriftHoldTime*q.hz)
                Screen('FillRect', q.window, 127);

                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 0,q.photoDiodeRect ) % photodiode is white for pre-hold grating
                end
                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            
            
            currentStimIndex = currentStimIndex + 1;
            
            %% try to get the drift and spot in same block
            stimulusInfo.stimuli(currentStimIndex).type = 'Drift';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            for frameCount = 1:round((2*q.driftTime+q.spotDriftTime+q.postDriftHoldTime) * q.hz);
                % Define shifted srcRect that cuts out the properly shifted rectangular
                % area from the texture:
                xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                
                % Draw grating texture, rotated by "angle":
                Screen('FillRect', q.window, 127);
                %Screen('DrawTexture', q.window, q.gratingtex, srcRect, [], thisDirection);
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 0,q.photoDiodeRect )
                end
                
                if ((frameCount > round(q.driftTime* q.hz)+1)&&(frameCount<round((q.driftTime+q.spotDriftTime)*q.hz)));
                    q.gratingcirc=q.gratingtex;
                    
                     mask=ones(2*texsize+1,2*texsize+1,2)*grey;
                     [x,y]=meshgrid(-texsize:texsize, -texsize:texsize);
                     mask(:,:,2) = white *(1-(x.^2 + y.^2 <= (texsize)^2));
                     masktex=Screen('MakeTexture',q.window ,mask);
                     dstCircleRect = [0 0 visiblesize visiblesize];
                     dstCircleRect = CenterRect(dstCircleRect,q.screenRect);
                     %xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                     %srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                     srcCircleRect=[xoffset 0 (xoffset + visiblesize) visiblesize];
                     % Draw grating texture:
                     %Screen('DrawTexture', q.window, q.gratingtex, srcRect, [], thisDirection);
                     
                     % Draw aperture over grating
                     %Screen('DrawTexture', q.window, masktex, [100 100 visiblesize visiblesize], dstCircleRect, thisDirection);
                     
                     % Disable alpha blending, restrict following drawing to
                     % alpha channel:
                     Screen('Blendfunction', q.window, GL_ONE, GL_ZERO, [0 0 0 1]);
                     
                     % Clear 'dstCircleRect' region of framebuffers alpha
                     % channel to zero:
                     Screen('FillRect', q.window, [0 0 0 0], dstCircleRect);
                     
                     % Fill circular 'dstCircleRect' region with an alpha value
                     % of 255:
                     Screen('FillOval', q.window, [0 0 0 255], dstCircleRect);
                     
                     % Enable destination alpha blending and reenable drawing to
                     % all color channels:
                     Screen('Blendfunction', q.window, GL_DST_ALPHA,GL_ONE_MINUS_DST_ALPHA, [1 1 1 1]);
                     
                     % Draw 2nd grating texture but only inside alpha == 255
                     % circular aperture, at an angle of 90 degrees
                     
                     Screen('DrawTexture', q.window, q.gratingcirc, srcCircleRect, dstCircleRect, thisDirection + 90,[],[],[],[],kPsychUseTextureMatrixForRotation);
                     
                     % Restore alpha blending mode for next draw iteration
                     Screen('Blendfunction', q.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                     % Draw photodiode area in one corner of the screen
                     if q.photoDiodeRect(2)
                         Screen('FillRect', q.window, 255,q.photoDiodeRect ) % photodiode black for drifting grating
                     end
                end

                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
                %Quit only if 'esc' key was pressed
                [~, ~, keyCode] = KbCheck;
                if keyCode(KbName('escape')), error('escape'), end
            end
            
            currentStimIndex = currentStimIndex + 1;

            
            
            %% PostHold Gray Screen
            stimulusInfo.stimuli(currentStimIndex).type = 'PostHoldGray';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            while inputSingleScan(q.input)
                Screen('FillRect', q.window, 127);
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