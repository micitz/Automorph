% This script moves all misplaced fence crossing files to where they should
% be
%
% Michael Itzkin, 6/1/2018
%-------------------------------------------------------------------------%

% All the Bogue files are alphabetical, store the alphabet
alphabet = 'A':'Z';

% Set a cell of years to loop through
years = {'2010', '2011', '2014', '2016'};

% Loop through the files
for letter = 1:length(alphabet)    
    for year = 1:length(years)
    
        % Check for a misplaced fence_crossings file
        fence_fname_wrong = sprintf('Bogue %s%sFence Crossings for Bogue %s %s.mat',...
            alphabet(letter), filesep, alphabet(letter), years{year});
        if exist(fence_fname_wrong)
            destination = sprintf('Bogue %s%s%s%s', alphabet(letter),...
                filesep, years{year}, filesep);
            movefile(fence_fname_wrong, destination, 'f');
        end
        
        % Check for a misplaced Excel file
        excel_fname_wrong = sprintf('Bogue %s%sBogue %s %s.xlsx',...
            alphabet(letter), filesep, alphabet(letter), years{year});
        if exist(excel_fname_wrong)
            destination = sprintf('Bogue %s%s%s%s', alphabet(letter),...
                filesep, years{year}, filesep);
            movefile(excel_fname_wrong, destination, 'f');
        end
  
    end
end