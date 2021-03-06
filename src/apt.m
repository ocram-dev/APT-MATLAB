%=========================================================================================
% Script to demodulate Automatic Picture Transmission (APT) satellite signals
% Input: .wav 
% Ouput: .png
% REFS:
% https://noaa-apt.mbernardi.com.ar/
% https://github.com/martinber/noaa-apt
%===========================================================================================

tic


[y,fs_ini] = audioread('20200521101741_mono_11k.wav'); % test_11025hz    20200521101741_mono_11k 

npre=1000; % Pre-allocate

dim=size(y);

if dim(2) ~= 1
    
    y(:,2)=[];% Discard second channel if audio signal is stereo  
    
end

fs_apt=4160; % APT sample rate 

sync_t= 6.3e-3; %Sync Period - s

sync_f=1040; %Sync Frequency - Hz

%y_theta=angle(hilbert(y)); % Phase of analytic signal

y_env=((abs(hilbert(y)))); % Obtain analytic signal and envelope

y_env2=y_env;

[p,q] = rat(fs_apt / fs_ini); %Rational resamplelar

y_env= resample(y_env,p,q); % Resample to APT sample rate 

t=0:1/fs_apt:sync_t;

phi=sync_f*t*(2*pi);

sync=square(phi); % Sync signal

cor_=zeros(npre,1);

 for idx=1:length(y_env)-length(sync) 
     
    cor_(idx)=dot(sync,y_env(idx:idx+length(sync)-1)); %Correlate input signal with sync pulses
 
 end
 
rows = floor(length(cor_)*2/fs_apt)-2; % A+B Sync signals

apt_width = fs_apt/2; % Columns = 2080 

list=zeros(npre,npre); %Pre-allocate

img=zeros(npre,apt_width); 

for n = 1:rows
    
    [m,idx]=max(cor_((n-1)*apt_width+1:n*apt_width)); % Max of correlations 

    img(n,:) = y_env(idx+apt_width*n:idx+apt_width*n+apt_width-1); %Shift to first correlation peak and cut vector in rows 
  
end

n_sync=39; % nº of pixels in sync frame

n_space=47;% nº of pixels in space frame

img_width=909; % Channel image size in pixels 

n_tele=44; % Pixels in telemetry 

offset=4;

channel='B'; 

switch channel
    
    case 'A'
        
         img_a_channel=img(:,n_space+n_sync-offset+1:n_space+n_sync+img_width-offset); % Isolated A channel image
         imwrite(img_a_channel,'img_a_channel.png');
     
    case 'B'
        
         img_b_channel=img(:,end-img_width-n_tele-offset:end-n_tele-1-offset); % Isolated B channel image
         imwrite(img_b_channel,'img_b_channel.png');
         
    case 'C'
        
         imwrite(img,'img_ab_ch.png');
         
    otherwise
       
end

raw_tele_a=img(:,n_space+n_sync+img_width-offset+1:n_space+n_sync+img_width+n_tele-offset); % -2 ,-3
%imwrite(raw_tele_a,'raw_tele_a.png');   
raw_tele_a=raw_tele_a';
raw_tele_a=raw_tele_a(:);

raw_tele_b=img(:,end-n_tele-offset+1:end-offset);  %-4,-5
%imwrite(raw_tele_b,'raw_tele_b.png');  
raw_tele_b=raw_tele_b';
raw_tele_b=raw_tele_b(:);


hrz_ln_mean_a=zeros(npre,1); %Pre-allocate
hrz_line_var_a=zeros(npre,1); 
hrz_ln_mean_b=zeros(npre,1); 
hrz_line_var_b=zeros(npre,1); 


for i=1:floor(length(raw_tele_a)/n_tele)
    
   hrz_ln_mean_a(i)=mean(raw_tele_a((i-1)*n_tele+1:i*n_tele));  % Horizontal mean 
 

end 


for i=1:floor(length(raw_tele_a)/n_tele)
    
  hrz_line_var_a(i)=var(raw_tele_a((i-1)*n_tele+1:i*n_tele));  % Horizontal var 
  
end

for i=1:floor(length(raw_tele_a)/n_tele)
    
   hrz_ln_mean_b(i)=mean(raw_tele_b((i-1)*n_tele+1:i*n_tele)); 
   hrz_line_var_b(i)=var(raw_tele_b((i-1)*n_tele+1:i*n_tele));  
   
end 

[tele_a,tele_b]=telemetry(hrz_ln_mean_a,hrz_ln_mean_b,hrz_line_var_a,hrz_line_var_b);

toc
