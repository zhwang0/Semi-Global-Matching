function [res_v,res_d] = WTA(target)
%{
WTA(winner takes all) 
Purpose: 
    Find the minimal costs in different disparity for each pixel
Input:
    target: M*N*D - image cost in D disparities 
Output: 
    res_v: the minimum cost values 
    res_d: the corresponding disparity 
%}

% obtain basic info
nSize = size(target); 

% initialization 
res_v = zeros(nSize(1), nSize(2));
res_d = zeros(nSize(1), nSize(2));

% find the minimum 
for i = 1:nSize(1) 
    for j = 1:nSize(2) 
        [tmp_v, tmp_d] = min(target(i,j,:)); 
        
        % update 
        res_v(i,j) = tmp_v; 
        res_d(i,j) = tmp_d;
    end 
end 

end

