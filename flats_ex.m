data = load('Subject_05_dn.mat');
img = data.images_dn2;
layers = data.manualLayer1new;
no = 9;
[im,lay,del] = flatten_im(img(:,:,no),layers(:,:,no));
figure;
imshow(uint8(im));
hold on
plot(1:800,lay)
a = input('continue');

[im2,lay2] = unflatten(im,lay,del);
figure;
imshow(uint8(im2));
hold on
plot(1:800,lay2)