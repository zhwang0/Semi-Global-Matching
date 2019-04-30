function [res_y, res_x] = getLocInLine(y0, x0, r, y_lim, x_lim, r_basic)
%{
GETLOCINLINE
Purpose:
    Returns the x(col) and y(row) loctions from (x0, y0) along a line in the
    direction of r
Inputs: 
    (x0, y0): starting point
    r: direction of line: 
        1: to right
        2: to right + 45'
        3: to up
        4: to up + 45'
        5: to left
        6: to left + 45'
        7: to down
        8: to down + 45'
    x_lim, y_lim: the image size 
    r_basic: the indices of [right, up, left, down]
Outputs: 
    (res_x, res_y): a list of the pixel location (y/row, x/col) 
    along the line
%}

% basic info
res_x = [];
res_y = [];
r_ver = [r_basic(1), r_basic(3)];
r_hor = [r_basic(2), r_basic(4)];


% retrieve the x and y index of the points locating on the line
if ismember(r, r_ver)
    % vertical line 
    if r == r_basic(1)
        % to right
        res_x = sort(x0:x_lim(2), 'descend');
    else 
        % to left
        res_x = x_lim(1):x0;
    end
    res_y = repmat(y0, 1, length(res_x)); 
    
elseif ismember(r, r_hor)
    % horizontal line
    if r == r_basic(2)
        % to up 
        res_y = y_lim(1):y0;
    else
        % to down 
        res_y = sort(y0:y_lim(2), 'descend');
    end
    res_x = repmat(x0, 1, length(res_y)); 
    
else
    % normal line
    [a, b] = getLinearPars(x0, y0, r, r_basic);
    
    if r < r_basic(2) || r > r_basic(4)
        % to RHS
        if r < r_basic(2)
            max_x = (y_lim(1) - b) / a; % not suitable for 16 neighbors
        else
            max_x = (y_lim(2) - b) / a; 
        end
        % remove the locations outside the boundary 
        res_x = sort(x0:min(x_lim(2), max_x), 'descend');
    else
        % to LHS
        if r < r_basic(3) 
            min_x = (y_lim(1) - b) / a; 
        else 
            min_x = (y_lim(2) - b) / a; 
        end
        % remove the locations outside the boundary 
        res_x = max(x_lim(1), min_x):x0; 
    end
    res_y = res_x * a + b; 
    
end 

end

