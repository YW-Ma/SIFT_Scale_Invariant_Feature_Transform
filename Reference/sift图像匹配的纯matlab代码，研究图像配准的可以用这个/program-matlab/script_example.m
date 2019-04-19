
img3 = imread('ima3.jpg');

figure(5);
image(img3);
colormap(gray(256));
title('ima3.jpg');

drawnow;

% Detect the SIFT features:
fprintf(1,'Computing the SIFT features for ima3.jpg...\n')
[features3,pyr3,imp3,keys3] = detect_features(img3);

figure(6);
showfeatures(features3,img3,1);
title('SIFT features of image ima3.jpg');

