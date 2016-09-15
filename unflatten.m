function [img,layer]=unflatten(img,layer,delta)
    for i=1:size(img,2)
        img(:,i) = circshift(img(:,i),-delta(:,i));
        layer(:,i)=layer(:,i)-delta(:,i);
        
    end
end