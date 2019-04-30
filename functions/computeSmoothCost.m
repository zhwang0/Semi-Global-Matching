function res = computeSmoothCost(tmp_r, tmp_c, tmp_lr, P1, P2)
%{
COMPUTESMOOTHCOST
Purpose:
    Compute the smooth cost for all disparities given a target point set
Inputs:
    tmp_r, tmp_c: the row and column locations on the target line 
    tmp_lr: the Lr in the current direction 
    P1, P2: penalty coefficients
    isAggregated; if the pixel is calculated
Outputs:
    res: smooth cost in all disparities for all points 
%}


nSize = size(tmp_lr); 

% obtain the costs
% tmp_cost = Inf(1, length(tmp_r), nSize(3));
% res_cost = fillSD(tmp_cost, 1, tmp_r, tmp_c, tmp_lr); 

% obtain costs for each pixel pair
for i = 1:length(tmp_r)     
    % initialize costs
    cur_cost = zeros(1, 1, nSize(3)); 
    
    % update Lr
    if i ~= 1
        pre_cost = tmp_lr(tmp_r(i-1), tmp_c(i-1),:);
    else 
        pre_cost = tmp_lr(tmp_r(i), tmp_c(i),:);
    end
    
    min_cost = min(pre_cost); % minLr(p-r, k) 
    
    % extract the cost for each disparity 
    for d = 1:nSize(3)
        % initial
        cost1 = Inf; % Lr(p-r,d) 
        cost2 = Inf; % Lr(p-r,d-1) + P1 
        cost3 = Inf; % Lr(p-r,d+1) + P1 
        cost4 = Inf; % Lr(p-r,i) + P12
         
        tmp = pre_cost; 
        cost1 = tmp(d);
        if d ~= nSize(3)
            cost3 = tmp(d+1) + P1;
            tmp(d+1) = []; % remove 
        end
        tmp(d) = []; % remove 
        if d ~= 1
            cost2 = tmp(d-1) + P1;
            tmp(d-1) = []; % remove 
        end 
        cost4 = min(tmp) + P2; 

        % update 
        cur_cost(1,1,d) = min([cost1, cost2, cost3, cost4]) - min_cost;
          
    end
    
    % update
    tmp_lr(tmp_r(i), tmp_c(i), :) = tmp_lr(tmp_r(i), tmp_c(i), :) + cur_cost(1,1,:);
    % fprintf(1, '(%d,%d) - %f \n', tmp_r(i), tmp_c(i), min(tmp_lr(tmp_r(i), tmp_c(i), :)));

end

res = tmp_lr; 

end

%{
Backup Codes (Replacing the funtion directly should be fine)

                    % initialize 
                    cost1 = Inf; % Lr(p-r,d) 
                    cost2 = Inf; % Lr(p-r,d-1) + P1 
                    cost3 = Inf; % Lr(p-r,d+1) + P1 
                    cost4 = Inf; % Lr(p-r,i) + P12
                    min_cost = 0; % minLr(p-r, k) 
                    
                    % obtain the costs
                    tmp_cost = Inf(d_range(2) - d_range(1) + 1, 1);
                    for k = 1:(d_range(2) - d_range(1))
                        tmp = Lr{r}(:,:,k);
                        tmp_cost(k,1) = min(tmp(sub2ind(size(tmp), tmp_r, tmp_c)));
                    end

                    % extract the minimum path
                    min_cost = min(tmp_cost);
                    cost1 = tmp_cost(d, 1);
                    if d ~= d_range(2) - d_range(1) + 1
                        cost3 = tmp_cost(d+1, 1) + P1;
                        tmp_cost(d+1) = [];
                    end
                    if d ~= 1 
                        cost2 = tmp_cost(d-1, 1) + P1;
                        tmp_cost(d-1) = [];
                    end 
                    cost4 = min(tmp_cost) + P2; 

===backup2=======

tmp_cost = Inf(1, length(tmp_r), nSize(3));
for i = 1:length(tmp_r)
    for k = 1:nSize(3)
    %     % from end to front 
    %     cur_i = length(tmp_r) - i + 1;
    %     
    %     % recursively fill the data from the end to front
    %     tmp_cost(cur_i,:) = tmp_lr(tmp_r(cur_i), tmp_c(cur_i), :); 

        tmp = tmp_lr(:,:,k);
        tmp_cost(1,i,k) = sum(tmp(sub2ind(size(tmp), tmp_r(i:end), tmp_c(i:end))));
    end
end

%}
