function y = layers(img,layer)
%img is loaded image; is an array;
%n = number of layers present;
%layer  ixj double
n = size(layer,1);
for i = 1:n
    p{i} = layer(i,:);
end
mask = {};
for m = 1:n-1
    A = zeros(size(img,1),size(img,2));
    for i = 1:size(img,2)
        for j = p{m}(i):p{m+1}(i)-1
            A(j,i) = 1;
        end
    end
    mask{m} = A;
end         
y = {};
img_new = zeros(size(img));
for i = 1:n-1
    y{i} = img.*mask{i};
    img_new = img_new+y{i};
end
%imshow(uint8(img));
%figure;
%imshow(uint8(img_new));
end