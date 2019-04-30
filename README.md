# Semi-Global-Matching (SGM)

This repo is built for completing the final project in SP19 ECE Computer Vision.  

As one of the most famous algorithms for dense stereo reconstruction, SGM algorithm is implemented in this assignment. 

The core of SGM is to obtain the disparity map using the Mutual Information and semi-global smoothness constraint. 

Due to the limited time, the data cost is simplified as **the photo-consistency** while **dynamic programming** is used to 
update the smooth cost in eight directions. 

After the refinement, the disparity maps show the best results when the penalty parameter are around 0.1 for P1 and 0.4 for P2. 

Future work is recommended to use the Mutual Information as the initial data cost for reconstructing more accurate results.
