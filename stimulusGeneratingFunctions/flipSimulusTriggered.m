function stimulusInfo = flipSimulusTriggered(q)
% function FLIPSTIMULUS flashes a white screen then a black screen for
% maximal stimulation. For use in testing or trying to evoke big responses
%
% n.b. as this is a triggered function, it does not need a baseline time or
% flipTime, as this is provided by the trigger. Black and white are the
% same duration, so here a 'cycle' is ONE state - black or white. Therefore
% the trigger frequency on the imaging computer corresponds to how long any
% ONE state will be displayed for.
%
% Inputs:
%
%   q
%
% Outputs:
%
%  stimulusInfo
%       .experimentType         'Flip'
%       .triggering             'on'
%       .q.repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m  struct array:
%           m = repeat * 2 - a complete list of states
%                   .state                  'white' or 'black'
%                   .startTime              relative time, in seconds, since
%                                           the start of the experiment, that
%                                           the state started to be shown
%                   .endTime                relative time, in seconds, since
%                                           the start of the experiment,
%                                           that the state stopped being
%                                           shown

%----------------------Initialisations-------------------------------------
% Initialise National Instrument card for triggering
q.input=initialisedio(q);


% Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);
%--------------------------------------------------------------------------

% start experiment clock
stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime=toc;

try
    for i = 1:q.repeats*2
        stimulusInfo.stimuli(i).startTime = toc;
        
        % Loop until the input is low (i.e. the previous trigger has ended)
        % then loop till it's high (a new trigger)
        
        Screen('FillRect', q.window, (255*mod(i, 2)));
        while inputSingleScan(q.input) %getvalue(q.input)
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
        
        
        while ~inputSingleScan(q.input) %~getvalue(q.input)
            Screen('Flip',q.window);
            stimulusInfo.stimuli(i).endTime = toc;
            
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
catch err
    if ~strcmp(err.message, 'escape')
        rethrow (err)
    end
end
end


