% This script calculates the dune volume (m^3/m) of the natural dune or the
% natural behind sand fences.
%
% Michael Itzkin, 5/2/2018
%------------------------------------------------------------------------%

% Determine if the dune toe or dune heel is lower in elevation. A line must
% be fit across the bottom of the dune, the lower feature will determine
% where to put the line
if y_heel <= y_toe
    % The natural dune heel is less than the natural dune toe
    
    % Create a line across the whole profile at the heel elevation
    x = profiles(:,k,3);
    x(heel_index:toe_index) = y_heel;
    
elseif y_toe < y_heel    
    % The natural dune toe is less than the natural dune heel
    
    % Create a line across the whole profile at the toe elevation
    x = profiles(:,k,3)';
    x(heel_index:toe_index) = y_toe;
    
end  

% Calculate the area under the profile from the heel to toe
integral_profile = trapz(profiles(:,k,3));

% Calculate the area under the x vector created above from the heel to toe
integral_line = trapz(x);

% Subtract the area below the line from the area below the profile to get
% the natural dune volume
natural_dune_volume = integral_profile - integral_line;
