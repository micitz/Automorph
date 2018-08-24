function [lon, lat] = lon_lat_finder(sp_loc, profiles, index, k)
    % Modified version of the sp_proj function call to save some space in
    % the Automorph scripts. The unit is set to feet ('sf') since the x and
    % y coordinates were never converted to meters when Excelload ran

    [lon, lat] = sp_proj(sp_loc,...
        'inverse', profiles(index,k,1), profiles(index,k,2),'sf');
    
end