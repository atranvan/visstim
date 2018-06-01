function stimulusInfo = sparseNoise(q)
% This function displays a sparse noise retinotopy stimulus, untriggered
%
% Inputs:
%
%   q - structure with all parameters entered in to or calculated in
%   VisStimAlex
%
% Ouput:
stimulusInfo=setstimulusinfobasicparams(q);
stimulusInfo=generateSparseStimuli(q,stimulusInfo);

Screen('FillRect', q.window, 0); %fill with black as a signal for the diode
Screen('Flip', q.window);
%KbWait();                   %Wait for keypress to start
WaitSecs(1);

Screen('FillRect', q.window, 177.5); %fill with grey
Screen('Flip', q.window);
tic        %start the timer
WaitSecs(q.baseLineTime) %and wait during baseline
stimulusInfo.actualBaseLineTime=toc;

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
            if delay == 2
                Screen('FillRect', q.window, 255,q.photoDiodeRect )
            else
                Screen('FillRect', q.window, 0,q.photoDiodeRect )
            end
        end
        Screen('Flip', q.window);       
    end     
    stimulusInfo.stimuli(i).endTime=toc;
    %Quit only if 'esc' key was pressed
    [~, ~, keyCode] = KbCheck;
    if keyCode(KbName('escape')), error('escape'), end
end

Screen('FillRect', q.window, 0); %fill with black as a signal for the diode
Screen('Flip', q.window);
stimulusInfo.experimentEndTime=toc;
WaitSecs(1);