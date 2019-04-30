function [res] = colorDiff(img1, img2, color_opt)
%{ 
COLORDIFF: 
Purpose: 
    Compute the color difference between two images
    diff = sqrt( sum( img1(i,j,c) - img2(i,j,c) ) ) 
Inputs: 
    im1 & img2
    opt: 
        1: RGB color difference 
        2. CIELAB color difference 
Outputs: 
    the color differece
%}

nSize = size(img1); 
res = zeros(nSize(1), nSize(2)); 

% decide color space 
if color_opt == 2
    img1 = rgb2lab(img1); 
    img2 = rgb2lab(img2);
end

% compute cost
tmp = (img1 - img2).^2;
if length(nSize) > 2
    for c = 1:nSize(3)
        res = res + tmp(:,:,c);
    end
else
    res = tmp; 
end
res = sqrt(res);

% without smooth for RGB color difference 
if color_opt == 1
    return;
end

% smooth
res_new = res; 
for i = 2:(nSize(1)-1) 
    for j = 2:(nSize(2)-1)
        res_new(i,j) = sum(sum(res(i-1:i+1, j-1:j+1)));
    end
end
res = medfilt2(res_new);
    
end

