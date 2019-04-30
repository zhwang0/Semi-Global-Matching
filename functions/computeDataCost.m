function [res] = computeDataCost(img1, img2, d, opt)
%{ 
COMPUTECOST Cost
Purpose: 
    Compute the initial data cost between two rectified images. 

Input: 
    img1: the left image
    img2: the right image 
    d: disparity 
    opt: 
        1: the cost based on the RGB color difference
        2: the cost based on the CIELAB difference with noise removing

output: 
    the data cost given the certain disparity and cost measurement
%}

nSize = size(img1); 
if length(nSize) < 3
    tmp_shift_R = zeros(nSize(1), nSize(2));
else
    tmp_shift_R = zeros(nSize(1), nSize(2), nSize(3));
end

% shift the right image
if (d >= 0) && (d < nSize(2))
    tmp_shift_R(:, (d+1):nSize(2), :) = img2(:, 1:(nSize(2)-d), :); 
else
    % defaut is that img2 is the right image 
    tmp_shift_R = img2;
end

% compute the difference 
res{1} = colorDiff(img1, tmp_shift_R, opt);


% shift the left image for refinements 
if opt == 2
    tmp_shift_L = zeros(nSize(1), nSize(2), nSize(3));
    if (d >= 0) && (d < nSize(2))
        tmp_shift_L(:, 1:(nSize(2)-d), :) = img1(:, (d+1):nSize(2), :); 
    else
        % defaut is that img2 is the right image 
        tmp_shift_L = img1;
    end

    res{2} = colorDiff(img2, tmp_shift_L, opt);
    
end

end

