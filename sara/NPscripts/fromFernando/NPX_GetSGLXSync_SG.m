function syncNPX = NPX_GetSGLXSync(filename)


% d = dir(filename);
% syncNPX = zeros(1,d.bytes/385/2);
% %syncNPX = zeros(1,d.bytes/385/2/15);
% fid = fopen(filename, 'r');
% 
% for ii = 1:length(syncNPX)
% 
%     fseek(fid,768,0);
%     syncNPX(ii) = fread(fid, 1, '*int16');
% 
% end
% fclose(fid);


fileType = filename(end-4);
chunkSize = 1000000;

fid = [];

d = dir(filename);

try
  
  fid = fopen(filename, 'r');
  chunkInd = 1;
    
  if strcmp(fileType,'p')
      nChansTotal = 385;
      nSampsTotal = d.bytes/nChansTotal/2;
      nChunksTotal = ceil(nSampsTotal/chunkSize);    
      syncNPX = zeros(1,nSampsTotal);
      while 1
        
        fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
        
        dat = fread(fid, [nChansTotal chunkSize], '*int16');
        
        if ~isempty(dat)
          
          tm = dat(385,:);
          syncNPX((chunkInd-1)*chunkSize+1:(chunkInd-1)*chunkSize+numel(tm)) = tm;
          
        else
          break
        end
        
        chunkInd = chunkInd+1;
      end

  elseif strcmp(fileType,'q')
      nChansTotal = 8;
      nSampsTotal = (d.bytes*8)/nChansTotal;
      nChunksTotal = ceil(nSampsTotal/chunkSize);    
      syncNPX = zeros(nChansTotal,nSampsTotal);
      while 1
        
        fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
        
        dat = fread(fid, [nChansTotal chunkSize], 'ubit1');
        
        if ~isempty(dat)
          
          tm = dat(1:8,:);
          syncNPX(:,(chunkInd-1)*chunkSize+1:(chunkInd-1)*chunkSize+size(tm,2)) = tm;
          
        else
          break
        end
        
        chunkInd = chunkInd+1;
      end

  end
  
  fclose(fid);
  
catch me
  
  if ~isempty(fid)
    fclose(fid);
  end
  
  
  rethrow(me)
  
end