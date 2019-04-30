function [a, b] = getLinearPars(x0, y0, r, r_basic)
%{ 
GETLINEARPARS
Purpose: 
    Return the parameters for a linear system given a starting point and
    the direction.
    In most cases, this function is only called for non-vertical and non-horizontal line.  
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
    r_basic: the indices of [right, up, left, down]
Outputs: 
    a: gradient
    b: intersection
%}

a = NaN; 
b = NaN; 
if max(r_basic) <= 8
    nR = 8;
else
    nR = 16; 
end

% determine a and b 
if nR == 8
    if r < r_basic(2) || (r > r_basic(3) && r < r_basic(4))
        % negative 
        a = -1;
    else
        % positive 
        a = 1; 
    end
    
    b = y0 - a* x0; 
end

end

