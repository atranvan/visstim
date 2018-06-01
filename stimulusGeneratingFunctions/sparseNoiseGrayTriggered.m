function stimulusInfo = sparseNoiseGrayTriggered(q)
% This function displays a sparse noise retinotopy stimulus, followed by a gray screen, untriggered
%
% Inputs:
%
%   q - structure with all parameters entered in to or calculated in
%   VisStimAlex
%       .spotSizeMean
%       .spotSizeRange
%       .spotNumberMean  
%       .spotNumberStd
%       .spotTime
%       .grayTime
%       .nStimFrames
%
% Ouput:
%       .experimentType         'spnG'
%       .triggering             'on'
%       .experimentEndTime      experiment duration
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuliSp
%       .spotSizes
%       .spotColors

%---------------------------Initialisation--------------------------------
q.input = initialisedio(q); 
[DG_SpatialPeriod, DG_ShiftPerFrame, DG_DirectionFrames] = getDGparams(q);
stimulusInfo=setstimulusinfobasicparams(q);
stimulusInfo=generateSparseStimuli(q,stimulusInfo);

Screen('FillRect', q.window, 0); %fill with black as a signal for the diode
Screen('Flip', q.window);
%KbWait();                   %Wait for keypress to start
WaitSecs(1);

Screen('FillRect', q.window, 177.5); %fill with grey
Screen('Flip', q.window);
% tic        %start the timer
% WaitSecs(q.baseLineTime) %and wait during baseline
% stimulusInfo.actualBaseLineTime=toc;

stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo);
stimulusInfo.actualBaseLineTime = toc;
try
    for i=1:q.nStimFrames;
        %[r,c,v]=find(stimulusInfo.stimuliSp(:,:,i));
        %v=convertSpotStateGreyscale(v)';
        %v=cat(1, v, v, v);
        
        Screen('FillRect', q.window, 177.5);
        %Screen('FillOval', q.window,stimulusInfo.spotColors{i}*255,stimulusInfo.stimuliSp{i}')
        Screen('FillRect', q.window,stimulusInfo.spotColors{i}*255,stimulusInfo.stimuliSp{i}')
        Screen('Flip', q.window);
        stimulusInfo.stimuli(i).startTime=toc;
        for delay=2:round(q.spotTime/q.ifi)         %Wait the requested time by calculating the correct
            Screen('FillRect', q.window, 177.5);      %number of screen flips, and executing them.
            Screen('FillOval', q.window, stimulusInfo.spotColors{i}*255,stimulusInfo.stimuliSp{i}')
            %Screen('FillRect', q.window, stimulusInfo.spotColors{i}*255,stimulusInfo.stimuliSp{i}')
            if q.photoDiodeRect(2)
                Screen('FillRect', q.window, 255,q.photoDiodeRect )
            end
            Screen('Flip', q.window);
        end
        
        while inputSingleScan(q.input)
            Screen('FillRect', q.window, 177.5);
            if q.photoDiodeRect(2)
                Screen('FillRect', q.window, 0,q.photoDiodeRect )
            end
            Screen('Flip', q.window);
            stimulusInfo.stimuli(i).endTime=toc;
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

Screen('FillRect', q.window, 0); %fill with black as a signal for the diode
Screen('Flip', q.window);
stimulusInfo.experimentEndTime=toc;
WaitSecs(1);