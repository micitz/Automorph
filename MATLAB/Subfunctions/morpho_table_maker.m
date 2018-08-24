% This script puts all of the morphometrics data for the current profile
% into a larger matrix with all of the information for the entire study
% area/year
%
% The general format will be the profile number followed by the general
% locations, the local locations, the lat/lon locations, other metrics
% [1; prof no., 2-17; gen., 18- loc., 16 lat/lon, misc...]
%
% Michael Itzkin, 4/4/2018
%------------------------------------------------------------------------%

% Preallocate an empty vector to store data in
% Put the profile number in the first column
morpho_table(k,1) = k;

% Store the MHW values
morpho_table(k,2) = x_mhw;
morpho_table(k,3) = y_mhw;
morpho_table(k,18) = local_x_mhw;
morpho_table(k,19) = local_y_mhw;
morpho_table(k,34) = mhw_lon;
morpho_table(k,35) = mhw_lat;

% Store the fenced dune toe values
if exist('x_fenced_toe')
    morpho_table(k,4) = x_fence_toe;
    morpho_table(k,5) = y_fence_toe;
    morpho_table(k,20) = local_x_fence_toe;
    morpho_table(k,21) = local_y_fence_toe;
    morpho_table(k,36) = fence_toe_lon;
    morpho_table(k,37) = fence_toe_lat;
end

% Store the fence values
if exist('x_fence')
    morpho_table(k,6) = x_fence;
    morpho_table(k,7) = y_fence;
    morpho_table(k,22) = local_x_fence;
    morpho_table(k,23) = local_y_fence;
    morpho_table(k,38) = fence_lon;
    morpho_table(k,39) = fence_lat;
end

% Store the fenced dune crest values
if exist('x_fence_crest') && exist('y_fence_crest')
    morpho_table(k,8) = x_fence_crest;
    morpho_table(k,9) = y_fence_crest;
    morpho_table(k,24) = local_x_fence_crest;
    morpho_table(k,25) = local_y_fence_crest;
    morpho_table(k,40) = fence_crest_lon;
    morpho_table(k,41) = fence_crest_lat;
end

% Store the fenced dune heel values
if exist('x_fence_heel')
    morpho_table(k,10) = x_fence_heel;
    morpho_table(k,11) = y_fence_heel;
    morpho_table(k,26) = local_x_fence_heel;
    morpho_table(k,27) = local_y_fence_heel;
    morpho_table(k,42) = fence_heel_lon;
    morpho_table(k,43) = fence_heel_lat;
end

% Store the toe values
morpho_table(k,12) = x_toe;
morpho_table(k,13) = y_toe;
morpho_table(k,28) = local_x_toe;
morpho_table(k,29) = local_y_toe;
morpho_table(k,44) = toe_lon;
morpho_table(k,45) = toe_lat;

% Store the crest values
morpho_table(k,14) = x_crest;
morpho_table(k,15) = y_crest;
morpho_table(k,30) = local_x_crest;
morpho_table(k,31) = local_y_crest;
morpho_table(k,46) = crest_lon;
morpho_table(k,47) = crest_lat;

% Store the heel values
morpho_table(k,16) = x_heel;
morpho_table(k,17) = y_heel;
morpho_table(k,32) = local_x_heel;
morpho_table(k,33) = local_y_heel;
morpho_table(k,48) = heel_lon;
morpho_table(k,49) = heel_lat;

% Store the natural dune volume
morpho_table(k,50) = natural_dune_volume;

% Store the fenced dune volume
if exist('fenced_dune_volume')
    morpho_table(k,51) = fenced_dune_volume;
elseif ~exist('fenced_dune_volume')
    morpho_table(k,51) = NaN;
end

% Store the total dune volume
if exist('total_dune_volume')
    morpho_table(k,52) = total_dune_volume;
elseif ~exist('total_dune_volume')
    morpho_table(k,52) = NaN;
end

% Store the beach width
morpho_table(k,53) = beach_width;

% Store the starting natural dune crest height and index
morpho_table(k,54) = start_crest_height;
morpho_table(k,55) = start_crest_index;

% Store the starting fenced dune crest height and index
if exist('start_fence_crest_height')
    morpho_table(k,56) = start_fence_crest_height;
    morpho_table(k,57) = start_fence_crest_index;
end

% Store the beach and foreshore slope
morpho_table(k,58) = beach_slope;
morpho_table(k,59) = foreshore_slope;

% Store the berm values
morpho_table(k,60) = x_berm;
morpho_table(k,61) = y_berm;
morpho_table(k,62) = local_x_berm;
morpho_table(k,63) = local_y_berm;
morpho_table(k,64) = berm_lon;
morpho_table(k,65) = berm_lat;
