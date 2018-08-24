% This script stores the elevation of the crest location in 2010 (or
% whatever the first year of analysis is) and the index of that location.
% When another, later, year runs it determines the height of that same
% location. Do the same for the fenced dune crest if it exists
%
% Michael Itzkin, 5/3/2018
%-----------------------------------------------------------------------%

% Set these to match the columns of the natural and fenced dune crest
% starting indices in the morpho_table. DO NOT CHANGE if the morpho_table
% columns have not changed
start_crest_col = 55; %% Can change this
start_fence_crest_col = 57; %% Can change this

if strcmp(year, start_year)
    % If the current year being looked at is the starting year, store the
    % current crest height and index
    
    % Store the natural dune height
    start_crest_height = y_crest;
    start_crest_index = crest_index;
    
    % Store the fenced dune height
    if fenced
        if exist('fence_crest_index') && ~isnan(fence_crest_index)
            start_fence_crest_height = y_fence_crest;
            start_fence_crest_index = fence_crest_index;
        else
            start_fence_crest_height = NaN;
            start_fence_crest_index = NaN;
        end
    else
        start_fence_crest_height = NaN;
        start_fence_crest_index = NaN;
    end
    
else
    % Load the index from the original year and store the elevation at that
    % index for the year being looked at
   
    % Find the elevation of the profile where the natural dune crest was in
    % the starting year
    start_crest_index = original_data(k,start_crest_col);
    start_crest_height = profiles(start_crest_index,k,3);
    
    % Find the elevation of the profile where the fenced dune crest was in
    % the starting year
    if exist('fence_crest_index') && ~isnan(fence_crest_index)
        start_fence_crest_index = original_data(k,start_fence_crest_col);
        if ~isnan(start_fence_crest_index)
            start_fence_crest_height = profiles(start_fence_crest_index,k,3);
        end
    else
        start_fence_crest_index = NaN;
        start_fence_crest_height = NaN;
    end
    
end