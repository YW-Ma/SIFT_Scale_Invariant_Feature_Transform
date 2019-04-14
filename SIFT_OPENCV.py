import numpy as np
import cv2
import matplotlib.pyplot as plt
import pandas as pd

pathName=r'Image\miao.jpg'
img=cv2.imread(pathName)
gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)

sift = cv2.xfeatures2d.SIFT_create()
kp,des = sift.detectAndCompute(gray,None)
octave = np.zeros(3598)
for i in range(3598):
    octave[i] = kp[i].octave
rects=plt.bar(range(len(octave)),octave)
plt.show()

# kp = kp[825:835]
# des = des[825:835]
img=cv2.drawKeypoints(gray,kp,img,flags=cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)

cv2.imshow('img',img)
cv2.waitKey()

