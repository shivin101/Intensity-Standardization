function values = standardize_learn(img)
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

    values = zeros(1,11);
    
    for i =1:size(hist,2)    
        function_value = find_percentile(hist{i});
        function_value = interp1([function_value(1),function_value(end)],[0,255],function_value,'liner','extrap');
        values = values + function_value;
    end

    values = values/size(hist,2);
    values(1)=start_lim;
end