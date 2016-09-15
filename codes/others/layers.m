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
        for j = p{m}(i):p{m+1}(i)
            A(j,i) = 1;
        end
    end
    mask{m} = A;
end         
y = {};
for i = 1:n-1
    y{i} = img.*mask{i};
end    
end