Scale-invariant feature transform
======
Introduction
--------
* A robust algorithm in CV to `detect` and `describe` `local features` in images.
* The implementations is different from the origin paper in the section of `detect` to make it run faster.
* For more details:
    * [Wikipedia - Scale-invariant feature transform](https://en.wikipedia.org/wiki/Scale-invariant_feature_transform)
    * [UCF Computer Vision Video Lectures 2012, Dr. Mubarak Shah](https://www.youtube.com/watch?v=NPcMS49V5hg)
    * [OpenCV tutorials](https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_feature2d/py_sift_intro/py_sift_intro.html)
    * [SIFT算法的Matlab实现](https://www.sun11.me/blog/2016/sift-implementation-in-matlab/) 

Pre-requisites
----------
* `MATLAB`
* Patience

Usage
----------
* Clone
* Adjust `main.m` to choose one-scale or multi-scale mode.
* Run

Results & Evaluation
-----------
* Honestly speaking, Affine-SIFT algorithm is much better than SIFT, since it simulates different angles of perspectives.
* It seems that the difference between my implementation and OpenCV's implementation is fatal problem. My candidates is much sparse!
![](https://github.com/YW-Ma/SIFT_Scale_Invariant_Feature_Transform/blob/master/multi.jpg)
