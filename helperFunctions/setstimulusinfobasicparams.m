function [stimulusInfo] = setstimulusinfobasicparams(q)
%SETSTIMULUSINFOBASICPARAMS Sets up stimulusInfo variable with basic
%information copied from the set VisStimAlex parameters.
%
%Used by all stimulus scripts.
% 2017-03-31 modified by ATVM to add Plaid stimulus and DriftGray stimulus
% added fsPulse, spnG, spnMap

stimulusInfo.experimentType = q.experimentType;
stimulusInfo.triggering = q.triggering;

if strcmp(q.triggering, 'off')
    stimulusInfo.baseLineTime = q.baseLineTime;
    stimulusInfo.baseLineSFrames = q.baseLineTime*q.hz;
end

switch q.experimentType
    case {'Flip','fsPulse'}
        stimulusInfo.repeats=q.repeats;
    case {'D', 'HD', 'HDH', 'DH','P', 'DG','PG','HDHG', 'HDRDHG','HDSRHG','HPHG','SrDG','SpotRet','SpotRetBlack','SpotHDHGBlack'}
        stimulusInfo.directionsNum = q.directionsNum;
        stimulusInfo.repeats = q.repeats;
    case 'fsLum'
        stimulusInfo.repeats = q.repeats;
        stimulusInfo.lumNum = q.lumNum;
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
    case 'spnG'
        stimulusInfo.spotSizeMean=q.spotSizeMean;
        stimulusInfo.spotSizeRange=q.spotSizeRange;
        stimulusInfo.spotNumberMean=q.spotNumberMean;
        stimulusInfo.spotNumberStd=q.spotNumberStd;
        stimulusInfo.spotTime=q.spotTime;
        stimulusInfo.grayTime=q.postSpotGrayTime;
        stimulusInfo.nStimFrames=q.nStimFrames;
        stimulusInfo.screenRect=q.screenRect;
    case 'spnMap'       
        stimulusInfo.spotTime=q.spotTime;
        stimulusInfo.grayTime=q.postSpotGrayTime;
        stimulusInfo.nStimFramesMapping=q.nStimFramesMapping;
        stimulusInfo.screenRect=q.screenRect;
    case 'freqTuning'
        stimulusInfo.direction= q.directionForFreqTuning;
        stimulusInfo.repeats = q.repeats;
    otherwise
        error('Unsupported Mode')
        
end

end

