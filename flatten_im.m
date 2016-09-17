function [im2,layers,change] = flatten_im(im,layers)
    %The brightest pixel of each column is taken as the rpe
    rpe = zeros(size(im,2),1);
    win = 4;
    thresh = 10;

    for i=1:size(im,2)
        k = find(im(:,i) == max(im(:,i)));
%         In case multiple pixels have the brightest value take their
%         average
        if(length(k)>1)
            k=mean(k);
        end
        rpe(i) = k;
    end

%     Find the outliers and fit a polynomial
%     disp(rpe);
    x = [];
    y = [];
    count = 1;
    for k =1:size(im,2)
        idx1 = max(k-win,1);
        idx2 = min(k+win,size(im,2));
        avg = median(rpe(idx1:idx2));
        if(~(rpe(k)<(avg-thresh) || rpe(k)>(avg+thresh)))
            y(count) = rpe(k);
            x(count) = k;
            count = count + 1;
        end
        
    end
%     
%     disp(x);
%     disp(y);

    p = polyfit(x,y,5);
    x = 1:size(im,2);
    y=polyval(p,x);
%     disp(y);
%     
%     figure;
%     imshow(uint8(im));
%     hold on;
%     plot(x,y);
%     pause(1);
    
    y = floor(y);
    lowest = max(y);
    change = zeros(1,size(im,2));
    for i=1:size(im,2)
        idx1 = max(i-win,1);
        idx2 = min(i+win,size(im,2));
        change(:,i) = round(lowest-median(y(idx1:idx2)));
        im2(:,i) = circshift(im(:,i),change(:,i));
        layers(:,i)=layers(:,i)+change(:,i);
        
    end
%     figure;
%     imshow(uint8(im));
%     figure;
%     imshow(uint8(im2));
%     imshow(uint8(im2));
%     hold on
%     plot(1:800,layers);


end