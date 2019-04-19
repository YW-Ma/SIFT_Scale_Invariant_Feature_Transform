% parpool%Comment it if you don't need parallel computing.

%Read an Image
img=imread('Image/l.bmp');
img_size=size(img);
length=size(img_size);
if(length(2)>2)
    img=rgb2gray(img_color);
end

%Step 1: Generating Difference of Gaussian
%  Octaves = 4;  
%  5 scales per octave;  
%  initial sigma=1.6

%1.1 Initialization
octaves=4;
scales=5;
sigma=1.6;
sigma_array=zeros(scales,1);
DOG=cell(octaves,1);%Storing the whole DOG
Candidates=cell(octaves,1);%storing the candidates
for i = 1:scales
    sigma_array(i)=sigma*2^(i/2);
end

%1.2 DOG
sampled_image=img;
for octave = 1:octaves 
    %1.2.1 Generating Difference of Gaussian
    diff_pad=repmat(sampled_image,1,1,scales-1); %Storing DoG
    temp1=sampled_image; %last scale of Gaussian
    temp2=sampled_image; %last scale of Gaussian
    for scale = 1:scales-1
        temp1=temp2; %last scale of Gaussian
        GFilter = fspecial('gaussian',[5 5],sigma_array(scale));
        temp2=imfilter(sampled_image,GFilter,'replicate'); %this scale of Gaussian
        diff_pad(:,:,scale)=temp2-temp1;
    end
    %1.2.2 Downsample the image by taking the average
    sampled_image = imresize(sampled_image,1/2,'bilinear');
    DOG{octave,1}=diff_pad;
    candidates{octave,1}= false(size(diff_pad));%initialize the logical matrix simultaneously
end


for octave=1:octaves
    pad=DOG{octave,1};
    pad_size=size(pad);
    sub_candidates=candidates{octave,1};
%     for x=1:pad_size(1)-2
%         for y=1:pad_size(2)-2
%             for z=1:pad_size(3)-2
%                 block=abs(pad(x:x+2,y:y+2,z:z+2));
%                 extrame_value=max(max(max(block)));
%                 if(extrame_value~=0)
%                     sub_candidates(x:x+2,y:y+2,z:z+2)=(block==max(max(max(block))));
%                 end
%             end
%         end
%     end
    for x=1:pad_size(1)-2
        for y=1:pad_size(2)-2
            for z=1:pad_size(3)-2
                block=abs(pad(x:x+2,y:y+2,z));
                extrame_value=max(max(block));
                if(extrame_value~=0)
                    sub_candidates(x:x+2,y:y+2,z)=(block==max(max(block)));
                end
            end
        end
    end

end







