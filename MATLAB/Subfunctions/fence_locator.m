% This script locates the point on the profile where the fence is located.
% It first checks that there is a fence on the profile and then proceeds to
% locate it. The general, local, and lat/lon position of the fence are
% stored.
%
% Michael Itzkin, 3/28/2018
%-------------------------------------------------------------------------%

% The first column of the fence_crossings matrix is the profile number of
% each fence. Check that the current profile (k) being looked at matches a
% number in the first column of fence_crossings.
fence_check = find(fence_crossings(:,1) == k);

% If there is a fence on this profile than find it, otherwise set the
% general, local, and lat/lon locations to be NaN
if ~isempty(fence_check)
    
    % The value in the third column of fence_crossings should be the
    % correct index of the fence location
    fence_index = fence_crossings(fence_check,3);
    
    fence_index = nanmax(fence_index);
    
    % Set the appropriate locations
    [x_fence, y_fence, local_x_fence, local_y_fence, fence_lon, fence_lat] =...
        set_locations(x_values, local_x_values, profiles, fence_index, k, sp_loc);
    
else
    x_fence = NaN;
    y_fence = NaN;
    local_x_fence = NaN;
    local_y_fence = NaN;
    fence_lon = NaN;
    fence_lat = NaN;  
end
