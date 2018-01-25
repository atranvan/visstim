
function stimulusInfo = flipStimulus(q)
% function FLIPSTIMULUS flashes a white screen then a black screen for
% maximal stimulation. For use in testing or trying to evoke big responses
%
% Inputs:
%
%   q
%
% Output:
%
%  stimulusInfo
%       .experimentType         'Flip'
%       .triggering             'off'
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .repeats
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .state                  'white' or 'black'
%                   .startTime              relative time, in seconds, since
%                                           the start of the experiment, that
%                                           the state started to be shown
%                   .endTime                relative time, in seconds, since
%                                           the start of the experiment,
%                                           that the state stopped being
%                                           shown
%
%

%---------------------------Initialisation--------------------------------
% Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);

%-------------------------------------------------------------------------

%Start the clock & record absolute clock start time
stimulusInfo.experimentStartTime = now;
tic;
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime=toc;
try
for i = 1:q.repeats * 2
    stimulusInfo.stimuli(i).startTime = toc;
    %Display the screen
    for j = 1:(q.flipTime*q.hz)
        Screen('FillRect', q.window, 255*(mod(i, 2)));
        Screen('Flip',q.window);
        stimulusInfo.stimuli(i).endTime = toc;
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
