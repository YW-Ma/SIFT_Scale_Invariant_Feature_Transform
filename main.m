%Announcement: Yaowei Ma(ID:2016302590151) finished all of the following
%code (except the idea of www.pudn.com) by himself.
%2019.5.7.

clear
% parpool%Comment it if you don't need parallel computing.
%Read Images

img1_origin=imread('Image/001.jpg');
disp('(1/5) Finish loading image 1.')
if size(img1_origin,3) > 1
    img1 = rgb2gray(img1_origin);
end
[Descriptors_1,Feature_Points_1]=multi_scale_features(img1);
disp('(2/5) Finish generating descriptors for image 1.')

img2_origin=imread('Image/002.jpg');
disp('(3/5) Finish loading image 2.')
if size(img2_origin,3) > 1
    img2 = rgb2gray(img2_origin);
end
[Descriptors_2,Feature_Points_2]=multi_scale_features(img2);
disp('(4/5) Finish generating descriptors for image 2.')

img=[img1_origin,img2_origin];
imshow(img);
hold on;
[h,w]=size(img1);
% for i = 1:length(Feature_Points_1)
%     plot(Feature_Points_1(i,2),Feature_Points_1(i,1),'go');
%     hold on;
%     plot(Feature_Points_2(i,2)+w,Feature_Points_2(i,1),'go');
%     hold on;
% end

flag_1=zeros(size(Feature_Points_1,1),1);
flag_2=zeros(size(Feature_Points_2,1),1);

for i = 1:size(Feature_Points_1,1)
  
    diff=Descriptors_2-Descriptors_1(i,:);
    distance=sum(abs(diff).^2,2);
    if(isempty(distance))
        continue
    end
    [dists,locs]=sort(distance);
    loc_1=locs(1);
    loc_2=locs(2);
    dist_1=dists(1);
    dist_2=dists(2);
    plot(Feature_Points_1(i,2),Feature_Points_1(i,1),'g+');
    hold on;
    plot(Feature_Points_2(loc_1,2)+w,Feature_Points_2(loc_1,1),'g+');
    hold on;
    if(dist_2/dist_1>1.4)
        flag_1(i)=loc_1;
        plot(Feature_Points_1(i,2),Feature_Points_1(i,1),'ro');
        hold on;
        plot(Feature_Points_2(loc_1,2)+w,Feature_Points_2(loc_1,1),'ro');
        hold on;
        plot([Feature_Points_1(i,2),Feature_Points_2(loc_1,2)+w],[Feature_Points_1(i,1),Feature_Points_2(loc_1,1)],'Color','r');
        hold on;
    end      
end


for i = 1:size(Feature_Points_2,1)

    diff=Descriptors_1-Descriptors_2(i,:);
    distance=sum(abs(diff).^2,2);
    if(isempty(distance))
        continue
    end
    [dists,locs]=sort(distance);
    loc_1=locs(1);
    loc_2=locs(2);
    dist_1=dists(1);
    dist_2=dists(2);
    plot(Feature_Points_2(i,2)+w,Feature_Points_2(i,1),'g+');
    hold on;
    plot(Feature_Points_1(loc_1,2),Feature_Points_1(loc_1,1),'g+');
    hold on;
    if(dist_2/dist_1>1.4)
        flag_2(i)=loc_1;
        plot(Feature_Points_2(i,2)+w,Feature_Points_2(i,1),'ro');
        hold on;
        plot(Feature_Points_1(loc_1,2),Feature_Points_1(loc_1,1),'ro');
        hold on;
        plot([Feature_Points_1(loc_1,2),Feature_Points_2(i,2)+w],[Feature_Points_1(loc_1,1),Feature_Points_2(i,1)],'Color','r');
        hold on;
    end      
end
disp('(5/5) Finish finding homonymy points')
