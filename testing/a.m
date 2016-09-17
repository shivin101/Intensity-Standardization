clc
close all
clear all

inpdir='/home/karthik/octdown/patient#2/';

load([inpdir '2_l.mat']);
load vect.mat;
img=vectform;

% % img=d3(:,:,128);
img = double(img);
%     
%initialize constants

    
    % resize image: 1st value set to 'true'& second value to be the scale.
    param.isResize = [true 0.5];
    
    % constants for smothing the images.
    param.filter0Params = [5 5 1];
    
    % constants used for defining the region for segmentation of individual layer
    param.initial_guess.shrinkScale = 0.2;
    param.initial_guess.offsets = -20:20;    
    param.ilm_0 = 4;
    param.ilm_1 = 4;
    param.isos_0 = 4;
    param.isos_1 = 4;
    param.rpe_0 = 0.05;
    param.rpe_1 = 0.05;
    param.inlopl_0 = 0.1;
    param.inlopl_1 = 0.3;
    param.nflgcl_0 = 0.05;
    param.nflgcl_1 = 0.3; 
    param.iplinl_0 = 0.6;
    param.iplinl_1 = 0.2;
    param.oplonl_0 = 0.05;
    param.oplonl_1 = 0.5;   
    
% constants for ploting
    colorarr=colormap('jet'); 
    param.colorarr=colorarr(64:-8:1,:);

% resize image.
if param.isResize(1)
    img = imresize(img,param.isResize(2),'bilinear');
end

%smooth image with specified kernels for denosing
img = imfilter(img,fspecial('gaussian',param.filter0Params(1:2),param.filter0Params(3)),'replicate');        

% create adjacency matrices and its elements base on the image.
[param.adjMatrixW, param.adjMatrixMW, param.adjMA, param.adjMB, param.adjMW, param.adjMmW, imgNew] = my_ver_getAdjacencyMatrix(img);

% layers in the order 
retinalLayerSegmentationOrder = {'initial_guess' 'ilm' 'isos' 'rpe' 'inlopl' 'nflgcl' 'iplinl' 'oplonl' };

% segment retinal layers based on the above order
retinalLayers = [];


for layerInd = 1:numel(retinalLayerSegmentationOrder)  
    
[retinalLayers, ~] = segment_layer(retinalLayerSegmentationOrder{layerInd},imgNew,param,retinalLayers);
  
end

% plot oct image and the obtained retinal layers.
    imagesc(img);
    axis image; colormap('gray'); hold on; drawnow;

    layersToPlot = {'ilm' 'isos' 'rpe' 'inlopl' 'nflgcl' 'iplinl' 'oplonl'};
    
    for k = 1:numel(layersToPlot)

        matchedLayers = strcmpi(layersToPlot{k},{retinalLayers(:).name});
        layerToPlotInd = find(matchedLayers == 1);
        colora = param.colorarr(k,:);
        plot(retinalLayers(layerToPlotInd).pathY-1,retinalLayers(layerToPlotInd).pathX-1,'color',colora,'linewidth',2);
        plotInd = round(numel(retinalLayers(layerToPlotInd).pathX)/2); 
        text(retinalLayers(layerToPlotInd).pathY(plotInd),retinalLayers(layerToPlotInd).pathX(plotInd),retinalLayers(layerToPlotInd).name,'color',colora,'linewidth',2);            
        drawnow;


    end 
    hold off;

    
