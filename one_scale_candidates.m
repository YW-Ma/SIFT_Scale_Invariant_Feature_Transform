function [DOG,Gaussian,Candidates,octaves]=one_scale_candidates(img,sigma1,sigma2,r,octaves)
%Step 1: Generating Difference of Gaussian
    %  Octaves = 5;
    %  1 DoG per octave, generating from two blurred images.

    %1.1 Initialization
    %get the maximum octaves that can be implemented on the given image.
    [h,w]=size(img);
    flag=false;
    while flag==false
        if(1/((2)^octaves)*h>r*2+1||1/((2)^octaves)*w>r*2+1)
            flag=true;
        else
            octaves=octaves-1;
%             warndlg('Too many octaves. Automatically changed octaves.','Too many Octaves')
        end
    end
    DOG=cell(octaves,1);%Storing the whole DOG
    Gaussian=cell(octaves,1);%Storing pyramid images
    Candidates=cell(octaves,1);%Storing the index for candidates
    %1.2 Generating DOG
    sampled_image=img;
    for octave = 1:octaves
        %1.2.1 Generating Difference of Gaussian
        GFilter1 = fspecial('gaussian',[5 5],sigma1);
        GFilter2 = fspecial('gaussian',[5 5],sigma2);
        blur1=imfilter(sampled_image,GFilter1,'replicate'); %this scale of Gaussian
        blur2=imfilter(sampled_image,GFilter2,'replicate'); %last scale of Gaussian
        DOG{octave,1}=blur2-blur1;
        Gaussian{octave,1}=blur1;

        %1.2.2 Downsample the image by taking the average
        sampled_image = imresize(sampled_image,1/2,'bilinear');
    end

    %Step 2: Candidates Localization
    %  window size = 3 (mask size)
    %  radius[relating to window size] = 2
    %  threshold = 2, eliminating the 0 and 1

    %  meaning of varaibles
    % y_ind: y index , referring the location of extreme value.
    % x_ind: x index , referring the location of extreme value.
    % index: point index
    % maxmum: logical vector, maxmum pts are 1
    % mask: mark the neighbours of a pixel
    % y_mask, x_mask: the index of neighbours
    % Candidates{octave,1}: storing the combinationg of y,x index

    for octave=1:octaves
        pad=DOG{octave,1};
        [h,w]=size(pad);
        center_pad = pad(1+r:h-r, 1+r:w-r);

        [y_ind,x_ind]=find(center_pad>1);
        y_ind=y_ind+r;
        x_ind=x_ind+r;
        index = y_ind+(x_ind-1)*h; %points' index

        %neighbours mask
        mask=ones(2*r+1,2*r+1);
        mask(r+1,r+1)=0;
        [y,x]=find(mask);
        y=y-r-1; x=x-r-1;%centralize

        %test for max within neighbours
        maxmum=ones(length(index),1);
        % Finding out the extreme points:
        % since I utilized vectors, so these two lines are much more faster
        % than the ones use a big block of for-loop finding out the maxmum
        % points.
        % Copy Right: this idea was found in http://www.pudn.com. Genuis!!!
        for i=1:length(x)
            neighbour_index = index + y(i) + x(i)*h; %neighbours
            maxmum = maxmum & pad(index)>pad(neighbour_index);
        end
        y_ind = y_ind(maxmum);
        x_ind = x_ind(maxmum);
        index = y_ind+(x_ind-1)*h;
        Candidates{octave,1}=[y_ind,x_ind,index];
    end
    
    %Step 3: Refining Candidates
    %  DOG has strong response along edge

    % 1.1calculating Hessian Matrix of each layer
    lambda=10;
    for octave =1:octaves
        img=Gaussian{octave,1};
        %Hessian Matrix
        [dx,dy]=gradient(double(img));
        [dxx,dxy]=gradient(dx);
        [dyx,dyy]=gradient(dy);
        tr_H=dxx+dyy;
        det_H=dxx.*dyy-dxy.*dyx;
        response=tr_H.*tr_H./det_H;
        threshold=(lambda+1)^2/lambda;
        %the logical matrix for low response
        pad_response=response<threshold; %eliminating points if r > 10

        %the logical matrix for extreme points
        pad_extreme= false(size(pad_response));
        temp=Candidates{octave,1};
        index=temp(:,3);
        pad_extreme(index)=1;

        %the final logical matrix
        pad_extreme = pad_extreme & pad_response;
        index=find(pad_extreme);
        [h,~]=size(img);
        y_ind=mod(index,h);
        x_ind=floor(index/h)+1;
        Candidates{octave,1}=[y_ind,x_ind,index];
    end
end

function show_candidates(Gaussian,Candidates,octave)
    figure
    imagesc(Gaussian{octave,1})
    hold on
    plot(Candidates{octave,1}(:,2),Candidates{octave,1}(:,1),'r+')
end
    