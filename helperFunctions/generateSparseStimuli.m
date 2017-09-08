function stimulusInfo=generateSparseStimuli(q, stimulusInfo)

stimulusInfo.stimuliSp=cell(q.nStimFrames, 1);
stimulusInfo.spotSizes=cell(q.nStimFrames, 1);
stimulusInfo.spotColors=cell(q.nStimFrames, 1);

possLocations=true(q.screenRect(3)*2, q.screenRect(4)*2);
if q.photoDiodeRect(2)
     %q.photoDiodeRect = [0 q.screenRect(4)-q.diodePatchYSize q.diodePatchXSize q.screenRect(4)];
     photodiodepos=logical([0:q.diodePatchXSize,q.screenRect(4)-q.diodePatchYSize:q.screenRect(4)]);
     possLocations(photodiodepos)=0;
end

for i=1:q.nStimFrames
    nSpots=round(q.spotNumberMean+q.spotNumberStd*randn(1));         %Generate a random number of spots
    nSpots=max([nSpots 1]);                                          %Prevent there being no or 'negative' numbers of spots
    

    stimulusInfo.spotSizes{i}=...
        round(q.spotSizeMean_pix+(2*(rand(nSpots, 1))-1)*q.spotSizeRange_pix); %Generate random spot sizes

    spotCols=(round(rand(1, nSpots)));                                 %Generate random spot colors
    stimulusInfo.spotColors{i}=cat(1, spotCols, spotCols, spotCols);   %...and convert to RGB
    
    newLocations=true(q.screenRect(3)*2, q.screenRect(4)*2);
    spotBounds=zeros(nSpots, 4);
    for j=1:nSpots
        randLocL=randi(q.screenRect(3));                                %Define new random positions
        randLocT=randi(q.screenRect(4));
        randLocR=randLocL+stimulusInfo.spotSizes{i}(j);
        randLocB=randLocT+stimulusInfo.spotSizes{i}(j);
        
        while sum(sum(~possLocations(randLocL:randLocR, randLocT:randLocB))) %Check for overlap; repeat if there is any.
            randLocL=randi(q.screenRect(3));
            randLocT=randi(q.screenRect(4));
            randLocR=randLocL+stimulusInfo.spotSizes{i}(j);
            randLocB=randLocT+stimulusInfo.spotSizes{i}(j);
        end
        
        possLocations(randLocL:randLocR, randLocT:randLocB)=0;
        newLocations(randLocL:randLocR, randLocT:randLocB)=0;
        spotBounds(j, :)=[randLocL randLocT, randLocR, randLocB];
    end
    
    stimulusInfo.stimuliSp{i}=spotBounds;
    possLocations=newLocations;
    
end

end