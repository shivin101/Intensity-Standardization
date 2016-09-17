function standard_img = map_img(img,scale)
    img = uint8(img);
    hist = double(imhist(uint8(img)));
    hist(1)=0;
    hist = hist./sum(hist);
    per_points = find_percentile(hist);
    per_points = interp1([per_points(1),per_points(end)],[0,255],per_points,'liner','extrap');
    per_points(1)=2;
    per_points = round(per_points);
    img = double(img);
    standard_img = ((interp1([per_points],scale,img,'liner','extrap')));
end