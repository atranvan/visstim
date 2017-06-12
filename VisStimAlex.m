% Visual Stimulation Script - Alex Brown
% 2017-03-31 modified by Alex Tran-Van-Minh to add Plaid stimulus
% and DriftGray stimulus
%
% Adapted from Bruno Pichler's Grating Script

function [stimulusInfo, filePath] = VisStimAlex(varargin)
%% --------------------------------- Setup---------------------------------
% Creates input parser
p=inputParser;
% Sets rand seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
%% ------------------------ Program  Setup ---------------------------------

% Whether or not to wait for keypresses at the beginning and end. Default
% is not to (0)
p.addParamValue('keyWait', 0)

% Whether or not to clear the screen at the end. Default is yes (1)
p.addParamValue('screenClear', 1)
%% --------------- Configuration Variables ---------------------------------


%%%%Experiment mode%%%%%%
% If you leave all configuration parameters alone, you can switch what
% stimulus you are using by specifying mode here.
%
% Flip: Screen flips between a total white rectangle and blackness. Useful
%       for maximal stimulation and assessing optical noise
% D:    Dynamic grating of fixed spatial and temporal frequency (specified as
%       parameters below) but changing orientation.
%       randomisation mode and number of repeats in each run
% DH:   Dynamic grating followed by a hold, both at the same orientation,
%       then on to the next orientation
% HDH:  Hold then dynamic then hold, all at the same orientation, then on
%       to the next orientation.
% Ret: Retinotopy stimulus

% freqTuning: spatiotemporal tuning (HD)
% P : Plaid
% DG: Dynamic grating followed by a gray screen
% PG: Plaid followed by a gray screen

p.addParamValue('experimentType', 'fsPulse');
 
% testing mode:
%0 turns off testing mode (assumes DAQ toolbox present, running on windows)
%1 turns testing mode on - do not initialise DIO. Requires a function called
%    getvalue to simulate trigger input (simple version just returns true every
%    n seconds). This can just be false all the time too - in which case
%    trigger only works by keypresses.
%2 as 1, but with more verbose output from PTB
p.addParamValue('testingMode', 0)

% If triggering is 'off', the stimulus will be generated by timings specified
% below. If it is 'on', state changes will occur on a trigger from the
% acquisition computer. Triggers only occur once per cycle, so state
% changes within a cycle (e.g. drift -> hold in DH) are carried out after a
% specified time. See individual functions for more details.
%
% 'toBegin' - triggering begins the stimuli, but they then run untriggered

p.addParamValue('triggering','on');% 'toBegin');


% photoDiode 'on' will display a patch for photodiode readout. 'off' means
% no patch will be displayed
p.addParamValue('photoDiode', 'off');

% add a default save path. This is safest. All timestamped stimulus files
% will be saved here. To save a different directory, pass that directory
% in. To suppress saving, pass an empty string ('')
p.addParamValue('filePath', 'C:\Users\ranczLab\Documents\MATLAB\visstim\stimfiles')

% add a status file path. This allows VisStimAlex to output its current
% status to a text file, for remote monitoring

p.addParamValue('statusFilePath', 'C:\Users\ranczLab\Documents\MATLAB\visstim\stimstatus')


% Grating parameters:
p.addParamValue('gratingType', 1);                           % 0 creates sine grating, 1 creates square wave grating
p.addParamValue('spaceFreqDeg',0.08);                        % spatial frequency in cycles / degree
p.addParamValue('tempFreq',1);                               % temporal frequency in Hz
p.addParamValue('directionsNum',8);                          % Number of different directions to display

%Run parameters
p.addParamValue('baseLineTime',0);
p.addParamValue('repeats', 100);                             % Number of repeats within each run
p.addParamValue('randMode', 3);                              % Randomisation of stimulus order. (not applicable to Flip)
%             0 = orderly presentation (not recommended).
%             1 = random permutation, kept constant throughout one run
%             2 = new random permutation on each repetition
%             3 = maximally different directions

% Experiment type specific parameters
p.addParamValue('preDriftHoldTime', 2);                       % How long to hold the grating for, in seconds, before a drift
p.addParamValue('driftTime', 0.5);                            % How long to display a drifting grating for
p.addParamValue('postDriftHoldTime', 4);                      % How long to hold the grating for, in seconds, after a drift
p.addParamValue('flipTime', 0.5);                             % How long each state (white or black) should be displayed for in flipStimulus
p.addParamValue('postDriftGrayTime', 4);                      % How long to display gray screen for, in seconds, after a drift
p.addParamValue('plaidAngle', 90);                            % angle between two components of a plaid
p.addParamValue('lumscreen', 128);                            % luminance of gray screen for fullscPulse stimulus
p.addParamValue('blackscreenTime',4);                         % How long to display a black screen for fullscPulse stimulus
p.addParamValue('pulsescreenTime',0.5);                       % How long to display a gray screen for fullscPulse stimulus

% Screen parameters:
p.addParamValue('screenWidthCm', 56);                         % screen size in cm
p.addParamValue('mouseDistanceCm', 10);                       % mouse distance from the screen im cm

% Photodiode indicator patch settings
p.addParamValue('diodePatchXSize', 100);
p.addParamValue('diodePatchYSize', 100);

% Baseline parameters
p.addParamValue('startBsl',10);
p.addParamValue('endBsl',10);

% Retinotopy parameters
p.addParamValue('retinotopyType', 'D');                          %Which type of retinotopy to run:
%D = drifts
%Flip = flips
p.addParamValue('retinotopyRandMode', 0);                       % Same as randMode, but for the order of patch presentation
p.addParamValue('patchGridX', 3);
p.addParamValue('patchGridY', 3);
p.addParamValue('postPatchPause', 1)                            % How long, in seconds, to leave after a patch. Has no effect on stimulus generation but is used by 2p triggering (Alex)
p.addParamValue('patchSubset', [1 1 1;1 1 1;1 1 1])
% Sparse Noise parameters
p.addParamValue('spotSizeMean', 20);
p.addParamValue('spotSizeRange', 5);
p.addParamValue('spotNumberMean', 8);
p.addParamValue('spotNumberStd', 1);
p.addParamValue('spotTime', 1);
p.addParamValue('nStimFrames', 300);
p.addParamValue('spotFrame', [0 0 1 1]);  % [l t r b] 
% Frequency tuning
p.addParamValue('directionForFreqTuning', 160)
%% --------------- System Parameters ---------------
% There should not, normally, be any reason for these to be changed.

p.addParamValue('gratingTextureSize', 4) %The factor by which to enlarge gratings, relative to the size of the screen

%NI card parameters
p.addParamValue('inputLine', 7);
p.addParamValue('inputPort', 0);
p.addParamValue('deviceName','Dev2');
KbName('UnifyKeyNames')                 %Needed for cross-platform compatibility
%% --------------------Parse Inputs------------------------------------------
% q is a struct containing all inputted or default parameters
try
    p.parse(varargin{:});
    q = p.Results;
    q.patchGridDimensions=[q.patchGridX q.patchGridY];
catch err
        clear mex
        rethrow(err)
end

%% Open status file, and write status
if ~isempty(q.statusFilePath)
    q.fid=fopen(q.statusFilePath, 'w');
    fprintf(q.fid, 'MATLAB initialised. Beginning PTB initialisation...');
else
    q.fid=-1;
end

%% -------------------Start PTB ------------------------------------------
try
    if q.testingMode > 1
        Screen('Preference', 'verbosity', 4);
    else
        Screen('Preference', 'verbosity', 2);
    end
    if strcmp(q.experimentType, 'spn')
        [q.window,q.screenRect,q.ifi]=initScreen(5); %Returns a handle to the active screen, a rectangle representing size,
        
    else
        [q.window,q.screenRect,q.ifi]=initScreen; %Returns a handle to the active screen, a rectangle representing size,
    end
catch
    clear mex
    fprintf('PTB Init failure \n')
    if q.fid>-1;fprintf(q.fid, 'Failed\n');fclose(q.fid);end
    return
end
% Output status to status file
if q.fid>-1
    fprintf(q.fid, 'Success!\nBeginning ');
    if strcmpi(q.triggering, 'on')
        fprintf(q.fid, 'triggered');
    elseif strcmpi(q.triggering, 'of')
        fprintf(q.fid, 'untriggered');
    elseif strcmpi(q.triggering, 'toBegin')
        fprintf(q.fid, 'trigToBegin');
    end
    fprintf(q.fid, ' %s experiment.\n', q.experimentType);
end
%% --------------- Calculated Properties ---------------

% Screen & Distance
% screenCenter = [(screenRect(3)-screenRect(1)) (screenRect(4)-screenRect(2))]/2; %Screen Centre in pixels
q.pixelsPerCm = q.screenRect(3) / q.screenWidthCm;             % Scaling factor for conversion between pixels and cm
q.mouseDistancePixels = q.mouseDistanceCm .*q.pixelsPerCm;    % Convert the mouse distance from the screen in to pixels

q.spaceFreqPixels=zeros(size(q.spaceFreqDeg));
for ii=1:length(q.spaceFreqDeg)
q.spaceFreqPixels(ii) = 1 / (2* q.mouseDistancePixels * tan((1 / q.spaceFreqDeg(ii)) * pi / 180 / 2));
end
q.hz = 1/q.ifi;                                             % Screen flip frequency

%Photodiode display area
if strcmp(q.photoDiode, 'on')
    q.photoDiodeRect = [0 q.screenRect(4)-q.diodePatchYSize q.diodePatchXSize q.screenRect(4)];
else
    q.photoDiodeRect = [0 0 0 0];
end

%% --------------- The Program Itself ---------------


q.startTime=datestr(now, 'yyyy/mm/dd HH:MM:SS.FFF');       % Records start time
display(sprintf(strcat('\r----------------', q.startTime, '-------------------\r\r'))); %outputs start time
HideCursor;

Priority(MaxPriority(q.window));                           % Needed to ensure maximum performance
whichScreen = max(Screen('Screens'));
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
grey = white / 2;


Screen('FillRect', q.window,grey);                          % Grey Background for initialisation
Screen('Flip',q.window);

%Generate the grating itself
g=grey+grey*GratingAlex(q.gratingType,(q.screenRect(1)+1:q.screenRect(3)*q.gratingTextureSize), (q.screenRect(2)+1:q.screenRect(4)*q.gratingTextureSize), 0, q.spaceFreqPixels);

if ndims(g)>2&&size(g, 3)>1
    for ii=1:size(g, 3)
        q.gratingtex(ii)=Screen('MakeTexture', q.window, squeeze(g(:,:,ii)));
    end
else
    q.gratingtex=Screen('MakeTexture', q.window, g);
end
%Decide where we're going to save it
q.fileName = [datestr(now, 'yyyymmdd_HH_MM_SS'), '_', q.experimentType];

% We're ready. Wait for a keypress if we're in keyWait mode
if q.keyWait
    KbWait;
end
if q.fid>-1
    fprintf(q.fid, 'All preparations complete. Ready to begin\n');
end
%Choose which stimulus function to call based on whether triggering is on,
%and on experiment type
try
    switch q.triggering
        case 'off'
            switch q.experimentType
                case 'Flip'
                    stimulusInfo = flipStimulus(q);
                    stimulusInfo.flipTime = q.flipTime;
                case 'D'
                    stimulusInfo = Drift(q);
                    stimulusInfo.driftTime = q.driftTime;
                case 'DH'
                    stimulusInfo = DriftHold(q);
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.postDriftHoldTime = q.postDriftHoldTime;
                case 'HD'
                    stimulusInfo = HoldDrift(q);
                    stimulusInfo.preDriftHoldTime = q.preDriftHoldTime;
                    stimulusInfo.driftTime = q.driftTime;
                case 'HDH'
                    stimulusInfo = HoldDriftHold(q);
                    stimulusInfo.preDriftHoldTime = q.preDriftHoldTime;
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.postDriftHoldTime = q.postDriftHoldTime;
                case 'Ret'
                    stimulusInfo=RetinotopyDrift(q);
                case 'spn'
                    stimulusInfo=sparseNoise(q);
                case 'P'
                    stimulusInfo=Plaid(q);
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.plaidAngle=q.plaidAngle;
                case 'DG'
                    stimulusInfo=DriftGray(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                case 'PG'
                    stimulusInfo=PlaidGray(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.plaidAngle=q.plaidAngle;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                case 'fsPulse'
                    stimulusInfo=fullscreenPulse(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                    stimulusInfo.lumscreen=q.lumscreen;
                otherwise
                    error('Unsupported Mode')
            end
        case 'on'
            switch q.experimentType
                case 'Flip'
                    stimulusInfo = flipSimulusTriggered(q);
                    stimulusInfo.flipTime = q.flipTime;
                case 'D'
                    stimulusInfo = DriftTriggered(q);
                    stimulusInfo.driftTime = q.driftTime;
                case 'DH'
                    stimulusInfo = DriftHoldTriggered(q);
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.postDriftHoldTime = q.postDriftHoldTime;
                case 'HD'
                    stimulusInfo = HoldDriftTriggered(q);
                    stimulusInfo.preDriftHoldTime = q.preDriftHoldTime;
                    stimulusInfo.driftTime = q.driftTime;
                case 'HDH'
                    stimulusInfo = HoldDriftHoldTriggered(q);
                    stimulusInfo.preDriftHoldTime = q.preDriftHoldTime;
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.postDriftHoldTime = q.postDriftHoldTime;
                case 'P'
                    stimulusInfo=PlaidTriggered(q);
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.plaidAngle=q.plaidAngle;
                case 'Ret'
                    stimulusInfo=RetinotopyDriftTriggered(q);
                case 'DG'
                    stimulusInfo=DriftGrayTriggered(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                case 'PG'
                    stimulusInfo=PlaidGrayTriggered(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.plaidAngle=q.plaidAngle;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                case 'fsPulse'
                    stimulusInfo=fullscreenPulseTriggered(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                    stimulusInfo.lumscreen=q.lumscreen;
                otherwise
                   error('Unsupported Mode')
            end
        case 'toBegin'
            q.input =initialisedio(q);
            switch q.experimentType
                case 'Flip'
                    stimulusInfo = flipStimulus(q);
                    stimulusInfo.flipTime = q.flipTime;
                case 'D'
                    stimulusInfo = Drift(q);
                    stimulusInfo.driftTime = q.driftTime;
                case 'DH'
                    stimulusInfo = DriftHold(q);
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.postDriftHoldTime = q.postDriftHoldTime;
                case 'HD'
                    stimulusInfo = HoldDrift(q);
                    stimulusInfo.preDriftHoldTime = q.preDriftHoldTime;
                    stimulusInfo.driftTime = q.driftTime;
                case 'HDH'
                    stimulusInfo = HoldDriftHold(q);
                    stimulusInfo.preDriftHoldTime = q.preDriftHoldTime;
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.postDriftHoldTime = q.postDriftHoldTime;
                case 'DG'
                    stimulusInfo = DriftGray(q);
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.postDriftHoldTime = q.postDriftGrayTime;
                case 'P'
                    stimulusInfo=Plaid(q);
                    stimulusInfo.driftTime = q.driftTime;
                    stimulusInfo.plaidAngle=q.plaidAngle;
                case 'PG'
                    stimulusInfo=PlaidGray(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.plaidAngle=q.plaidAngle;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                case 'fsPulse'
                    stimulusInfo=fullscreenPulse(q);
                    stimulusInfo.driftTime=q.driftTime;
                    stimulusInfo.postDriftGrayTime = q.postDriftGrayTime;
                    stimulusInfo.lumscreen=q.lumscreen;
                case 'Ret'
                    stimulusInfo=RetinotopyDrift(q);
                case 'spn'
                    stimulusInfo=sparseNoise(q);
                case 'freqTuning'
                    stimulusInfo=freqTuningHD(q);
                otherwise
                    error('Unsupported Mode')

            end
    end
    
catch err
    if strcmp(err.message, 'escapeBsl')
        Screen('CloseAll')
        clear mex
        fprintf('Program terminated before stimulus presentation \n stimulusInfo will not be saved \n')
        % Write to file if the file exists
        if q.fid>-1
            fprintf('\nProgram manually terminated. \n stimulusInfo will not be saved \n')
            fclose(q.fid);
        end
        stimulusInfo=[];
        return
    else
        clear mex
         if q.fid>-1
            fprintf(q.fid, '\n\tError: %s\n', err.message);
            fclose(q.fid);
        end
        rethrow(err)
    end
end

% Unless it's a flip or sparse noise (in which case it's irrelevant), add temporal and
% spatial frequency to the output variable
if ~sum((strcmp(q.experimentType, {'Flip', 'spn','fsPulse'})))
    stimulusInfo.temporalFreq = q.tempFreq;
    stimulusInfo.spatialFreq = q.spaceFreqDeg;
    
    %add a vector to stimulusInfo containing all the directions in order
    directions = zeros(2, size(stimulusInfo.stimuli, 2));
    for i = 1:size(stimulusInfo.stimuli, 2)
        directions(1, i) = stimulusInfo.stimuli(i).direction;
        if strcmp(stimulusInfo.stimuli(1, i).type,'Drift')
            directions(2, i) = 1;
        else
            directions(2, i) = 0;
        end
    end
    stimulusInfo.directions = directions;
end

if ~isempty(q.filePath)
    filePath = fullfile(q.filePath, q.fileName);
    save(filePath, 'stimulusInfo')
    if q.fid>-1
        if isempty(stimulusInfo.stimuli(end).endTime)
            fprintf(q.fid, 'Terminated early.\nPartial stimulus info saved to %s\n', filePath);
        else
            fprintf(q.fid, 'Complete.\nStimulus info saved to %s\n', filePath);
        end
        fclose(q.fid);
    end
end

if q.keyWait
    KbWait;
end

if q.screenClear
    Screen('CloseAll')
    clear mex
else
    Screen
    Screen('FillRect', q.window,127);                         % Grey Background for initialisation
    Screen('Flip',q.window);
end
