function SetForcZero(grd,forcfile);
% added sss_time: 5/6/08
% Set the Forc to Zero
%  - E. Di Lorenzo (edl@ucsd.edu)
  

    in=netcdf(forcfile,'w');
    
    if length (in{'sms_time'}(:)) == 12  
       disp(' Looks like climatology time index array.');
       timeind=[15, 45, 75, 105, 135, 165, 195, 225, 255, 285, 315, 345 ]';
    else
       disp(' - Time index is > 12, please make sure to put in the times');
	 timeind=1:length (in{'sms_time'}(:));
    end
    
      timevar={'sms_time' 'shf_time' 'swf_time' 'sss_time' 'sst_time' 'srf_time' 'wind_time' 'pair_time' 'qair_time' 'tair_time' 'rain_time' 'cloud_time' 'lrf_time' 'lhf_time' 'shf_time' 'wave_time'};
    
  for i=1:length(timevar)
    in{timevar{i}}(:) = 0;
  end
     vars={'sustr' 'svstr' 'shflux' 'swflux' 'SST' 'SSS' 'dQdSST' 'swrad' 'Uwind' 'Vwind' 'Uwind_rel' 'Vwind_rel' 'Pair' 'Qair' 'Tair' 'rain' 'cloud' 'lwrad' 'latent' 'sensible','lwrad_down' 'Wave_dissip'};
  
   for i=1:length(vars)
      disp(vars{i});
      in{vars{i}}(:,:,:) = 0;
   end
   
   % For flux correction
   %in{'svstr'}(:,:,:) = 0.05;

  close(in);
 


    disp(' Make Forc DONE. ');
