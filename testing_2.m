data = load('Subject_06_dn.mat');
img_layers = data.manualLayer1new;
img = data.images_dn2;
img_delta = zeros(1,size(img,2),size(img,3));
seg = {};
seg_roi = {};

for i = 1:size(img,3)
    seg{i} = layers(img(:,:,i),img_layers(:,:,i));
end

for i = 1:size(img,3)
%     [img(:,:,i),img_layers(:,:,i),img_delta(:,:,i)] = flatten_im(img(:,:,i),img_layers(:,:,i));
    seg_roi{i} = layers(img(:,:,i),[img_layers(1,:,i);img_layers(8,:,i)]);
end

% img_new = zeros(size(img));

for i=1:9
    img_new(:,:,i)=seg_roi{i}{1};
end

test_im = img(:,:,10);
nn_test = seg_roi{10}{1};

% [or_im,or_layer] = unflatten(test_im,img_layers(:,:,10),img_delta(:,:,10));
% figure;
% imshow(uint8(or_im));
% hold on;
% plot(1:size(test_im,2),or_layer);
% a = input('continue');


test_layer = round(nn(img_new,nn_test,img_layers(:,:,1:9)));

new_img = zeros(size(test_im)); 

figure ;
imshow(uint8(test_im));
hold on;
plot(1:size(test_im,2),test_layer);


test_seg = layers(test_im,test_layer);
for i=1:size(test_seg,2)
    for j =1:9
        train_layer{j}=seg{j}{i};
    end
    new_seg{i}=standardize(train_layer,test_seg{i});
    new_img = new_img+new_seg{i};
end

figure;
imshow(uint8(new_img));
hold on
%plot(1:size(test_im,2),test_layer);