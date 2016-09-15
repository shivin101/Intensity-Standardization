data = load('Subject_05_dn.mat');
img_layers = data.manualLayer1new;
img = data.images_dn2;

seg = {};

for i = 1:size(img,3)
    seg{i} = layers(img(:,:,i),img_layers(:,:,i));
end

test_im = img(:,:,10);
test_layer = round(nn(img(:,:,1:9),test_im,img_layers(:,:,1:9)));

new_img = zeros(size(test_im)); 

figure ;
imshow(uint8(test_im));
hold on;
plot(1:800,test_layer);

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
%plot(1:800,test_layer);