function stimulusInfo = RFNoiseMapping(q)
% This function displays white or black squares, 7.8 degrees wide, on a gray
% background, to cover 120 positions in a 12 x 10 matrix. Presentation is
% in random order.
% This method follows the protocol used by Iacaruso et al. 2017 Nature doi:10.1038/nature23019
%
%
% Inputs:
%
%   q - structure with all parameters entered in to or calculated in
%   VisStimAlex
%
% Ouput:
stimulusInfo=setstimulusinfobasicparams(q);
stimulusInfo=generateSparseMappingStimuli(q,stimulusInfo);

Screen('FillRect', q.window, 0); %fill with black as a signal for the diode
Screen('Flip', q.window);
%KbWait();                   %Wait for keypress to start
WaitSecs(1);

Screen('FillRect', q.window, 127); %fill with grey
Screen('Flip', q.window);
tic        %start the timer
WaitSecs(q.baseLineTime) %and wait during baseline
% stimulusInfo.actualBaseLineTime=toc;
% q.nSpots=2*q.nStimFramesMapping;
% q.DotLocation = datasample(0:q.nSpots-1,q.nSpots,'Replace',false); % draw q.nSpots unique elements in random order, use to set positions of white or black squares
% %0:119 correspond to locations of white dots for q.nStimFramesMapping = 120
% %120:239 correspond to locations of black dots
% 
% stimulusInfo.spotColors = cell(q.nSpots, 1);  % 0 for black, 1 for white
% stimulusInfo.whiteXIndex = zeros (q.nSpots,1); % whiteXIndex is column number between 0:11 if spot is white, -1 otherwise
% stimulusInfo.whiteYIndex = zeros (q.nSpots,1); % whiteYIndex is row number between 0:9 if spot is white, -1 otherwise
% stimulusInfo.blackXIndex = zeros (q.nSpots,1); % blackXIndex is column number if spot is black, -1 otherwise
% stimulusInfo.blackYIndex = zeros (q.nSpots,1); % blackYIndex is row number if spot is black, -1 otherwise
% for i=1:q.nSpots
%     if q.DotLocation(i)<=119
%         stimulusInfo.spotColors{i}=[1;1;1];
%         stimulusInfo.whiteXIndex(i) = mod(q.DotLocation(i),12);
%         stimulusInfo.whiteYIndex(i) = floor(q.DotLocation(i)/12);
%         stimulusInfo.blackXIndex(i) = -1;
%         stimulusInfo.blackYIndex(i) = -1;
%         spotBounds(i, :)=[295+stimulusInfo.whiteXIndex(i)*108, stimulusInfo.whiteYIndex(i)*108, 295+(stimulusInfo.whiteXIndex(i)+1)*108, (stimulusInfo.whiteYIndex(i)+1)*108];
%         stimulusInfo.stimuliSp{i}=spotBounds(i, :);
%     else
%         stimulusInfo.spotColors{i}=[0;0;0];
%         stimulusInfo.whiteXIndex(i) = -1;
%         stimulusInfo.whiteYIndex(i) = -1;
%         stimulusInfo.blackXIndex(i) = mod(q.DotLocation(i)-120,12);
%         stimulusInfo.blackYIndex(i) = floor((q.DotLocation(i)-120)/12);
%         spotBounds(i, :)=[295+stimulusInfo.blackXIndex(i)*108, stimulusInfo.blackYIndex(i)*108, 295+(stimulusInfo.blackXIndex(i)+1)*108, (stimulusInfo.blackYIndex(i)+1)*108];
%         stimulusInfo.stimuliSp{i}=spotBounds(i, :);
%     end
% end

for i=1:2*q.nStimFramesMapping;
    
    Screen('FillRect', q.window, 127);
    Screen('FillRect', q.window,stimulusInfo.spotColors{i}*255,stimulusInfo.stimuliSp{i}')
    Screen('Flip', q.window);
    stimulusInfo.stimuli(i).startTime=toc;
    for delay=2:round(q.spotTime/q.ifi)         %Wait the requested time by calculating the correct
        Screen('FillRect', q.window, 127);      %number of screen flips, and executing them.
        Screen('FillRect', q.window, stimulusInfo.spotColors{i}*255,stimulusInfo.stimuliSp{i}')
        Screen('Flip', q.window);       
    end     
    stimulusInfo.stimuli(i).endTime=toc;
    for holdFrames =1:round(q.postSpotGrayTime/q.ifi)
        Screen('FillRect', q.window, 127);
        Screen('Flip', q.window);
    end
    %Quit only if 'esc' key was pressed
    [~, ~, keyCode] = KbCheck;
    if keyCode(KbName('escape')), error('escape'), end
end

Screen('FillRect', q.window, 0); %fill with black as a signal for the diode
Screen('Flip', q.window);
stimulusInfo.experimentEndTime=toc;
WaitSecs(1);