% This script locates the position of the fenced dune crest. It first
% checks that there is a fence on the profile before continuing. It then
% assigns the general, local, and lat/lon position of the fenced dune crest
%
% Michael Itzkin, 3/28/2018
%-------------------------------------------------------------------------%
clear y_fence_crest

if ~isempty(fence_check) && (abs(crest_index+1 - fence_index)>=3)
    % Locate the fenced dune crest
    [fence_pks, fence_locs] = findpeaks(profiles(crest_index+1:fence_index,k,3));
    
    % If there are no peaks between the crest and the fence
    % then assign NaNs
    if isempty(fence_pks)
        x_fence_crest = NaN;
        y_fence_crest = NaN;
        local_x_fence_crest = NaN;
        local_y_fence_crest = NaN;
        fence_crest_lon = NaN;
        fence_crest_lat = NaN; 
    else
        
        % Pick the most seaward peak for the fenced dune crest index
        fence_crest_max_loc = find(fence_locs == nanmax(fence_locs));
        fence_crest_loc = find(fence_pks == fence_pks(fence_crest_max_loc));
        fence_crest_index = find(profiles(:,k,3) == fence_pks(fence_crest_loc));
        
        fence_crest_index = nanmin(fence_crest_index);
        
        % Set the appropriate locations
        [x_fence_crest, y_fence_crest, local_x_fence_crest,...
            local_y_fence_crest, fence_crest_lon, fence_crest_lat] =...
            set_locations(x_values, local_x_values, profiles,...
            fence_crest_index, k, sp_loc);
        
    end
       
else
    % If no fence then assign NaN values
    x_fence_crest = NaN;
    y_fence_crest = NaN;
    local_x_fence_crest = NaN;
    local_y_fence_crest = NaN;
    fence_crest_lon = NaN;
    fence_crest_lat = NaN;      
end
