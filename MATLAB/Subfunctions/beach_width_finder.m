% This script calculates the beach width from MHW to either the natural
% dune toe or fenced dune toe (if it exists). The local_x_toe or
% local_x_fence_toe should be equal to the beach width since 0m cross-shore
% is set to the MHW location
%
% Michael Itzkin, 5/3/2018
%------------------------------------------------------------------------%

if exist('local_x_fence_toe') && ~isnan(local_x_fence_toe)
    % If the fenced dune toe exists and is not a NaN than calculate the
    % beach width using the fence dune toe
    
    beach_width = local_x_fence_toe - local_x_mhw;
    
else
    % If there is no fenced dune toe or it is a NaN than just calculate the
    % beach width using the natural dune toe
    
    beach_width = local_x_toe - local_x_mhw;
    
end