data = {};
data{1} = load('Subject_05_dn.mat');
data{2} = load('Subject_03_dn.mat');
data{3} = load('Subject_02_dn.mat');
data{4} = load('Subject_04_dn.mat');


count = 0;
ims = [];
lays = [];
seg_value = {};
for i = 1:7
    seg_value{i} = zeros(1,10);
end
new_seg_value={};
for k=1:size(data,2)
    img_layers = data{k}.manualLayer1new;
    img = data{k}.images_dn2;

    seg = {};

    for i = 1:size(img,3)
        seg{i} = layers(img(:,:,i),img_layers(:,:,i));
    end
    
    for i = 1:size(img,3)
        seg_roi{i} = layers(img(:,:,i),[img_layers(1,:,i);img_layers(8,:,i)]);
    end

    for i=1:size(img,3)
        img(:,:,i)=seg_roi{i}{1};
    end

    for i=1:size(seg{1},2)
        for j =1:size(seg,2)
            train_layer{j}=seg{j}{i};
        end
        new_seg_value{i}=standardize_learn(train_layer);
        seg_value{i} = seg_value{i}+new_seg_value{i};
        
    end
    count = count + 1;
    
    ims = cat(3,ims,img);
    lays = cat(3,lays,img_layers);
end
for i = 1:size(seg{1},2)
    seg_value{i}=seg_value{i}/count;
end

test_data = load('Subject_01_dn.mat');
test_img = test_data.images_dn2;
test_layer = test_data.manualLayer1new;

test_img_roi = zeros(size(test_img));
lay = {};
for i = 1:size(test_img,3)
    
    lay = layers(test_img(:,:,i),[test_layer(1,:,i);test_layer(8,:,i)]);
    test_img_roi(:,:,i) = lay{1};
end

for i = 1:size(test_img,3)
    res_layers{i} = round(nn(ims,test_img_roi(:,:,i),lays));
end
for i=1:5
    figure;
    imshow(uint8(test_img(:,:,i)));
    hold on;
    plot(1:size(res_layers{i},2),res_layers{i});
    im = input('continue');
end