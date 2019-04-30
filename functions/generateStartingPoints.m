function [r_range,c_range] = generateStartingPoints(r,r_basic, nSize)
%{
GENERATESTARTINGPOINTS
Purpose: 
    Generates the sequence of starting points for all lines across the
    iamge 
Inputs: 
    r: directions 1-8 or 1-16
    r_basic: the indices of [R U L D]
    nSize: image size [row col] 
Outputs: 
    r_range & c_range: the corresponding row and col pairs of the starting
    points of lines
%}

if r == r_basic(1)
    % to right 
    r_range = 1:nSize(1);
    c_range = ones(1, nSize(1));
elseif r > r_basic(1) && r < r_basic(2)
    % to up-right 
    r_range1 = 1:nSize(1);
    r_range2 = ones(1, nSize(2)-1) * nSize(1); 
    r_range = [r_range1, r_range2];
    
    c_range1 = ones(1,nSize(1)-1); 
    c_range2 = 1:nSize(2); 
    c_range = [c_range1, c_range2];
elseif r == r_basic(2)
    % to up 
    r_range = ones(1,nSize(2)) * nSize(1);
    c_range = 1:nSize(2);
elseif r > r_basic(2) && r < r_basic(3) 
    % to up-left 
    r_range1 = ones(1, nSize(2)-1) * nSize(1);
    r_range2 = sort(1:nSize(1), 'descend'); 
    r_range = [r_range1, r_range2]; 
    
    c_range1 = 1:nSize(2);
    c_range2 = ones(1, nSize(1)-1) * nSize(2); 
    c_range = [c_range1, c_range2];     
elseif r == r_basic(3) 
    % to left
    r_range = 1:nSize(1);
    c_range = ones(1, nSize(1)) * nSize(2); 
elseif r > r_basic(3) && r < r_basic(4)
    % to bottom-left 
    r_range1 = ones(1, nSize(2)-1);
    r_range2 = 1:nSize(1);
    r_range = [r_range1, r_range2]; 
    
    c_range1 = 1:nSize(2);
    c_range2 = ones(1, nSize(1)-1) * nSize(2); 
    c_range = [c_range1, c_range2];
elseif r == r_basic(4) 
    % to bottom
    r_range = ones(1, nSize(2));   
    c_range = 1:nSize(2); 
else
    % to bottom-right
    r_range1 = sort(1:nSize(1), 'descend');
    r_range2 = ones(1, nSize(2)-1); 
    r_range = [r_range1, r_range2];
    
    c_range1 = ones(1, nSize(1)-1);
    c_range2 = 1:nSize(2);
    c_range = [c_range1, c_range2]; 
end

end

