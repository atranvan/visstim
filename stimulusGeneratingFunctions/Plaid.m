function stimulusInfo =  Plaid(q)
% PLAID displays a moving plaid (2 overlaid gratings), angle between two
% gratings determined by plaidAngle parameters (in degree, default = 90)
%
% Inputs:
%
%   q
%
% Ouput:
%   stimulusInfo
%       .experimentType         'P'
%       .triggering             'off'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .directionsNum          Number of different directions displayed
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .type           'Drift'
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
[DG_SpatialPeriod, DG_ShiftPerFrame, DG_DirectionFrames] = getDGparams(q);

%Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);

%--------------------------------------------------------------------------
% This is kind of a workaround to superimpose two sets of gratings
% blending the default gratings (as generated in Drift) would look like the
% white bars are summed
stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime = toc;
Priority(MaxPriority(q.window));                           % Needed to ensure maximum performance

white = WhiteIndex(max(Screen('Screens')));
black = BlackIndex(max(Screen('Screens')));
grey = white / 2;
gplaid=grey+grey*GratingAlex(q.gratingType,(q.screenRect(1)+1:q.screenRect(3)*q.gratingTextureSize), (q.screenRect(2)+1:q.screenRect(4)*q.gratingTextureSize), 0, q.spaceFreqPixels);
plaidgrating=ones(length(q.screenRect(2)+1:q.screenRect(4)*q.gratingTextureSize),length(q.screenRect(1)+1:q.screenRect(3)*q.gratingTextureSize), 2) * black;

plaidgrating(:, :, 2)= gplaid.* 1;
if ndims(gplaid)>2&&size(gplaid, 3)>1
    for ii=1:size(g, 3)
        gratingtex(ii)=Screen('MakeTexture', q.window, squeeze(plaidgrating(:,:,ii)));
    end
else
    gratingtex=Screen('MakeTexture', q.window, plaidgrating);
end
%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
Screen('FillRect',q.window,WhiteIndex(max(Screen('Screens'))));
try
    for repeat = 1:q.repeats
        for d=1:q.directionsNum
            %Record absolute and relative stimulus start time
            stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).startTime = toc;
            stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).type='Drift';
            thisDirection = stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
            for frameCount= 1:DG_DirectionFrames;
                %Define shifted srcRect that cuts out the properly shifted rectangular
                %area from the texture:
                xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                
                %Draw grating texture, rotated by "angle":
                
                Screen('DrawTexture', q.window, gratingtex, srcRect, [], thisDirection);
                Screen('DrawTexture', q.window, gratingtex, srcRect, [], thisDirection+q.plaidAngle); % second grating is rotated by value in plaidAngle in degrees

                if q.photoDiodeRect(2)
                    if frameCount == 1
                        Screen('FillRect', q.window, 255,q.photoDiodeRect )
                    else
                        Screen('FillRect', q.window, 0,q.photoDiodeRect )
                    end
                end
                Screen('Flip',q.window);
                %Record measured stimulus display time
                stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).endTime = toc;
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