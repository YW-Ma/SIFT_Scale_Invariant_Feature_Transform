Scale-invariant feature transform
======
重要提示：【我发现这个代码是有问题的，还在加工中，请大家不要参考。】
NOTICE: Unexpected behaviors are found in execution. Please do not refer to this code!!!

Introduction
--------
* A robust algorithm in CV to `detect` and `describe` `local features` in images.
* The implementations is different from the origin paper in the section of `detect` to make it run faster.
* For more details:
    * [Wikipedia - Scale-invariant feature transform](https://en.wikipedia.org/wiki/Scale-invariant_feature_transform)
    * [UCF Computer Vision Video Lectures 2012, Dr. Mubarak Shah](https://www.youtube.com/watch?v=NPcMS49V5hg)
    * [OpenCV tutorials](https://opencv-python-tutroals.readthedocs.io/en/latest/py_tutorials/py_feature2d/py_sift_intro/py_sift_intro.html)
    * [SIFT-on-MATLAB](https://github.com/aminzabardast/SIFT-on-MATLAB) 

Pre-requisites
----------
* `MATLAB`
* Patience

Usage
----------
* Clone
* Adjust `main.m` to choose one-scale or multi-scale mode.
* Run
* Notice: This code is for reference only, because of the problem with the implementation of its `detect` section.

Results & Evaluation
-----------
* Honestly speaking, Affine-SIFT algorithm is much better than SIFT, since it simulates different angles of perspectives.
* It seems that the difference between my implementation and OpenCV's implementation is fatal problem. My candidates is much sparser!
![](https://github.com/YW-Ma/SIFT_Scale_Invariant_Feature_Transform/blob/master/multi.jpg)
