% This script locates the natural dune toe on the profile and stores the
% general, local, and lat/lon location of the toe. It uses a stretched
% sheet method similar to Mitasova et al (2011)
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%

% Make a copy of the current profile, and then replace the part between toe
% and the crest with a straight line
profile_copy = profiles(:,k,3);
linear_component = linspace(y_crest, y_mhw,...
    length(crest_index:mhw_index));
profile_copy(crest_index:mhw_index) = linear_component;

% Subtract the profile_copy from the profile and take the absolute values.
% Then identify where the greatest value is and set it as the toe index
%dists = abs(profiles(:,k,3) - profile_copy);
dists = profile_copy - profiles(:,k,3);
toe_index = find(dists == nanmax(dists));

% Make sure the toe is not on a high point
while(toe_index-1 > 1)
   if profiles(toe_index-1,k,3) < profiles(toe_index,k,3)
       toe_index = toe_index-1;
   else
       break
   end 
end

toe_index = nanmin(toe_index);

% If there are any peaks between the crest and the toe, make sure that 
% the toe is moved accordingly
if any(locs>crest_index) && any(locs<toe_index)
    possible = nanmin(intersect(find(locs<toe_index), find(locs>crest_index)));
    if ~isempty(possible)
        toe_index = find(profiles(:,k,3) == nanmin(profiles(crest_index:locs(possible),k,3)));
    end
end

toe_index = nanmin(toe_index);


% Set the appropriate locations
[x_toe, y_toe, local_x_toe, local_y_toe, toe_lon, toe_lat] =...
    set_locations(x_values, local_x_values, profiles, toe_index, k, sp_loc);
