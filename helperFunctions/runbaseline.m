function runbaseline(q, stimulusInfo)
%RUNBASELINE Displays a black screen during baseline. 
%
% For both triggere AND untriggered mode 
%
% Untriggered: calculates number of frames by dead reckoning
% and displays for that amount of time.
% Only bother doing this if there IS a baseline requested
%
% Triggered mode: displays a black screen or gray screen (color defined in VisStim via baseLineColor), until trigger
switch q.triggering
    case 'off'
        if q.baseLineTime
            if q.fid>-1
                fprintf(q.fid, 'Running baseline...');
            end
            for i = 1:floor(stimulusInfo.baseLineSFrames)
                Screen('FillRect', q.window, q.baseLineColor);
                Screen('Flip',q.window);
                %Quit only if 'esc' key was pressed
                [~, ~, keyCode] = KbCheck;
                if keyCode(KbName('escape')), error('escapeBsl'), end
            end
            if q.fid>-1
                fprintf(q.fid, 'Complete.\nBeginning stimulus...\n');
            end
        end
    case {'on', 'toBegin'}
        
        if q.fid>-1
            fprintf(q.fid, 'Running baseline...');
        end
            
        % Display a black or gray screen
        Screen('FillRect', q.window, q.baseLineColor);
        Screen('Flip',q.window);
        if q.fid>-1
            fprintf(q.fid, '\nReady for trigger to begin stimulus...');
        end
        while ~inputSingleScan(q.input)%~getvalue(q.input)
            %Quit only if 'esc' key was pressed, advance if 't' was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escapeBsl'), end
            if keyCode(KbName('t')) 
                %wait for keypress to end (=key up) before breaking
                while KbCheck
                end
                break
            end
        end
        if q.fid>-1
            fprintf(q.fid, 'Receieved\nBeginning stimulus...');
        end
end
end


