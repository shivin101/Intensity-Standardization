function gen_img = standardize(img,new_im)
    %Learn Percentile Points from give Images
%     img = {};
    
    presicion = 256;
    start_lim = 2;
    end_lim =255;

%     img{1} = imread('img1.jpg');
%     img{2} = imread('img2.jpg');
%     img{3} = imread('img3.jpg');
%     img{4} = imread('img4.jpg');

    hist = {};
    for i=1:size(img,2)
        hist{i} = imhist(uint8(img{i}),presicion);
        hist{i}(1)=0;
    end

    points = {};
    

    for i =1:size(hist,2)    
        points{i} = find_percentile(hist{i});    
    end

    values = zeros(1,10);
    
    for i =1:size(hist,2)    
        function_value = find_percentile(hist{i});
        function_value = interp1([function_value(1),function_value(end)],[0,255],function_value,'liner','extrap');
        values = values + function_value;
    end

    values = values/size(hist,2);
    values(1)=start_lim;

%     New Image 

%     new_im = double(img{1});
    new_im = uint8(new_im);
    img_hist = imhist(uint8(new_im),presicion);
    img_hist(1)=0;

    img_points = find_percentile(img_hist);
    img_points = interp1([img_points(1),img_points(end)],[0,255],img_points,'liner','extrap');
    img_points(1)=start_lim;

    gen_img = double(new_im);
    pixels = zeros(size(gen_img));

    gen_img = interp1(img_points,values,gen_img,'liner','extrap');
    
%     subplot(1,2,1);
%     imshow(uint8(gen_img));
%     subplot(1,2,2)
%     imshow(uint8(new_im));

%     hist1 = imhist(uint8(new_im));
%     hist1(1)=0;
%     hist2 = imhist(uint8(gen_img));
%     hist2(1)=0;
%     x=1:256;
%     figure;
%     hold on
%     or_im = plot(x,hist{1});
%     ne_im = plot(x,hist2);
%     lab1 = 'original';
%     lab2 = 'processed';
%     legend(lab1,lab2); 
end