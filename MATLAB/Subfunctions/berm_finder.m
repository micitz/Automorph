% This script locates the possible position of a berm on the profile
%
% Michael Itzkin, 6/1/2018
%------------------------------------------------------------------------%

% Make a line from the toe to mhw then fit it into a copy of the profile
berm_line = linspace(profiles(toe_index,k,3), profiles(mhw_index,k,3),...
    length(profiles(toe_index:mhw_index,k,3)));
berm_profile = profiles(:,k,3);
berm_profile(toe_index:mhw_index) = berm_line;
berm_profile = profiles(:,k,3) - berm_profile;

% Find peaks in the berm_profile
[berm_pks, berm_locs] = findpeaks(berm_profile);

% Find the berm peak nearsest to MHW
if ~isempty(berm_pks)
    [~, ix] = nanmin(abs(berm_locs-mhw_index));
    berm_index = berm_locs(ix);
    
    % Set the fenced dune heel
    [x_berm, y_berm, local_x_berm,...
        local_y_berm, berm_lon, berm_lat] =...
        set_locations(x_values, local_x_values, profiles,...
        berm_index, k, sp_loc);
else
    % Set all the locations to NaN
    x_berm = NaN;
    y_berm = NaN;
    local_x_berm = NaN;
    local_y_berm = NaN;
    berm_lon = NaN;
    berm_lat = NaN; 
end
