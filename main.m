%Announcement: Yaowei Ma(ID:2016302590151) finished all of the following
%code (except the idea of www.pudn.com) by himself.
%2019.4.21.

clear
% parpool%Comment it if you don't need parallel computing.
%Read Images

img1_origin=imread('Image/13.jpg');
if size(img1_origin,3) > 1
    img1 = rgb2gray(img1_origin);
end
[Descriptors_1,Feature_Points_1]=multi_scale_candidates(img1);


img2_origin=imread('Image/14.jpg');
if size(img2_origin,3) > 1
    img2 = rgb2gray(img2_origin);
end
[Descriptors_2,Feature_Points_2]=multi_scale_candidates(img2);

img=[img1_origin,img2_origin];
imshow(img);
hold on;
[h,w]=size(img1);
flag_1=zeros(size(Descriptors_1,1),1);
flag_2=zeros(size(Descriptors_2,1),1);

for i = 1:length(Feature_Points_1)
    diff=Descriptors_2-Descriptors_1(i,:);
    distance=sum(abs(diff).^2,2).^(1/2);
    distance=distance((distance<100));
    [~,locs]=sort(distance);
    loc=locs(length(1));
    if(0<distance(loc) && distance(loc)<15)
        flag_1(i)=loc;
    end
    
end

for i = 1:length(Feature_Points_2)
    diff=Descriptors_1-Descriptors_2(i,:);
    distance=sum(abs(diff).^2,2).^(1/2);
    distance=distance((distance<100));
    [~,locs]=sort(distance);
    loc=locs(length(1));
    if(0<distance(loc) && distance(loc)<15)
        flag_2(i)=loc;
    end
    
end

for i = 1:length(Feature_Points_1)
    if(flag_1(i)~=0)
        if(flag_2(flag_1(i))==i)
            loc=flag_1(i);
            plot(Feature_Points_1(i,2),Feature_Points_1(i,1),'go');
            hold on;
            plot(Feature_Points_2(loc,2)+w,Feature_Points_2(loc,1),'go');
            hold on;
            plot([Feature_Points_1(i,2),Feature_Points_2(loc,2)+w],[Feature_Points_1(i,1),Feature_Points_2(loc,1)]);
        end
    end
end






