

function [Descriptors,Feature_Points] = multi_scale_features(img)
    % Notice: Data Structure:
    %   1.Different Scale [Gaussians,Candidates]
    %   {
    %       2.Each Scale in different octave [gaussian,candidate]
    %   }
    % Reason: to speed up the algorithm    
    sigma1=1.6;
    sigma2=2.26;
    r=5;
    octaves=4;
    scales=6;
    Gaussians=cell(scales,1);
    Candidates=cell(scales,1);
    DOGs=cell(scales,1);
    %Features will store the location of final feature points.
    Features=cell(octaves,1);
    
    %Step 1. Generating Candidates
    for scale = 1:scales
        sigma1=sigma1*1.414;
        sigma2=sigma2*1.414;

        [DOG,gaussian,candidate,octaves]=one_scale_candidates(img,sigma1,sigma2,r,octaves);
        Gaussians{scale,1}=gaussian;
        Candidates{scale,1}=candidate;
        DOGs{scale,1}=DOG;
    end
    
    %Step 2. Testing Candidates across different scales
    for octave = 1:octaves
        features=cell(scales,1);
        for scale = 1:scales-2          
            dog_1=DOGs{scale,1}{octave,1};
            dog_2=DOGs{scale+1,1}{octave,1};
            dog_3=DOGs{scale+2,1}{octave,1};
            if(scale==1)                  %Test candidate -- first scale
                features{1,1}=Candidates{1,1}{octave,1};
            elseif(scale==scales-2)       %Test candidate -- last scale
                features{scales,1}=Candidates{scales,1}{octave,1};
            else                          %Test candidate -- middle scale
                cand_2=Candidates{scale,1}{octave,1};
                flag=false(size(cand_2,1),1);
                for i = 1:size(cand_2,1)
                    yp=cand_2(i,1);
                    xp=cand_2(i,2);
                    cand_value=dog_2(yp,xp);
                    neighbor_values=[dog_1(yp-r:yp+r,xp-r:xp+r);dog_2(yp-r:yp+r,xp-r:xp+r);dog_3(yp-r:yp+r,xp-r:xp+r)];
                    neighbor=neighbor_values(:);
                    if(max(neighbor)==cand_value)
                        % delete the false candidate
                        flag(i,:)=1;
                    end
                end 
                cand_2=cand_2(flag,:);
                features{scale+1,1}=cand_2;
            end
        end
        Features{octave,1}=features;
    end

    Features=Candidates;
    %Step 4: Generating descriptors:
    features_num=0;
    for scale = 1:scales
        for octave = 1:octaves
            features=Features{octave,1};
            features_num=features_num+length(features);
        end
    end
    Descriptors = zeros(features_num,128);
    Feature_Points = zeros(features_num,3);%storing the final feature points.(x,y,layer)
    
    cnt=0;
    dir_num=36;
    dir_step=2*pi/dir_num;
    direction=-pi+dir_step:dir_step:pi;
    direction_descriptor=-pi+(2*pi/8):(2*pi/8):pi;
    GFilter1 = fspecial('gaussian',[2*r+1 2*r+1],sigma1);%weights
    for scale = 1:scales
        for octave = 1:octaves
            img=Gaussians{scale,1}{octave,1};%
            features=Features{scale,1}{octave,1};
            [dx,dy]=gradient(double(img));

            for i = 1:size(features,1)

                %4.1 find out the direction(theta) and magnitude of gradients

                y=features(i,1);
                x=features(i,2);
                pad_y=GFilter1.*dy(y-r:y+r,x-r:x+r);
                pad_x=GFilter1.*dx(y-r:y+r,x-r:x+r);%weighted gradients
                pad_y=pad_y(:);
                pad_x=pad_x(:);%convert to 1 dim
                %magnitude
                m=sqrt((pad_x.^2+pad_y.^2));
                %theta
                theta=atan(pad_x./pad_y);
                hist_theta=hist(theta,direction);
                %find the peaks
                peaks_sift=find(max(hist_theta)==hist_theta);
                if(length(peaks_sift)>2)%vulnerable points
                    continue
                end
                cnt=cnt+1;
                [~,peak_pos]=sort(hist_theta);
                len=length(peak_pos);
                %find two peaks for each points.
                peak_1=peak_pos(len);
                peak_2=peak_pos(len-1);

                %4.2 generating descriptors

                %first peak
                r=int16(r);
                descriptor_1=zeros(128,1);
                theta_1=mod(theta-direction(peak_1)+pi,2*pi) - pi;
                theta_1=reshape(theta_1,2*r+1,2*r+1);
                seed_1 = theta_1(1          :	r/2     ,	1	:	r/2);
                seed_2 = theta_1(r/2+1      :	r+1     ,	1	:	r/2);
                seed_3 = theta_1(r+1        :	r+r/2+1 ,	1	:	r/2);
                seed_4 = theta_1(r+r/2+2	:	2*r+1	,	1	:	r/2);

                seed_5 = theta_1(1          :	r/2     ,	r/2+1	:	r+1);
                seed_6 = theta_1(r/2+1      :	r+1     ,	r/2+1	:	r+1);
                seed_7 = theta_1(r+1        :	r+r/2+1 ,	r/2+1	:	r+1);
                seed_8 = theta_1(r+r/2+2	:	2*r+1	,	r/2+1	:	r+1);

                seed_9 = theta_1(1         :	r/2     ,	r+1      :	r+r/2+1);
                seed_10 =theta_1(r/2+1      :	r+1     ,	r+1      :	r+r/2+1);
                seed_11 =theta_1(r+1        :	r+r/2+1 ,	r+1      :	r+r/2+1);
                seed_12 =theta_1(r+r/2+2	:	2*r+1	,	r+1      :	r+r/2+1);

                seed_13 =theta_1(1         :	r/2     ,	r+r/2+2	:	2*r+1);
                seed_14 =theta_1(r/2+1      :	r+1     ,	r+r/2+2	:	2*r+1);
                seed_15 =theta_1(r+1        :	r+r/2+1 ,	r+r/2+2	:	2*r+1);
                seed_16 =theta_1(r+r/2+2	:	2*r+1	,	r+r/2+2	:	2*r+1);

                descriptor_1(1:8)=hist(seed_1(:),direction_descriptor);
                descriptor_1(9:16)=hist(seed_2(:),direction_descriptor);
                descriptor_1(17:24)=hist(seed_3(:),direction_descriptor);
                descriptor_1(25:32)=hist(seed_4(:),direction_descriptor);

                descriptor_1(33:40)=hist(seed_5(:),direction_descriptor);
                descriptor_1(41:48)=hist(seed_6(:),direction_descriptor);
                descriptor_1(49:56)=hist(seed_7(:),direction_descriptor);
                descriptor_1(57:64)=hist(seed_8(:),direction_descriptor);

                descriptor_1(65:72)=hist(seed_9(:),direction_descriptor);
                descriptor_1(73:80)=hist(seed_10(:),direction_descriptor);
                descriptor_1(81:88)=hist(seed_11(:),direction_descriptor);
                descriptor_1(89:96)=hist(seed_12(:),direction_descriptor);

                descriptor_1(97:104)=hist(seed_13(:),direction_descriptor);
                descriptor_1(105:112)=hist(seed_14(:),direction_descriptor);
                descriptor_1(113:120)=hist(seed_15(:),direction_descriptor);
                descriptor_1(121:128)=hist(seed_16(:),direction_descriptor);
                Descriptors(cnt,:)=descriptor_1;
                scale=2^(octave-1);
                Feature_Points(cnt,:)=[y*scale,x*scale,octave];

                cnt=cnt+1;
                % second peak
                descriptor_2=zeros(128,1);
                theta_2=mod(theta-direction(peak_2)+pi,2*pi) - pi;
                theta_2=reshape(theta_2,2*r+1,2*r+1);
                seed_1 = theta_2(1          :	r/2     ,	1	:	r/2);
                seed_2 = theta_2(r/2+1      :	r+1     ,	1	:	r/2);
                seed_3 = theta_2(r+1        :	r+r/2+1 ,	1	:	r/2);
                seed_4 = theta_2(r+r/2+2	:	2*r+1	,	1	:	r/2);

                seed_5 = theta_2(1          :	r/2     ,	r/2+1	:	r+1);
                seed_6 = theta_2(r/2+1      :	r+1     ,	r/2+1	:	r+1);
                seed_7 = theta_2(r+1        :	r+r/2+1 ,	r/2+1	:	r+1);
                seed_8 = theta_2(r+r/2+2	:	2*r+1	,	r/2+1	:	r+1);

                seed_9 = theta_2(1         :	r/2     ,	r+1      :	r+r/2+1);
                seed_10 =theta_2(r/2+1      :	r+1     ,	r+1      :	r+r/2+1);
                seed_11 =theta_2(r+1        :	r+r/2+1 ,	r+1      :	r+r/2+1);
                seed_12 =theta_2(r+r/2+2	:	2*r+1	,	r+1      :	r+r/2+1);

                seed_13 =theta_2(1         :	r/2     ,	r+r/2+2	:	2*r+1);
                seed_14 =theta_2(r/2+1      :	r+1     ,	r+r/2+2	:	2*r+1);
                seed_15 =theta_2(r+1        :	r+r/2+1 ,	r+r/2+2	:	2*r+1);
                seed_16 =theta_2(r+r/2+2	:	2*r+1	,	r+r/2+2	:	2*r+1);

                descriptor_2(1:8)=hist(seed_1(:),direction_descriptor);
                descriptor_2(9:16)=hist(seed_2(:),direction_descriptor);
                descriptor_2(17:24)=hist(seed_3(:),direction_descriptor);
                descriptor_2(25:32)=hist(seed_4(:),direction_descriptor);

                descriptor_2(33:40)=hist(seed_5(:),direction_descriptor);
                descriptor_2(41:48)=hist(seed_6(:),direction_descriptor);
                descriptor_2(49:56)=hist(seed_7(:),direction_descriptor);
                descriptor_2(57:64)=hist(seed_8(:),direction_descriptor);

                descriptor_2(65:72)=hist(seed_9(:),direction_descriptor);
                descriptor_2(73:80)=hist(seed_10(:),direction_descriptor);
                descriptor_2(81:88)=hist(seed_11(:),direction_descriptor);
                descriptor_2(89:96)=hist(seed_12(:),direction_descriptor);

                descriptor_2(97:104)=hist(seed_13(:),direction_descriptor);
                descriptor_2(105:112)=hist(seed_14(:),direction_descriptor);
                descriptor_2(113:120)=hist(seed_15(:),direction_descriptor);
                descriptor_2(121:128)=hist(seed_16(:),direction_descriptor);
                Descriptors(cnt,:)=descriptor_2;
                scale=(2)^(octave-1);
                Feature_Points(cnt,:)=[y*scale,x*scale,octave];
            end
        end
    end
end