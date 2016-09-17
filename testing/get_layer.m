function reslayer = get_layer(img)
% clc
% close all
% clear all
img = uint8(img);
% inpdir='/home/karthik/Testing/Miccai_15_challenge/training/cirrus_2/scan/';
% file=dir([inpdir '*.dcm']);
 paths = '../testing/im1.jpg';
% img = imread(path);
% img=dicomread([inpdir file.name]);
data=squeeze(img);
sizeofimg=size(data);
%     img=im2double(data(:,:,110));
% 
%     img(1:200,1:sizeofimg(2))=img(101:300,1:sizeofimg(2));
%initialize constants
% % 
%     img = medfilt2(img,[15 15]);  
% 
%     img = imadjust(img,stretchlim(img),[]);
    % resize image: 1st value set to 'true'& second value to be the scale.
    param.isResize = [true 1];
    
    % constants for smothing the images.
    param.filter0Params = [5 5 1];
    
    % constants used for defining the region for segmentation of individual layer
    param.initial_guess.shrinkScale = 0.2;
    param.initial_guess.offsets = -1:1;    
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

%  img = medfilt2(img,[15 15]);  

 img = imadjust(img,stretchlim(img),[]);
%smooth image with specified kernels for denosing
% img = imfilter(img,fspecial('gaussian',param.filter0Params(1:2),param.filter0Params(3)),'replicate');        

% img = imadjust(img,stretchlim(img),[]);

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
     a=zeros(size(img));
     reslayer = zeros(7,size(a,2));
   
     for k = 1:numel(layersToPlot)

        matchedLayers = strcmpi(layersToPlot{k},{retinalLayers(:).name});
        layerToPlotInd = find(matchedLayers == 1);

        y=retinalLayers(layerToPlotInd).pathY-1;
        idx1=find(y==0);
        idx2=find(y>size(img,2));
        ny=y(max(idx1+1):min(idx2-1));
        x=retinalLayers(layerToPlotInd).pathX;
        nx=x(max(idx1+1):min(idx2-1));
        reslayer(k,:)=nx;
        for i=1:length(nx)
        a(nx(i),ny(i))=1;
        end
%         imshow(a);
       
        colora = param.colorarr(k,:);
        plot(retinalLayers(layerToPlotInd).pathY-1,retinalLayers(layerToPlotInd).pathX-1,'color',colora,'linewidth',2);
        plotInd = round(numel(retinalLayers(layerToPlotInd).pathX)/3); 
        text(retinalLayers(layerToPlotInd).pathY(plotInd),retinalLayers(layerToPlotInd).pathX(plotInd),retinalLayers(layerToPlotInd).name,'color',colora,'linewidth',2);            
        drawnow;


    end 
    hold off;
%     reslayer = zeros(7,size(a,2));
%     for i=1:size(a,2)
%         reslayer(:,i)=find(a(:,i)==1);
%     end

    
end