function [masktex, stimulusInfo]=patchgrid(q, stimulusInfo)
%calculate patch grid
 
 [py, px]=meshgrid(linspace(0, 1, q.patchGridDimensions(2)+1), linspace(0, 1, q.patchGridDimensions(1)+1));
 px=px(1:end-1, 1:end-1).*q.screenRect(3);
 py=py(1:end-1, 1:end-1).*q.screenRect(4);
 stepSz=[px(2, 1) py(1, 2)];
 
 %enable alpha blending and create masks
 Screen('BlendFunction', q.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 mask=zeros(q.screenRect(3), q.screenRect(4), 2); %luminance channel - fill with black
 mask(:,:,2)=255; %default alpha channel to max(opaque)
 
 masktex=zeros(stimulusInfo.nPatches, 1); %array of handles
 
 for i = 1:stimulusInfo.nPatches
     tmp =mask;
     minX=round(px(i)); if minX ==0; minX=1; end
     minY=round(py(i)); if minY ==0; minY =1; end
     maxX=round(px(i)+stepSz(1));
     maxY=round(py(i)+stepSz(2));
     tmp(minX:maxX, minY:maxY, 2)=0;
     tmpT(:,:,1) = tmp(:,:,1)';
     tmpT(:,:,2) = tmp(:,:,2)';
     masktex(i)=Screen('MakeTexture', q.window, tmpT);
 end
 
 
 if isfield(q, 'patchSubset')&&~isempty(q.patchSubset)
     if numel(q.patchSubset)~=stimulusInfo.nPatches
         error('subset specification must contain the same number of entries as the number of patches (x*y)')
     end
     if ~isnumeric(q.patchSubset)||(~all((q.patchSubset(:)==1)|(q.patchSubset(:)==0)))
         error('Please specity subset using only 1s or 0s')
     end
     stimulusInfo.nPatches=sum(q.patchSubset(:));
     masktex=masktex(logical(q.patchSubset));
 end