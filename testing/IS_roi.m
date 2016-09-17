data = load('Subject_05_dn.mat');
img_layers = data.manualLayer1new;
img = data.images_dn2;
img_delta = zeros(1,size(img,2),size(img,3));
seg = {};
seg_roi = {};
test_im = img(:,:,10);
test_layer = img_layers(:,:,10);

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


test_roi = seg_roi{10}{1};

% [or_im,or_layer] = unflatten(test_im,img_layers(:,:,10),img_delta(:,:,10));
% figure;
% imshow(uint8(or_im));
% hold on;
% plot(1:size(test_im,2),or_layer);
% a = input('continue');

[weight,idx] = nn_roi(img_new,test_roi);
% for i =1:length(idx)
%     figure;
%     imshow(uint8(img_new(:,:,idx(i))));
% end
% figure;
% imshow(uint8(test_roi));

lay = {};
scale = {};
for i=1:size(img_layers,1)-1
    for j = 1:9
        lay{j}=seg{j}{i};
    end
    scale{i}=round(standardize_learn(lay));   
end

new_img = {};
for i=1:length(idx)
    new_img{i} = zeros(size(test_im));
    for j =1:size(img_layers)-1
        temp=map_img(seg{i}{j},scale{j});
%         imshow(uint8(seg{i}{j}));
%         imshow(uint8(temp));
        new_img{i}=new_img{i}+temp;
    end
%     figure
%     imshow(uint8(seg_roi{i}{1}));
%     figure;
%     imshow(uint8(new_img{i}));
end

values = zeros(1,11);
per_points = {};
for i=1:length(idx)
    per_points{i} = standardize_learn({new_img{i}});
    values = values+weight(i)*per_points{i};
end
stand_test_roi = map_img(test_roi,values);
stand_test = stand_test_roi+(test_im-test_roi);
% imshow(uint8(test_im));
% figure;
% imshow(uint8(stand_test));
% figure;
% imshow(uint8(new_img));
% hold on
%plot(1:size(test_im,2),test_layer);

gt_layer = test_layer(1:6,:);
gt_layer = [gt_layer;test_layer(8,:)];
layer_test = get_layer(test_im);
layer_stand = get_layer(stand_test);
mse1 = mse(layer_test,gt_layer);
mse2 = mse(layer_stand,gt_layer);
disp(mse1);
disp(mse2);