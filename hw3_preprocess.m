%{
Author: zhihao Wang
Date: Apr 11, 2019

Purpose: preprocess all the image data and output three mat files
%}


%% === Configurations 
clear; 
clc; 

% show the long precision numbers 
format long g;

% data direction 
dir_data = '.\dataset\';

% global parameters
processBasic = true;
processBonus = true;

% the set of images
nBasic = [1, 2, 3]; 
nBonus = [4, 5]; 


%% == lazy snapping
if processBasic
   
    fprintf(1, 'Processing Data for Basic questions.. \n');
    tic;
    
    img_basic = [];

    % setup directory
    for t = nBasic
        % dataset directory 
        tmp_dir_data = strcat(dir_data, 'data', int2str(t), '\');
        % png images
        file_pattern = fullfile(tmp_dir_data, '*.png');        
        img_files = dir(file_pattern);
        % tif image
        file_pattern = fullfile(tmp_dir_data, '*.tif');
        img_files_tif = dir(file_pattern);

        % initializing
        nImg = length(img_files) + 1;
        tmp_img_col = [];
        nameImg = [];

        % read images 
        for i = 1:nImg
            if i ~= nImg
                base_file_name = img_files(i).name;
            else
                base_file_name = img_files_tif.name;
            end

            full_file_name = fullfile(tmp_dir_data, base_file_name);
            fprintf(1, '	Reading %s\n', full_file_name);

            %image_name
            tmp = strsplit(base_file_name, '.');
            nameImg{i} = string(tmp(1));

            % store image in the image cell
            tmp_img_col{i} = imread(full_file_name);

            % test
%             figure;
%             imshow(tmp_img_col{i});
%             drawnow; 
        end
        
        % read txt
        tmp_p = [];
        for i = 1:2
            tmp_p_sub = [];
            fileID = fopen(strcat(tmp_dir_data, 'P', int2str(i), '.txt'),'r');
            while ~feof(fileID)
                tmp_line = fgetl(fileID);
                if tmp_line == -1 
                    continue; 
                end
                tmp_num = str2num(tmp_line);
                tmp_p_sub = [tmp_p_sub; tmp_num];
            end
            fclose(fileID);    
            
            tmp_p{i} = tmp_p_sub;
        end
        
        % update 
        img_basic_sub = [];
        img_basic_sub.img1 = im2double(tmp_img_col{1});
        img_basic_sub.img2 = im2double(tmp_img_col{2});
        img_basic_sub.disp = im2double(tmp_img_col{3});
        img_basic_sub.p1 = tmp_p{1};
        img_basic_sub.p2 = tmp_p{2};
        img_basic{t} = img_basic_sub;
        
        clear img_basic_sub;
        
    end
    
    save('.\dataset\img_basic.mat', 'img_basic');
    fprintf(1, 'Done! ');
    toc;
    fprintf(1, '\n');
end


%% == Bonus Images 
if processBonus
    
    fprintf(1, 'Processing Data for Bonus questions .. \n');
    tic;
    
    img_bonus = [];

    % setup directory
    for t = nBonus
        tmp_dir_data = strcat(dir_data, 'data', int2str(t), '\');
        file_pattern = fullfile(tmp_dir_data, '*.png');
        img_files = dir(file_pattern);

        nImg = length(img_files);
        tmp_img_col = [];
        nameImg = [];

        % read images 
        for i = 1:nImg
            base_file_name = img_files(i).name;
            full_file_name = fullfile(tmp_dir_data, base_file_name);
            fprintf(1, '	Reading %s\n', full_file_name);

            %image_name
            tmp = strsplit(base_file_name, '.');
            nameImg{i} = string(tmp(1));

            % store image in the image cell
            tmp_img_col{i} = imread(full_file_name);

            % test
%             figure;
%             imshow(tmp_img_col{i});
%             drawnow; 
        end
        
        % update 
        img_bonus_sub = [];
        img_bonus_sub.img1 = im2double(tmp_img_col{1});
        img_bonus_sub.img2 = im2double(tmp_img_col{2});
        img_bonus{t - nBonus(1) + 1} = img_bonus_sub;
        
        clear img_bonus_sub;
    end
    
    % save 
    save('.\dataset\img_bonus.mat', 'img_bonus');
    fprintf(1, 'Done!');
    toc;
    fprintf(1, '\n');
end


