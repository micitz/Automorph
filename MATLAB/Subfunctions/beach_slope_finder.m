% This script calculates both the beach and foreshore slope. The foreshore
% slope is the slope from MHW to natural dune toe or, if present, the
% fenced dune toe. The beach slope takes points around MHW, regresses
% through them and determines the slope of the regression
%
% Michael Itzkin, 5/3/2018
%------------------------------------------------------------------------%

% Calculate the foreshore slope first
if exist('x_fence_toe') && ~isnan(x_fence_toe)
    % Use the fenced dune toe to calculate the foreshore slope    
    foreshore_slope = (y_fence_toe - y_mhw)/(x_fence_toe - x_mhw);
    
else
    % Use the natural dune toe to calculate the foreshore slope    
    foreshore_slope = (y_toe - y_mhw)/(x_toe - x_mhw);
    
end

% Determine the lowest point to use for the beach slope
beach_slope_range = 0.5; %% Can change this!!
low_elevation = y_mhw - beach_slope_range;
high_elevation = y_mhw + beach_slope_range;

% Find the index for the low_elevation. If the profile does not go low
% enough than just use the most seaward point
if nanmin(profiles(:,k,3)) < low_elevation
    low_dists = abs(profiles(:,k,3) - low_elevation);
    low_elevation_index = find(low_dists(mhw_index:length(x_values)) == nanmin(low_dists(mhw_index:length(x_values))));
    low_elevation_index = mhw_index + low_elevation_index;
    
    if low_elevation_index > length(x_values)
        low_elevation_index = length(x_values);
    end
else
    low_elevation_index = length(x_values);
end

% Find the index for the high_elevation
high_dists = abs(profiles(:,k,3) - high_elevation);
high_elevation_index = find(high_dists == nanmin(high_dists));

% Regress through the elevation range
regress_range = [high_elevation_index:low_elevation_index];
if ~isempty(regress_range)
    beach_slope_regression = fitlm(x_values(regress_range),...
        profiles(regress_range,k,3));

    % Extract the slope from the regression model as the beach slope
    beach_slope = beach_slope_regression.Coefficients{2,1};
else
    beach_slope = NaN;
end
