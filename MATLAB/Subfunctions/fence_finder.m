% This script loads all the fence crossing locations and matches them with
% the correct profiles in the study area
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%

% Check if the fences have been found for this area before. If so just load
% the .mat file and skip the rest
check_fence_crossings_fname = sprintf('%s%s%s%sFence Crossings for %s %s.mat',...
    location(1:end-1), filesep, year, filesep, location(1:end-1), year);
if exist(check_fence_crossings_fname)
    
    load(check_fence_crossings_fname)
    
else

    fence_crossings = [];

    % Load the spreadsheet with the fence crossings
    fences_spreadsheet = sprintf('Excel Files%s%s Fences.xlsx',...
        filesep, location(1:end-1));
    fences = xlsread(fences_spreadsheet);

    % Create a table of just the profiles with the crossings
    a = fences(:,1);
    b = profiles(:,:,2);
    profiles_with_crossings = [];
    for i = 1:length(a)
        profiles_with_crossings = [profiles_with_crossings b(:,a(i))];
    end

    % The amount of columns in this new table should be equal to the amount of
    % rows in the fences table
    for i = 1:length(fences(:,1))
        % Use i for the column in the profiles table
        for j = 1:length(profiles_with_crossings(:,1))-1
            % Use j for the row in the profiles table
            if ((profiles_with_crossings(j,i) < fences(i,3)) && (profiles_with_crossings(j+1,i) > fences(i,3))) ||...
                    ((profiles_with_crossings(j,i) > fences(i,3)) && (profiles_with_crossings(j+1,i) < fences(i,3))) ||...
                    ((profiles_with_crossings(j,i) == fences(i,3)))
                cross_profile = fences(i,1);
                cross_location = profiles_with_crossings(j,i);
                x_values_cross_index = j;
                crossings = [cross_profile, cross_location, x_values_cross_index];
                fence_crossings = [fence_crossings; crossings];
            end
        end
    end

    % Save the fence crossings matrix as a .mat file to load faster next time
    fence_crossings_fname = sprintf('%s%s%s%sFence Crossings for %s %s.mat',...
        location(1:end-1), filesep, year, filesep, location(1:end-1), year);
    save(fence_crossings_fname, 'fence_crossings', '-mat')
    
end

clear check_fence_crossings_fname