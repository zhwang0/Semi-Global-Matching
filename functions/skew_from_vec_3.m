% get skew matrix from a 3-D vector
% Rongjun Qin for CE7453 qin.324@osu.edu, The Ohio State University
% Nov 8, 2017.
function S_x = skew_from_vec_3(x)

S_x=[0 -x(3) x(2) ; x(3) 0 -x(1) ; -x(2) x(1) 0 ];

end