function test_seg = nn(img2,test_im,seg)
    % data =load('Subject_01_dn');
    % 
    % seg = data.manualLayer1new;
    % img1 = double(data.images_pp);
    % img2 = double(data.images_dn1);
    % img3 = double(data.images_dn2);


    L = 3;
    no_images = size(img2,3);
    % 
    % for i=1:no_images
    %     segm = seg(:,:,i);
    % end

    hist = {};
    for i=1:no_images
        hist{i} = imhist(uint8(img2(:,:,i)));
        hist{i}(1)=0;
        hist{i} = hist{i}/sum(hist{i});
    end

    kl = zeros(no_images,2);

    % test_im = img2(:,:,10);
    test_hist = imhist(uint8(test_im));
    test_hist(1)=0;
    test_hist = test_hist./sum(test_hist);


    for i=1:no_images
       kl(i,1) = KLDiv(hist{i},test_hist);
       kl(i,2) = i;
    end

    %Code may have to be changed to get correct indices in case of
    %randomization
    kl =kl';
    [kl,ind] = sort(kl(1,:));


    kl = kl(1:L);
    ind = ind(1:L);
    kl = ones(size(kl))./kl;
    tot = sum(kl);
    kl = kl./tot;

    test_seg = zeros(size(seg(:,:,1)));
    for i=1:L
        test_seg = test_seg + kl(i)*seg(:,:,ind(i));
    end
end