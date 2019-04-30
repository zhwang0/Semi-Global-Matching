function [updated_i, updated_j, tmp_r, tmp_c] = updateLocIdx(cur_i, cur_j, tmp_r, tmp_c)
%{
UPDATELOCIDX
Purpose: 
    Update the Location indices in the retrieved lits 
Inputs: 
    cur_i, cur_j: current row and col locations 
    tmp_r, tmp_c: location lists along the line 
Outputs:
    updated_i, updated_j: updaed row and col locations 
    tmp_r, tmp_c: new location lists for the next iteration 
%}

% find the index of the number which need to be removed
idx_remove = find(tmp_r == cur_i);
if length(idx_remove) ~= 1
    idx_remove = find(tmp_c == cur_j);
end
tmp_r(idx_remove) = [];
tmp_c(idx_remove) = [];

% check there is no location
if isempty(tmp_r)
    updated_i = -1;
    updated_j = -1;
    return
end

% update current index
if idx_remove ~= 1
    % end of the list 
    updated_i = tmp_r(end);
    updated_j = tmp_c(end);
else
    % front of the list 
    updated_i = tmp_r(1);
    updated_j = tmp_c(1);
end

end

