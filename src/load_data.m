

function [sample_tele] = load_data()

sample_tele = [
       

         0,255,224,191,159,127,95,63,31,...
         0, 0, 0, 0, 0, 0, 0, 0, 0,  ... % Variable
          0,255,224,191,159,127,95,63,31; % For contrast
          % 0,255,224,191,159,127,95,63,31 ...  % For contrast
             %% 31, 63, 95, 127, 159, 191, 224, 255, 0, ... % For contrast 
    ];

sample_tele = repmat(sample_tele,8,1);
 
sample_tele=sample_tele(:);

sample_tele(129:144)=[];

sample_tele=sample_tele';


end