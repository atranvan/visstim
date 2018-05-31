function stimulusInfo = setstimulusinfostimuli(stimulusInfo, q)
%SETSTIMULUSINFOSTIMULI Adds stimuli struct to the stimulusInfo struct.
% 2017-03-31 modified by ATVM to add Plaid stimulus and DriftGray
% stimulus
switch q.experimentType
    case 'Flip'
        %Preallocate
        stimulusInfo.stimuli = struct('state', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats*2).state =[];
        for i =1:2:length(stimulusInfo.stimuli)
            stimulusInfo.stimuli(i).state = 'white';
            stimulusInfo.stimuli(i+1).state = 'black';
        end
    case 'fsPulse'
        %Preallocate
        stimulusInfo.stimuli = struct('state', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats*2).state =[];
        for i =1:2:length(stimulusInfo.stimuli)
            stimulusInfo.stimuli(i).state = 'black';
            stimulusInfo.stimuli(i+1).state = 'gray';
        end
    case 'fsLum'    
        stimulusInfo.stimuli = struct('state', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats*q.lumNum*2).state =[];
        switch q.randMode
            case 0  % Orderly progression of luminance (dark to bright)
                for repeat = 1:q.repeats
                    for d=1:q.lumNum
                        stimulusInfo.stimuli((repeat-1)*q.lumNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat-1)*q.lumNum + d).num = d;
                        if q.baselineLum == 0
                            stimulusInfo.stimuli((repeat-1)*q.lumNum + d).lum = d*q.white/q.lumNum; % just dump in the luminance in order, starting from the first one after 0
                        else
                            stimulusInfo.stimuli((repeat-1)*q.lumNum + d).lum = (d-1)*q.white/(q.lumNum-1);% just dump in the luminance in order, starting from 0
                        end
                    end
                end
            case 1  % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.lumNum);
                if q.baselineLum == 0
                    lumOrder = (order) * q.white/q.lumNum;
                else
                    lumOrder = (order-1)*q.white/(q.lumNum-1);
                end
                for repeat = 1:q.repeats
                    for d=1:q.lumNum
                        stimulusInfo.stimuli((repeat-1)*q.lumNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat-1)*q.lumNum + d).num = d;
                        stimulusInfo.stimuli((repeat-1)*q.lumNum + d).lum = lumOrder(d); % assign the appropriate luminance
                    end
                end
            case 2  % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.lumNum);
                    if q.baselineLum == 0
                        lumOrder = (order) * q.white/q.lumNum;
                    else
                        lumOrder = (order-1)*q.white/(q.lumNum-1);
                    end
                    for d=1:q.lumNum
                        stimulusInfo.stimuli((repeat -1)*q.lumNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.lumNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.lumNum + d).lum = lumOrder(d); % assign the appropriate luminance
                    end
                end
            case 3  % choose maximally different stimuli
                order = maximallyDifferentDirections(q.lumNum);
                if q.baselineLum == 0
                    lumOrder = (order) * q.white/q.lumNum;
                else
                    lumOrder = (order-1)*q.white/(q.lumNum-1);
                end
                for repeat = 1:q.repeats
                    for d=1:q.lumNum
                        stimulusInfo.stimuli((repeat -1)*q.lumNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.lumNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.lumNum + d).lum = lumOrder(d); % assign the appropriate luminance
                    end
                end
                
    case 'D'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
            case 3 % choose maximally different stimuli
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
        end
    case 'DH'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
    case 'DG'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
    case 'HD'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
    case 'HDH'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*3).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = (d-1)*360/q.directionsNum;
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
        
    case 'HDHG'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*3).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = (d-1)*360/q.directionsNum;
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
        
    case 'HDRDHG'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*3).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = (d-1)*360/q.directionsNum;
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
      
        case 'HDSRHG'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*3).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = (d-1)*360/q.directionsNum;
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end    
    case 'SrDG'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*3).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = (d-1)*360/q.directionsNum;
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end    
    case 'HPHG'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*3).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = (d-1)*360/q.directionsNum;
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end    
    case 'P'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
            case 3 % choose maximally different stimuli
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
        end
        case 'PG'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
        case 'SpotRet'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
    case 'Ret'
        nPatches = q.patchGridDimensions(1)*q.patchGridDimensions(2);
        
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'patch', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum * nPatches).type=[];
        
        % This switch structure preloads patch identity
        patches = zeros(nPatches*q.repeats, 1);
        switch q.retinotopyRandMode
            case 0 %orderly progression of patches
                for i = 1:q.repeats
                    patches(((i-1)*nPatches +1): i*nPatches) = 1:nPatches;
                end
            case 1 %pseudorandom repeated
                O=randperm(nPatches);
                for i = 1:q.repeats
                    patches(((i-1)*nPatches +1): i*nPatches)= O;
                end
            case 2 %pseudorandom
                patches = zeros(nPatches*q.repeats, 1);
                for i = 1:q.repeats
                    patches(((i-1)*nPatches +1): i*nPatches) = randperm(nPatches);
                end
            case 3
                for i = 1:q.repeats
                    patches(((i-1)*nPatches +1): i*nPatches) = maximallyDifferentDirections(nPatches);
                end
        end
        
        
        patches =imresize(patches, [length(patches)*q.directionsNum, 1], 'nearest'); % duplicate for all directions
        
        % This switch structure preloads direction identity
        dirsN=zeros(q.directionsNum*nPatches*q.repeats, 1);
        switch q.randMode
            case 0 %orderly progression of directions
                d=1:q.directionsNum;
                for i=1:q.directionsNum:length(dirsN)
                    dirsN(i:i+q.directionsNum-1) = d;
                end
            case 1 %pseudorandom repeated
                d= randperm(q.directionsNum);
                for i=1:q.directionsNum:length(dirsN)
                    dirsN(i:i+q.directionsNum-1) = d;
                end
            case 2 %pseudorandom
                for i=1:q.directionsNum:length(dirsN)
                    d= randperm(q.directionsNum);
                    dirsN(i:i+q.directionsNum-1) = d;
                end
            case 3 %max diff
                d= maximallyDifferentDirections(q.directionsNum);
                for i=1:q.directionsNum:length(dirsN)
                    dirsN(i:i+q.directionsNum-1) = d;
                end
        end
        directions = (dirsN-1)*(360/q.directionsNum);
        
        % and assign
        idx = 0;
        for repeat = 1:q.repeats
            for patch=1:nPatches
                for d=1:q.directionsNum
                    idx=idx+1;
                    stimulusInfo.stimuli(idx).repeat = repeat;
                    stimulusInfo.stimuli(idx).patch = patches(idx);
                    stimulusInfo.stimuli(idx).num = d;
                    stimulusInfo.stimuli(idx).direction = directions(idx); % just dump in the angles in order, starting from 0
                end
            end
        end
    case 'freqTuning'
        
        s=q.spaceFreqDeg;
        t=q.tempFreq;
        
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', [], 'spaceFreqDeg', [], 'tempFreq', []);
        stimulusInfo.stimuli(q.repeats * length(s)*length(t)*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for ii=1:length(s)
                        for jj=1:length(t)
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = q.directionForFreqTuning;
                        stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg = s(ii);
                        stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq = t(jj);
                        stimulusInfo.stimuli(currentStimIndex*2+1).num=[find(t==stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq)...
                                                                            find(s==stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg)];
                            
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = q.directionForFreqTuning;
                        stimulusInfo.stimuli(currentStimIndex*2+2).spaceFreqDeg = s(ii);
                        stimulusInfo.stimuli(currentStimIndex*2+2).tempFreq = t(jj);
                        stimulusInfo.stimuli(currentStimIndex*2+1).num=[find(t==stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq)...
                                                                            find(s==stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg)];
                            
                        currentStimIndex = currentStimIndex + 1;
                        end
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                [sGrid, tGrid]=meshgrid(s, t);
                order = randperm(length(s)*length(t));
                for repeat = 1:q.repeats
                    for ii=1:length(s)
                        for jj=1:length(t)
                            theseConditionsIdx=order(mod(currentStimIndex, length(s)*length(t))+1);
                            stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                            stimulusInfo.stimuli(currentStimIndex*2+1).direction = q.directionForFreqTuning; % assign the appropriate direction
                            stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg = sGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq = tGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+1).num=[find(t==stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq)...
                                                                            find(s==stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg)];
                            
                            stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                            stimulusInfo.stimuli(currentStimIndex*2+2).direction = q.directionForFreqTuning;
                            stimulusInfo.stimuli(currentStimIndex*2+2).spaceFreqDeg = sGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+2).tempFreq = tGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+2).num=[find(t==stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq)...
                                                                            find(s==stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg)];
                            
                            currentStimIndex = currentStimIndex + 1;
                        end
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                [sGrid, tGrid]=meshgrid(s, t);
                for repeat = 1:q.repeats;
                    order = randperm(length(s)*length(t));
                    for ii=1:length(s)
                        for jj=1:length(t)
                            theseConditionsIdx=order(mod(currentStimIndex, length(s)*length(t))+1);
                            stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                            stimulusInfo.stimuli(currentStimIndex*2+1).direction = q.directionForFreqTuning; % assign the appropriate direction
                            stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg = sGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq = tGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+1).num=[find(t==stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq)...
                                                                            find(s==stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg)];
                            
                            stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                            stimulusInfo.stimuli(currentStimIndex*2+2).direction = q.directionForFreqTuning;
                            stimulusInfo.stimuli(currentStimIndex*2+2).spaceFreqDeg = sGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+2).tempFreq = tGrid(theseConditionsIdx);
                            stimulusInfo.stimuli(currentStimIndex*2+2).num=[find(t==stimulusInfo.stimuli(currentStimIndex*2+1).tempFreq)...
                                                                            find(s==stimulusInfo.stimuli(currentStimIndex*2+1).spaceFreqDeg)];
                            currentStimIndex = currentStimIndex + 1;
                        end
                    end
                end
            case 3
                error('Maximally Different mode not supported for frequency tuning')
        end
end

end

