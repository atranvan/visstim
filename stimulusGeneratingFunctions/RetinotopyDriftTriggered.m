function stimulusInfo =  RetinotopyDriftTriggered(q)
% This function displays a drifting retinotopy stimulus, triggered
%
% Inputs:
%
%   q - structure with all parameters entered in to or calculated in
%   VisStimAlex
%
% Ouput:
%   stimulusInfo
%       .experimentType         'Ret'
%       .triggering             'off'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .directionsNum          Number of different directions displayed in each patch
%       .repeats                Number of cycles of ALL patches
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .patchGridDimensions    a copy of patchGridDimensions - the number
%                                  of divisions ([x y])
%       .stimuli                a 1 x m struct array:
%               m = repeat * directions * patchGrid_x*patchGrid_y - a complete list of states
%                   .type               'Drift'
%                   .repeat             Which repetition, within the run, this
%                                           drift was in
%                   .patch              The number of the patch - in order
%                                           from top left, rows first
%                   .num                Which number, within a repetition this
%                                           drift was
%                   .direction          In degrees, with 0 being upward movement, increasing CW
%                   .startTime          Relative time, in seconds, since the
%                                           start of the experiment, that the
%                                           state started to be shown
%                   .endTime            Relative time, in seconds, since the
%                                           start of the experiment, that the
%                                           state stopped being shown
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

masktex=patchgrid(q, stimulusInfo); % Patch Overlay Generation

%% Stimulus Execution
%grey background
Screen('Rect', q.window);

%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime = toc;

%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
idx=0;
try
    for repeat = 1:q.repeats
        for patch = 1:stimulusInfo.nPatches
            %% Run by dead reckoning
            for d=1:q.directionsNum
                idx=idx+1;
                %Record absolute and relative stimulus start time
                stimulusInfo.stimuli(idx).startTime = toc;
                stimulusInfo.stimuli(idx).type='Drift';
                thisDirection = stimulusInfo.stimuli(idx).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
                for frameCount= 1:DG_DirectionFrames;
                    %Define shifted srcRect that cuts out the properly shifted rectangular
                    %area from the texture:
                    xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                    srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                    
                    %Draw grating texture, rotated by "angle":
                    Screen('DrawTexture', q.window, q.gratingtex, srcRect, [], thisDirection);
                    %Overdraw the alpha mask
                    Screen('DrawTexture', q.window, masktex(stimulusInfo.stimuli(idx).patch));
                    
                    %overdraw the photodiode rectangle if it is of finite size (i.e.
                    %wanted)
                    if q.photoDiodeRect(2)
                        if d==1
                            Screen('FillRect', q.window, 255,q.photoDiodeRect )
                        else
                            Screen('FillRect', q.window, 0, q.photoDiodeRect)
                        end
                    end
                    
                    %push to screen
                    Screen('Flip',q.window);
                    %Record measured stimulus display time
                    stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).endTime = toc;
                end
            end
            
          
            while ~inputSingleScan(q.input) %~getvalue(q.input)
                Screen('FillRect', q.window, 0);
                %push to screen
                Screen('Flip',q.window);
                %Quit if 'esc' key was pressed; advance if 't' key pressed
                [~, ~, keyCode] = KbCheck;
                if keyCode(KbName('escape')), error('escape')
                elseif keyCode(KbName('t')), break
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