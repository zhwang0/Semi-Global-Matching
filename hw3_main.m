 %{
Author: zhihao Wang
Date: Apr 23, 2019

Purpose: 
Goals: 
    Dense stereo reconstruction for depth using Semi-Global Matching
    Algorithm. 
%}

%% === Configurations 
clear; 
clc; 

% show the long precision numbers 
format long g;

% data directory 
dir_data = '.\dataset\';
dir_res ='.\res2\';

% funtion directory
addpath('.\functions');

% global parameters 
isSaveFig = true; 
isSaveMat = true;
P = [3, 1, 0.5, 0.1, 0.05, 0.01;
     12, 4, 2, 0.4, 0.2 0.05];


%% === Read data
fprintf(1, 'Now start loading imgs ...\n');
tic;

load(strcat(dir_data, 'img_basic.mat')); 
load(strcat(dir_data, 'img_bonus.mat')); 

toc;
fprintf(1, 'Done!\n\n');


%% === extract a set of image 
nImg = length(img_basic); 
for n = [2 1]

    fprintf(1, 'Now start processing Image %d ...\n=====\n', n);
    tic;

    % read data 
    cur_img1 = img_basic{n}.img1; % left image 
    cur_img2 = img_basic{n}.img2; % right image 
    cur_img1_gray = rgb2gray(cur_img1); 
    cur_img2_gray = rgb2gray(cur_img2); 
    cur_proj1 = img_basic{n}.p1; % projection 
    cur_proj2 = img_basic{n}.p2;
    
    %{
    % crop for test 
    isCrop = false; 
    if isCrop
        cur_img1 = cur_img1(300:600,250:600,:); 
        cur_img2 = cur_img2(300:600,250:600,:);

        subplot(1,2,1);
        imshow(cur_img1);
        subplot(1,2,2);
        imshow(cur_img2);
    end
    %}
    nSize = size(cur_img1);

    % plot
    fig = figure;
    subplot(1,2,1); 
    imshow(cur_img1);
    title('Origin - Left');
    subplot(1,2,2);
    imshow(cur_img2);
    title('Origin - Right');
    if isSaveFig
        saveas(fig, strcat(dir_res, 'Img', num2str(n), '_Origin_LR.png'));
    end



    %% === Cost Computation 
    fprintf(1, 'Now start computing cost...\n');
    tic;

    % plot stereo analysis
    % A = stereoAnaglyph(cur_img1,cur_img2);
    % figure
    % imshow(A)
    % title('Red-Cyan composite view of the rectified stereo pair image')

    % compute data cost
    d_range = [0, 60]; % need to tune later 
    cur_cost_init = zeros(nSize(1), nSize(2), d_range(2)-d_range(1)+1); 
    cur_cost_init_r = zeros(nSize(1), nSize(2), d_range(2)-d_range(1)+1); 
    for d = 1:(d_range(2)-d_range(1)+1)
        tmp = [];
        tmp = computeDataCost(cur_img1, cur_img2, d-1, 2);  
        cur_cost_init(:,:,d) = tmp{1};
        cur_cost_init_r(:,:,d) = tmp{2}; 
    end
    % normalize (divided by the max of the max of all disparity)
    cur_cost_init = cur_cost_init / max(max(max(cur_cost_init)));
    cur_cost_init_r = cur_cost_init_r / max(max(max(cur_cost_init_r)));

    % display 
    % d_best = 13; % 33 disparity 
    % imshow(cur_cost_init(:,:,d_best));

    % plot data cost 
    [~, cur_cost_init_d] = WTA(cur_cost_init); 
    [~, cur_cost_init_d_r] = WTA(cur_cost_init_r); 
    fig = figure;
    subplot(1,2,1);
    imshow(cur_cost_init_d/d_range(2));
    title('Data Cost - Left');
    subplot(1,2,2);
    imshow(cur_cost_init_d_r/d_range(2));
    title('Data Cost - Right');
    if isSaveFig
        saveas(fig, strcat(dir_res, 'Img', num2str(n), '_data_cost_LR.png'));
    end

    toc;
    fprintf(1, 'Done!\n');


    %% === Cost Aggregation 
    fprintf(1, 'Now start aggregating cost...\n');
    tic;

    nExperiment = size(P); 
    for z = 1:nExperiment(2)
        P1 = P(1,z);
        P2 = P(2,z); 

        % the number of neighthoods
        nR = 8; 
        if nR == 8 
            r_basic = [1, 3, 5, 7]; % [R, U, L, D]
        elseif nR == 16
            r_basic = [1, 5, 9, 13]; 
        end

        % initialize Lr for different directions 
        Lr = [];
        Lr_r = [];
        for i = 1:nR
            Lr{i} = cur_cost_init;
            Lr_r{i} = cur_cost_init_r;
        end

        % update LR for each direction
        tmp_Lr = Lr;
        tmp_Lr_r = Lr_r;
        for r = 1:nR
            fprintf(1, '  Direction r %d ... \n', r);

            % generate the sequnce of the starting points for lines across the
            % image
            [row_range, col_range] = generateStartingPoints(r, r_basic, nSize);
            %{
            % test function 
            for i = row_range
                for j = col_range
                    isAggregated(i,j) = 1;

                     % obtain the pixels along the line with r degree
                    [tmp_r, tmp_c] = getLocInLine(i, j, r, [1 nSize(1)], [1 nSize(2)], r_basic);
                    for k = 1:length(tmp_r)
                        isAggregated(tmp_r(k), tmp_c(k)) = 1;
                    end
                end
            end
            fprintf(1, '%d --> min is %d\n', r,  min(min(isAggregated))); 
            %}

            for idx = 1:length(row_range)
                i = row_range(idx);
                j = col_range(idx); 
               % fprintf(1, "   %d %d ...\n", i, j);

                % obtain the pixels along the line with r degree
                [tmp_r, tmp_c] = getLocInLine(i, j, r, [1 nSize(1)], [1 nSize(2)], r_basic); 

                % compute the smooth cost
                tmp_Lr{r} = computeSmoothCost(tmp_r, tmp_c, tmp_Lr{r}, P1, P2);
                tmp_Lr_r{r} = computeSmoothCost(tmp_r, tmp_c, tmp_Lr_r{r}, P1, P2);

                %{
                for k = 1:length(tmp_r)
                    cur_i = tmp_r(k);
                    cur_j = tmp_c(k);
                    tmp_Lr{r}(cur_i,cur_j,:) = Lr{r}(cur_i,cur_j,:) + res(1,k,:);
                    isAggregated(cur_i,cur_j) = 1;        
                end

                % further process the rest poins on the line for
                % avoiding dupliatte computation.
                [updated_i, updated_j, tmp_r, tmp_c] = updateLocIdx(i, j, tmp_r, tmp_c); 
                while (updated_i ~= -1)   
                    if ~isAggregated(updated_i, updated_j)

                        % compute the smooth cost
                        res = computeSmoothCost(tmp_r, tmp_c, Lr{r}, P1, P2);

                        % update
                        tmp_Lr{r}(updated_i,updated_j,:) = Lr{r}(updated_i,updated_j,:) + res;
                        isAggregated(updated_i,updated_j) = true; 
                    end
                    [updated_i, updated_j, tmp_r, tmp_c] = updateLocIdx(updated_i, updated_j, tmp_r, tmp_c);            
                end
                %}
            end

        end
        Lr_final = tmp_Lr;
        Lr_final_r = tmp_Lr_r;

        % sum all directions as S(p,d)
        cur_cost_aggregated = zeros(nSize(1), nSize(2), d_range(2) - d_range(1) + 1);
        cur_cost_aggregated_r = zeros(nSize(1), nSize(2), d_range(2) - d_range(1) + 1);
        for i = 1:nR
            cur_cost_aggregated = cur_cost_aggregated + Lr_final{i};
            cur_cost_aggregated_r = cur_cost_aggregated_r + Lr_final_r{i};
        end
        
        % output
        if isSaveMat
            res_smooth{1} = cur_cost_aggregated;
            res_smooth{2} = cur_cost_aggregated_r;
            save(strcat(dir_res, 'Img', num2str(n), '_', num2str(P1), '_', num2str(P2), '.mat'), ...
                'res_smooth');
        end

        toc;
        fprintf(1, 'Done!\n');


        %% === Cost Computation  
        fprintf(1, 'Now start computing cost...\n');
        tic;

        % Winner Takes All (WTA) Strategy 
        [cur_cost_winner_v, cur_cost_winner_d] = WTA(cur_cost_aggregated);
        [cur_cost_winner_v_r, cur_cost_winner_d_r] = WTA(cur_cost_aggregated_r);

        % plot and save
        fig = figure;
        subplot(1,2,1)
        imshow(cur_cost_winner_d/d_range(2));
        title('Disparity Map - Left');
        subplot(1,2,2)
        imshow(cur_cost_winner_d_r/d_range(2));
        title('Disparity Map - Right');
        if isSaveFig
            saveas(fig, strcat(dir_res, 'Img', num2str(n), '_Unrefiend_', num2str(P1), '_', num2str(P2), '.png'));
        end

        toc;
        fprintf(1, 'Done!\n');


        %% === Disparity Refinement 
        fprintf(1, 'Now start refining disparity ...\n');
        tic;

        % obtain disaprity difference 
        tmp_diff = abs(cur_cost_winner_d - cur_cost_winner_d_r);
    %     valid_percent = [];
    %     for i = 1:round(d_range(2) / 2)
    %         valid_percent(i) = sum(sum(tmp_diff <= i))/(nSize(1)*nSize(2)) * 100;
    %     end
    %     plot(valid_percent, '-s');
    %     xlabel('Disparity Difference between Left and Right');
    %     ylabel('% of Within the Difference Range');

        % refine 
        refined = cur_cost_winner_d;
        refined( tmp_diff > 10) = NaN;
        figure;
        fig = imshow(refined / d_range(2));
        title('Disparity DIfference Greater than 10 as NaN');
        if isSaveFig
            saveas(fig, strcat(dir_res, 'Img', num2str(n), '_Refined_', num2str(P1), '_', num2str(P2), '.png'));
        end

        toc;
        fprintf(1, 'Done!\n');


        %% === Final Output - Left Image
        res_final = cur_cost_winner_d;
        figure; 
        fig = imagesc(cur_cost_winner_d);
        title(strcat('P1=', num2str(P1), ' & P2=', num2str(P2)));
        colorbar;
        if isSaveFig
            saveas(fig, strcat(dir_res, 'Img', num2str(n), '_Final_', num2str(P1), '_', num2str(P2), '.png'));
        end

        %% 3D Triangulation 
        projM{1} = cur_proj1;
        projM{2} = cur_proj2; 

        % initial 
        pts1_y = repmat(1:nSize(2), 1, nSize(1)); % col
        pts1_x = repelem(1:nSize(1), nSize(2));   % row 
        pts1 = [pts1_x', pts1_y'];
        pts2 = pts1; 

        % find corresponding points from the disparity map 
        pts2(:,2) = pts2(:,2) + reshape(res_final', nSize(1)*nSize(2), 1);
        pts = [pts1, pts2];

        % triangulate 3d points
        pts3d = Triangulate_M_proj(projM, pts);

        % add rgb
        pts_color = zeros(nSize(1)*nSize(2), nSize(3));
        for i = 1:nSize(3)
            pts_color(:,i) = reshape(cur_img1(:,:,i)', nSize(1)*nSize(2), 1);
        end

        % output
        res_pts = [pts3d, pts_color]; 
        dlmwrite(strcat(dir_res, 'Img', num2str(n), '_Point_Clouds_', num2str(P1), '_', num2str(P2), '.txt'), res_pts, 'Delimiter', '\t');

    end
end







