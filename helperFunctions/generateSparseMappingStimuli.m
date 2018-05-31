function stimulusInfo=generateSparseStimuli(q, stimulusInfo)
q.nSpots=2*q.nStimFramesMapping;
stimulusInfo.stimuliSp=cell(q.nSpots, 1);
stimulusInfo.spotColors=cell(q.nSpots, 1); % 0 for black, 1 for white
stimulusInfo.XSpanPixels=round(q.XSpanDegrees/q.degperpix);
stimulusInfo.YSpanPixels=round(q.YSpanDegrees/q.degperpix);

if (stimulusInfo.XSpanPixels>q.screenRect(3))||(stimulusInfo.YSpanPixels>q.screenRect(4))
    msg='visual space larger than screen dimensions';
    disp(stimulusInfo.XSpanPixels)
    disp(q.screenRect(3))
    disp(stimulusInfo.YSpanPixels)
    disp(q.screenRect(4))
    error(msg)
else
    stimulusInfo.XOffset = round((q.screenRect(3)-stimulusInfo.XSpanPixels)/2);
    stimulusInfo.YOffset = round((q.screenRect(4)-stimulusInfo.YSpanPixels)/2);
end

stimulusInfo.spotSizePixels=round(sqrt((stimulusInfo.XSpanPixels*stimulusInfo.YSpanPixels)/(q.nStimFramesMapping)),1);
stimulusInfo.spotSizeDegrees=round(stimulusInfo.spotSizePixels*q.degperpix);

stimulusInfo.Ncols=round(stimulusInfo.XSpanPixels/stimulusInfo.spotSizePixels);
stimulusInfo.Nrows=round(stimulusInfo.YSpanPixels/stimulusInfo.spotSizePixels);

%q.DotLocation = datasample(0:q.nSpots-1,q.nSpots,'Replace',false); % draw q.nSpots unique elements in random order, use to set positions of white or black squares
%datasample seem to work only for recent Matlab versions
q.DotLocation = 0:q.nSpots-1;
q.DotLocation = q.DotLocation(randperm(length(q.DotLocation)));%0:q.nStimFramesMapping-1 correspond to locations of white dots
%q.nStimFramesMapping:q.nSpots-1 correspond to locations of black dots

stimulusInfo.whiteXIndex = zeros (q.nSpots,1); % whiteXIndex is column number between 0:11 if spot is white, -1 otherwise
stimulusInfo.whiteYIndex = zeros (q.nSpots,1); % whiteYIndex is row number between 0:9 if spot is white, -1 otherwise
stimulusInfo.blackXIndex = zeros (q.nSpots,1); % blackXIndex is column number if spot is black, -1 otherwise
stimulusInfo.blackYIndex = zeros (q.nSpots,1); % blackYIndex is row number if spot is black, -1 otherwise
spotBounds=zeros(q.nSpots,4);

for i=1:q.nSpots
    if q.DotLocation(i)<=q.nStimFramesMapping-1
        stimulusInfo.spotColors{i}=[1;1;1];
        stimulusInfo.whiteXIndex(i) = mod(q.DotLocation(i),stimulusInfo.Ncols);
        stimulusInfo.whiteYIndex(i) = floor(q.DotLocation(i)/stimulusInfo.Ncols);
        stimulusInfo.blackXIndex(i) = -1;
        stimulusInfo.blackYIndex(i) = -1;
        %spotBounds(i, :)=
        stimulusInfo.stimuliSp{i}(:,:)=[stimulusInfo.XOffset+stimulusInfo.whiteXIndex(i)*stimulusInfo.spotSizePixels, stimulusInfo.YOffset+stimulusInfo.whiteYIndex(i)*stimulusInfo.spotSizePixels, stimulusInfo.XOffset+(stimulusInfo.whiteXIndex(i)+1)*stimulusInfo.spotSizePixels, stimulusInfo.YOffset+(stimulusInfo.whiteYIndex(i)+1)*stimulusInfo.spotSizePixels];        
    else
        stimulusInfo.spotColors{i}=[0;0;0];
        stimulusInfo.whiteXIndex(i) = -1;
        stimulusInfo.whiteYIndex(i) = -1;
        stimulusInfo.blackXIndex(i) = mod(q.DotLocation(i)-q.nStimFramesMapping,stimulusInfo.Ncols);
        stimulusInfo.blackYIndex(i) = floor((q.DotLocation(i)-q.nStimFramesMapping)/stimulusInfo.Ncols);
        %spotBounds(i, :)=
        stimulusInfo.stimuliSp{i}(:,:)=[stimulusInfo.XOffset+stimulusInfo.blackXIndex(i)*stimulusInfo.spotSizePixels, stimulusInfo.YOffset+stimulusInfo.blackYIndex(i)*stimulusInfo.spotSizePixels, stimulusInfo.XOffset+(stimulusInfo.blackXIndex(i)+1)*stimulusInfo.spotSizePixels, stimulusInfo.YOffset+(stimulusInfo.blackYIndex(i)+1)*stimulusInfo.spotSizePixels];
    end
    
end

end