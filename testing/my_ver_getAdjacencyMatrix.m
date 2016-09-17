function [adjMatrixW, adjMatrixMW, adjMAsub, adjMBsub, adjMW, adjMmW, img] = my_ver_getAdjacencyMatrix(inputImg)

% Ouputs the adjacency matrices, and the weights and locations for building these matrices based on eq 1
% Usage
% Input: 'inputImg' - an image.
% Outputs: 
%   %Sparse Matrices
%   'adjMatrixW'    - dark-to-light adjacency matrix
%   'adjMatrixMW'   - light-to-dark adjacency matrix
%   %Non zero weights in the sparse matrices
%   'adjMBsub'      - locations of the weights
%   'adjMAsub'      - locations of the weights
%   'adjMmW'        - light-to-dark weights
%   'adjMW'         - dark-to-light weights
%   'img'           - updated image with 1 column of 0s on the each verticle side of the image

% pad image with vertical column on both sides
szImg = size(inputImg);
img = zeros([szImg(1) szImg(2)+2]);

img(:,2:1+szImg(2)) = inputImg;

% update size of image
szImg = size(img);

% get vertical gradient image
[~,gradImg] = gradient(img,1,1);
gradImg = -1*gradImg;

% normalize gradient
gradImg = (gradImg-min(gradImg(:)))/(max(gradImg(:))-min(gradImg(:)));

% get the "invert" of the gradient image.
gradImgMinus = gradImg*-1+1; 

%% generate adjacency matrix, see equation 1 in the refered article.

%minimum weight
minWeight = 1E-5;

neighborIterX = [1 1  1 0  0 -1 -1 -1];
neighborIterY = [1 0 -1 1 -1  1  0 -1];

% get location A (in the image as indices) for each weight.
adjMAsub = 1:szImg(1)*szImg(2);

% convert adjMA to subscripts
[adjMAx,adjMAy] = ind2sub(szImg,adjMAsub);

adjMAsub = adjMAsub';
szadjMAsub = size(adjMAsub);

% prepare to obtain the 8-connected neighbors of adjMAsub
% repmat to [1,8]
neighborIterX = repmat(neighborIterX, [szadjMAsub(1),1]);
neighborIterY = repmat(neighborIterY, [szadjMAsub(1),1]);

% repmat to [8,1]
adjMAsub = repmat(adjMAsub,[1 8]);
adjMAx = repmat(adjMAx, [1 8]);
adjMAy = repmat(adjMAy, [1 8]);

% get 8-connected neighbors of adjMAsub
% adjMBx,adjMBy and adjMBsub
adjMBx = adjMAx+neighborIterX(:)';
adjMBy = adjMAy+neighborIterY(:)';

% make sure all locations are within the image.
keepInd = adjMBx > 0 & adjMBx <= szImg(1) & ...
    adjMBy > 0 & adjMBy <= szImg(2);

adjMAsub = adjMAsub(keepInd);
adjMBx = adjMBx(keepInd);
adjMBy = adjMBy(keepInd); 

adjMBsub = sub2ind(szImg,adjMBx(:),adjMBy(:))';

% calculate weight
adjMW = 2 - gradImg(adjMAsub(:)) - gradImg(adjMBsub(:)) + minWeight;
adjMmW = 2 - gradImgMinus(adjMAsub(:)) - gradImgMinus(adjMBsub(:)) + minWeight;

% pad minWeight on the side
imgTmp = nan(size(gradImg));
imgTmp(:,1) = 1;
imgTmp(:,end) = 1;
imageSideInd = ismember(adjMBsub,find(imgTmp(:)==1));
adjMW(imageSideInd) = minWeight;
adjMmW(imageSideInd) = minWeight;

% build sparse matrices
adjMatrixW = [];
adjMatrixMW = [];