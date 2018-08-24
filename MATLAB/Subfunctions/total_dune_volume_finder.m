% This script calculates the total dune volume including the fenced dune
% and the natural dune behind the fenced dune
%
% Michael Itzkin, 5/2/2018
%------------------------------------------------------------------------%

if exist('y_fence_toe') && ~isnan(y_fence_toe)
    
    % Determine if the fenced dune toe or dune heel is lower in elevation.
    % A line must be fit across the bottom of the dune, the lower
    % feature will determine where to put the line
    if y_heel <= y_fence_toe
        % The natural dune heel is less than the natural dune toe

        % Create a line across the whole profile at the heel elevation
        x = profiles(:,k,3);
        x(heel_index:fence_toe_index) = y_heel;

    elseif y_fence_toe < y_heel    
        % The natural dune toe is less than the natural dune heel

        % Create a line across the whole profile at the toe elevation
        x = profiles(:,k,3);
        x(heel_index:fence_toe_index) = y_fence_toe;

    end  

    % Calculate the area under the profile from the heel to toe
    integral_profile = trapz(profiles(:,k,3));

    % Calculate the area under the x vector created above from the heel to toe
    integral_line = trapz(x);

    % Subtract the area below the line from the area below the profile to get
    % the natural dune volume
    total_dune_volume = integral_profile - integral_line;

end