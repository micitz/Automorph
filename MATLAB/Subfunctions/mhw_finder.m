% This script finds the location on the profile near the MHW line and
% stores it. Both the relative location is found and the lat/lon location
% is stored. Then create a local_x_value vector where 0 is centered on MHW
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%

% Find the closest point on the profile to MHW
mhw_index = nanmin(find_closest(profiles(:,k,3), MHW));
local_x_values(:,k) = x_values-x_values(mhw_index);

mhw_index = nanmin(mhw_index);

% Set all the appropriate locations
[x_mhw, y_mhw, local_x_mhw, local_y_mhw, mhw_lon, mhw_lat] =...
    set_locations(x_values, local_x_values, profiles, mhw_index, k, sp_loc);