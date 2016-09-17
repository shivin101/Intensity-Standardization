function [kl,ind] = nn_roi(img2,test_im)
    


    L = 3;
    no_images = size(img2,3);
   
    hist = {};
    for i=1:no_images
        hist{i} = imhist(uint8(img2(:,:,i)));
        hist{i}(1)=0;
        hist{i} = hist{i}/sum(hist{i});
    end

    kl = zeros(no_images,2);

    test_hist = imhist(uint8(test_im));
    test_hist(1)=0;
    test_hist = test_hist./sum(test_hist);


    for i=1:no_images
       kl(i,1) = KLDiv(hist{i},test_hist);
       kl(i,2) = i;
    end


    kl =kl';
    [kl,ind] = sort(kl(1,:));


    kl = kl(1:L);
    ind = ind(1:L);
    kl = ones(size(kl))./kl;
    tot = sum(kl);
    kl = kl./tot;

    
end