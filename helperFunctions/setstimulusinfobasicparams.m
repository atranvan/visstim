function [stimulusInfo] = setstimulusinfobasicparams(q)
%SETSTIMULUSINFOBASICPARAMS Sets up stimulusInfo variable with basic
%information copied from the set VisStimAlex parameters.
%
%Used by all stimulus scripts.
% 2017-03-31 modified by ATVM to add Plaid stimulus and DriftGray stimulus

stimulusInfo.experimentType = q.experimentType;
stimulusInfo.triggering = q.triggering;

if strcmp(q.triggering, 'off')
    stimulusInfo.baseLineTime = q.baseLineTime;
    stimulusInfo.baseLineSFrames = q.baseLineTime*q.hz;
end

switch q.experimentType
    case 'Flip'
        stimulusInfo.repeats=q.repeats;
    case {'D', 'HD', 'HDH', 'DH','P', 'DG'}
        stimulusInfo.directionsNum = q.directionsNum;
        stimulusInfo.repeats = q.repeats;
    case'Ret'
        stimulusInfo.nPatches = q.patchGridDimensions(1)*q.patchGridDimensions(2);
        stimulusInfo.patchGridX=q.patchGridX;
        stimulusInfo.patchGridY=q.patchGridY;
        stimulusInfo.repeats = q.repeats;
    case 'spn'
        stimulusInfo.spotSizeMean=q.spotSizeMean;
        stimulusInfo.spotSizeRange=q.spotSizeRange;
        stimulusInfo.spotNumberMean=q.spotNumberMean;
        stimulusInfo.spotNumberStd=q.spotNumberStd;
        stimulusInfo.spotTime=q.spotTime;
        stimulusInfo.nStimFrames=q.nStimFrames;
        stimulusInfo.screenRect=q.screenRect;
    case 'freqTuning'
        stimulusInfo.direction= q.directionForFreqTuning;
        stimulusInfo.repeats = q.repeats;
    otherwise
        error('Unsupported Mode')
        
end

end

