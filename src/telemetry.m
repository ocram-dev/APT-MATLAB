function [tele_a,tele_b]=telemetry(hrz_ln_mean_a,hrz_ln_mean_b,hrz_line_var_a,hrz_line_var_b)

[,sample_tele]=load_data();

acum=0;


for i=1:length(hrz_ln_mean_a)-length(sample_tele) %Cross-correlation telemerty sample with horizontal mean 
       for j=1:length(sample_tele) 
                acum = acum+ sample_tele(j) * (hrz_ln_mean_a(i + j));
                cum_sum(i)=acum;
             
       end 
end 

cum_sum_padded=[cum_sum zeros(1,(length(hrz_line_var_a)-length(cum_sum)))];


qa=cum_sum_padded./((hrz_line_var_a)');

[quality,quality_idx_a]=max(qa);

%quality_idx_a=quality_idx_a+32;

acum=0; %Pre-allocate


for i=1:length(hrz_ln_mean_b)-length(sample_tele) %Cross-correlation telemerty sample with horizontal mean 
       for j=1:length(sample_tele) 
                acum = acum + sample_tele(j) * (hrz_ln_mean_b(i + j));
                cum_sum_(i)=acum;
             
       end 
end 

cum_sum_padded_=[cum_sum_ zeros(1,(length(hrz_line_var_b)-length(cum_sum)))];

qb=cum_sum_padded_./((hrz_line_var_b)');

[quality,quality_idx_b]=max(qb);

lines_wedge=8;

for i=1:(length(sample_tele)/lines_wedge)
    
    tele_a(i)=mean(hrz_ln_mean_a((i-1)*lines_wedge+quality_idx_a+1:i*lines_wedge+quality_idx_a)); % Wedges mean (composed of 8 lines)

end


for i=1:length(sample_tele)/lines_wedge
    
    tele_b(i)=mean(hrz_ln_mean_b((i-1)*lines_wedge+quality_idx_b+1:i*lines_wedge+quality_idx_b)); % Wedges mean (composed of 8 lines)
end 


figure()

subplot(2,2,1)

plot(hrz_line_var_a)

subplot(2,2,2)

plot(qa)

subplot(2,2,3)

plot(hrz_ln_mean_a(quality_idx_a:quality_idx_a+200)*255);

title('A');

figure()

subplot(2,2,1)

plot(hrz_line_var_b)

subplot(2,2,2)

plot(qb)

subplot(2,2,3)

plot(hrz_ln_mean_b(quality_idx_b:quality_idx_b+200)*255);

title('B');

tele_a=tele_a(2:8)*255;

tele_b = tele_b(2:8).*255 ;
