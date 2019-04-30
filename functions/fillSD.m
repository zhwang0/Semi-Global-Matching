function [res] = fillSD(tmp_cost, idx, tmp_r, tmp_c, tmp_lr)
%{ 
RECURFILLSD 
Purpose: 
    fill the smoooth costs 
Input:
    tmp_cost: predefined empty matrix for store the cost
    idx = current location 
    tmp_r & tmp_c: the point set of the target points along the line 
    tmp_lr: current data cost 
%} 

if idx ~= length(tmp_r)
    res = fillSD(tmp_cost, idx+1, tmp_r, tmp_c, tmp_lr);
    tmp_cost = res; % udate tmp_cost to the previous state
    % tmp = res(1,idx+1,:); % extract the value from the previous 
else
    tmp = 0;
end

% select the previous cost
tmp_cost(1,idx,:) = tmp_lr(tmp_r(idx), tmp_c(idx), :);
% tmp_cost(1,idx,:) = tmp + tmp_lr(tmp_r(idx), tmp_c(idx), :);
res = tmp_cost; 

end

