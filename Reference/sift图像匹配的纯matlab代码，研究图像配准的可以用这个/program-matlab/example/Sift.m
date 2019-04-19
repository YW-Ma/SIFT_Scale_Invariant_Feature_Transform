function [N]=Sift(N,files,total,fileDir,Index)

for temp1=1:(total+1)
    N{temp1}=zeros(1,700);
end

%对于选中图片：
[features,~,~,~] = detect_features(imread([fileDir,files(Index).name]));
row=size(features,1);    %统计选中图片的行列数
col=size(features,2);
for i=1:row            
    for j=1:col
        k=round(features(i,j));
        N{total+1}(k+5)=N{total+1}(k+5)+1;
    end
end

%对于其他图片,分别计算其特征数组：
for ii=1:total
   [features,~,~,~] = detect_features(imread([fileDir,files(ii).name]));
   row=size(features,1);   
   col=size(features,2);

    for i=1:row
        for j=1:col
            k=round(abs(features(i,j)));%k代表的是此格子的灰度级
            N{ii}(k+5)=N{ii}(k+5)+1;
        end
    end
end

end