
function [rPaths, img] = segment_layer(layerName,img,params,rPaths)
switch layerName
    
    case {'initial_guess'}
      
                inputImg = img(:,2:end-1);
%shrink the image.
                szImg = size(inputImg);
                procImg = imresize(inputImg,params.initial_guess.shrinkScale,'bilinear');

%create adjacency matrices
            [adjMatrixW, adjMatrixMW, adjMX, adjMY, adjMW, adjMmW, newImg] = my_ver_getAdjacencyMatrix(procImg);

%create roi for getting shortestest path based on gradient-Y image.
                [gx, gy] = gradient(newImg);
                szImgNew = size(newImg);
                roiImg = zeros(szImgNew);
                roiImg(gy > mean(gy(:))) =1 ;

% find at least 2 layers
                path{1} = 1;
                count = 1;
            while ~isempty(path) && count <= 2
                roiImg(:,1)=1;
                roiImg(:,end)=1;

% include only region of interst in the adjacency matrix
                includeX = ismember(adjMX, find(roiImg(:) == 1));
                includeY = ismember(adjMY, find(roiImg(:) == 1));
                keepInd = includeX & includeY;
                adjMatrix = sparse(adjMX(keepInd),adjMY(keepInd),adjMmW(keepInd),numel(newImg(:)),numel(newImg(:)));
    
% get layer shortest path       
                [ ~,path{1} ] = graphshortestpath( adjMatrix, 1, numel(newImg(:)));

                if ~isempty(path{1})
                        
% get rid of first few points and last few points
                    [pathX,pathY] = ind2sub(szImgNew,path{1});        

                    pathX = pathX(gradient(pathY)~=0);
                    pathY = pathY(gradient(pathY)~=0);
        
%block the obtained path and abit around it
                    pathXArr = repmat(pathX,numel(params.initial_guess.offsets));
                    pathYArr = repmat(pathY,numel(params.initial_guess.offsets));
                    for i = 1:numel(params.initial_guess.offsets)
                        pathYArr(i,:) = pathYArr(i,:)+params.initial_guess.offsets(i);
                    end

                    pathXArr = pathXArr(pathYArr > 0 & pathYArr <= szImgNew(2));
                    pathYArr = pathYArr(pathYArr > 0 & pathYArr <= szImgNew(2));

                    pathArr = sub2ind(szImgNew,pathXArr,pathYArr);
                    roiImg(pathArr) = 0;

                    paths(count).pathX = pathX;
                    paths(count).pathY = pathY;
                end 
                count = count + 1;
            end

%resize paths back to original size
                for i = 1:numel(paths)    
                    [paths(i).path, paths(i).pathY, paths(i).pathX] = resizePath(szImg, szImgNew, params.initial_guess, paths(i).pathY, paths(i).pathX);    
                    paths(i).pathXmean = nanmean(paths(i).pathX);
                    paths(i).name = [];

                end

%based on the mean location detemine the layer type.
                if paths(1).pathXmean < paths(2).pathXmean
                    paths(1).name = 'ilm';
                    paths(2).name = 'isos';
                else
                    paths(1).name = 'isos';    
                    paths(2).name = 'ilm';    
                end

                    %save to structure 
                    clear rPaths
                    rPaths = paths;

                    return;        

    case {'ilm' 'isos' 'rpe' 'inlopl' 'nflgcl' 'iplinl' 'oplonl'}
        
        adjMA = params.adjMA;
        adjMB = params.adjMB;
        adjMW = params.adjMW;
        adjMmW = params.adjMmW;        
      
end


% avoid the top part of image
szImg = size(img);
roiImg = zeros(szImg);
roiImg(1:20,:) = 0;

% search in interested region
for k = 2:szImg(2)-1
    
    switch layerName
        
         case {'ilm'}
            
            % region near 'ilm'.
            indPathX = find(rPaths(strcmp('ilm',{rPaths.name})).pathY==k);
            
            startInd = rPaths(strcmp('ilm',{rPaths.name})).pathX(indPathX(1)) - params.ilm_0; 
            endInd = rPaths(strcmp('ilm',{rPaths.name})).pathX(indPathX(1)) + params.ilm_1;             
            
        case {'isos'}            
            
            % region near 'isos'.
            indPathX = find(rPaths(strcmp('isos',{rPaths.name})).pathY==k);            
            
            startInd = rPaths(strcmp('isos',{rPaths.name})).pathX(indPathX(1)) - params.isos_0; 
            endInd = rPaths(strcmp('isos',{rPaths.name})).pathX(indPathX(1)) + params.isos_1;             
            
        case {'rpe'}
            
            % region below 'isos'.
            indPathX = find(rPaths(strcmp('isos',{rPaths.name})).pathY==k);             
            startInd0 = rPaths(strcmp('isos',{rPaths.name})).pathX(indPathX(1));
            endInd0 = startInd0+round((rPaths(strcmp('isos',{rPaths.name})).pathXmean-rPaths(strcmp('ilm',{rPaths.name})).pathXmean));

            startInd = startInd0+round(params.rpe_0*(endInd0-startInd0));
            endInd = endInd0-round(params.rpe_1*(endInd0-startInd0));    
            
        case {'inlopl'}     
            
            % region between 'ilm' & 'isos'.
            indPathX = find(rPaths(strcmp('ilm',{rPaths.name})).pathY==k);
            startInd0 = rPaths(strcmp('ilm',{rPaths.name})).pathX(indPathX(1));
            indPathX = find(rPaths(strcmp('isos',{rPaths.name})).pathY==k);
            endInd0 = rPaths(strcmp('isos',{rPaths.name})).pathX(indPathX(1));
                                    
            startInd = startInd0+round(params.inlopl_0*(endInd0-startInd0));
            endInd = endInd0-round(params.inlopl_1*(endInd0-startInd0));            
                        
        case {'nflgcl'}
            
            % region between 'ilm' & 'inlopl'.
            indPathX = find(rPaths(strcmp('ilm',{rPaths.name})).pathY==k);
            startInd0 = rPaths(strcmp('ilm',{rPaths.name})).pathX(indPathX(1));            
            indPathX = find(rPaths(strcmp('inlopl',{rPaths.name})).pathY==k);
            endInd0 = rPaths(strcmp('inlopl',{rPaths.name})).pathX(indPathX(1));
                        
            startInd = startInd0 + round(params.nflgcl_0*(endInd0-startInd0));
            endInd = endInd0 - round(params.nflgcl_1*(endInd0-startInd0));
              
        case {'iplinl'}

            % region between 'nflgcl' and 'inlopl'.
            indPathX = find(rPaths(strcmp('nflgcl',{rPaths.name})).pathY==k);
            startInd0 = rPaths(strcmp('nflgcl',{rPaths.name})).pathX(indPathX(1));
            indPathX = find(rPaths(strcmp('inlopl',{rPaths.name})).pathY==k);
            endInd0 = rPaths(strcmp('inlopl',{rPaths.name})).pathX(indPathX(1));
            
            startInd = startInd0 + round(params.iplinl_0*(endInd0-startInd0));
            endInd = endInd0 - round(params.iplinl_1*(endInd0-startInd0));
            
            
        case {'oplonl'}
                        
            % region between 'inlopl' and 'isos'.
            indPathX = find(rPaths(strcmp('inlopl',{rPaths.name})).pathY==k);
            startInd0 = rPaths(strcmp('inlopl',{rPaths.name})).pathX(indPathX(1));
            indPathX = find(rPaths(strcmp('isos',{rPaths.name})).pathY==k);
            endInd0 = rPaths(strcmp('isos',{rPaths.name})).pathX(indPathX(1));
                        
            startInd = startInd0 +round(params.oplonl_0*(endInd0-startInd0));
            endInd = endInd0 -round(params.oplonl_1*(endInd0-startInd0));
    end
    
    %error checking    
    if startInd > endInd
        startInd = endInd - 1;
    end            
    
    if startInd < 1
        startInd = 1;
    end
    
    if endInd > szImg(1)
        endInd = szImg(1);
    end
                    
    % set region of interest at column k from startInd to endInd
    roiImg(startInd:endInd,k) = 1;
    
end

%ensure the 1st and last column is part of the region of interest.
roiImg(:,1)=1;
roiImg(:,end)=1;            

% include only region of interst in the adjacency matrix
includeA = ismember(adjMA, find(roiImg(:) == 1));
includeB = ismember(adjMB, find(roiImg(:) == 1));
keepInd = includeA & includeB;

%get the shortestpath
switch layerName
    %bright to dark
    case {'rpe' 'nflgcl' 'oplonl' 'iplinl' }
        adjMatrixW = sparse(adjMA(keepInd),adjMB(keepInd),adjMW(keepInd),numel(img(:)),numel(img(:)));    
        [ ~, path ] = graphshortestpath( adjMatrixW, 1, numel(img(:)) );
        
    %dark to bright
    case {'inlopl' 'ilm' 'isos' }
        adjMatrixMW = sparse(adjMA(keepInd),adjMB(keepInd),adjMmW(keepInd),numel(img(:)),numel(img(:)));    
        [ ~, path ] = graphshortestpath( adjMatrixMW, 1, numel(img(:)) );        
end

%convert path indices to subscript
[pathX, pathY] = ind2sub(szImg,path);

%if name layer existed, overwrite it, else add layer info to struct
matchedLayers = strcmpi(layerName,{rPaths(:).name});
layerToPlotInd = find(matchedLayers == 1);
if isempty(layerToPlotInd)    
    layerToPlotInd = numel(rPaths)+1;
    rPaths(layerToPlotInd).name = layerName;
end

rPaths(layerToPlotInd).path = path;
rPaths(layerToPlotInd).pathX = pathX;
rPaths(layerToPlotInd).pathY = pathY;
rPaths(layerToPlotInd).pathXmean = mean(rPaths(layerToPlotInd).pathX(gradient(rPaths(layerToPlotInd).pathY)~=0));

