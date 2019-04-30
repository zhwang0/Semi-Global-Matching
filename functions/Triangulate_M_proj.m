% triangulate the 3D points from 2D correspondences using projection
% matrix, it supports multiple project matrix in a cell format, you can
% easily change the formulation here. ProjM_cell{p} is 3X4 matrix.
% correspts has a dimension of [numpts] x [number_projmatrix * 2], every
% two columns of correspts contains x,y, on the image following the
% sequence of projection_matrix storing in the ProjM_cell.
%%
% Rongjun Qin for CE7453 qin.324@osu.edu, The Ohio State University
% Nov 8, 2017.
function pt3D = Triangulate_M_proj(ProjM_cell,corespts)

[numpts,ncols] = size(corespts);
numprojmatr = length(ProjM_cell);

if (numprojmatr * 2 ~= ncols)
    
    disp('number of projection matrix does not match the image points');
    return;
    
end


% formulating A Matrix
pt3D = zeros(numpts,3);
for p = 1:numpts
    A = zeros(numprojmatr*3,4);
    for pp = 1:length(ProjM_cell)
        pt_indx = p;
        impt_indx_x = (pp-1)*2+1;
        impt_indx_y =     pp*2;
        pt_cur_homo = [corespts(pt_indx,impt_indx_x),corespts(pt_indx,impt_indx_y),1];
        A(((pp-1)*3+1) : (pp*3),:) = skew_from_vec_3(pt_cur_homo)*ProjM_cell{pp};    % constructing A matrix.
    end
    
    [U,S,V] = svd(A);
    sol_X = V(:,end)';
    sol_X = sol_X./sol_X(4);  % get the Euclidean coordiantes from the homogeneous coordaintes.
    
pt3D(p,:) = sol_X(1:3)';   % aranged by rows.

if (mod(p,1000) == 0)
    disp(p);
end

end

end