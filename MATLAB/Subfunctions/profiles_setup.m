% This script processes .txt files with LiDAr profiles and returns their
% information to a .txt file as well as saves them to an .xlsx file
% for Automorph
%
% Michael Itzkin, 6/16/2018
%------------------------------------------------------------------------%
close all
clear all
clc

% Load the profile info table
profile_table_fname = sprintf('Excel Files%sProfile Info Table.xlsx', filesep);
profile_info_table = readtable(profile_table_fname);

% Set the first and last years being looked at
first_year = '1997';
last_year = '2016';

% Load all the files to be processes
to_be_processed_path = 'H:\Michael\Bogue Banks\Full Island Profiles\Text Files';
files = dir([to_be_processed_path filesep '*.txt']);

% Loop through the files and process
for q = 1:length(files)

    % Figure out the location and year from the file name
    location = files(q).name(1:end-9);
    year = files(q).name(end-7:end-4);
    
    % Set the path to the files to process
    fname = sprintf('%s%s%s',...
        to_be_processed_path, filesep, files(q).name);
    
    % Print out the current area being worked on
    fprintf('Currently Working On: %s %s', location, year)

    % Create an empty table to put data into
    % This table will be saved as an .xlsx file
    % after processing. Initiate the cross-section
    % count to 0 and the max index to 0.
    output_table = NaN(1000000,3);  % Pre-allocate a massive table for speed
    transects = 0;                  % Count the number of transects
    index = 0;                      % Count the indexes
    max_index = 0;                  % Track the max indexes
    line = 0;                       % Track the lines in the file

    % Open the file
    fid = fopen(fname);
    if fid==-1
        fprintf('ERROR! Could not open the file: %s', fname);
    else
        % Loop through the lines in the file
        while ~feof(fid)
            curr_line = fgetl(fid);
            line = line + 1;

            % If the current line is a cross section identifer
            % increment the cross-section count and put a row of
            % NaN values into the output table. Reset the index
            % to 0
            if strcmp(curr_line(1:13), 'Cross Section')            
                transects = transects + 1;
                output_table(line,:) = [NaN NaN NaN];

                if index > max_index
                    % Reset the max_index if the current
                    % index is larger
                    max_index = index + 2;
                end

                index = 0;

            % If the current line is an "X Y Z" line
            % put a row of NaN values into the output
            % table
            elseif strcmp(curr_line, '         X	         Y	         Z')
                output_table(line,:) = [NaN NaN NaN];

            % If the current line has numbers in it
            % put the current line into the output 
            % table and increment the index
            else
                output_table(line,:) = [str2num(curr_line)];
                index = index + 1;
            end
        end

        % Remove unnecessary rows from the output table
        output_table(line+1:end,:) = [];

        % Update the values in the profile info table
        for i = 1:height(profile_info_table)
            % Find the row for the current location
            if strcmp(profile_info_table{i,1}, location) &&...
                    (profile_info_table{i,2}==str2double(year))
                info_row = i;
            end
        end

        profile_info_table{info_row, 1} = {location};
        profile_info_table{info_row, 2} = str2double(year);
        profile_info_table{info_row, 3} = transects;
        profile_info_table{info_row, 4} = index + 2;

        if strcmp(year, first_year) &&...
                (profile_info_table{info_row+1, 17} > max_index)
            profile_info_table{info_row, 17} = profile_info_table{info_row+1, 17};
        elseif strcmp(year, last_year) &&...
                (profile_info_table{info_row-1, 17} > max_index)
            profile_info_table{info_row, 17} = profile_info_table{info_row-1, 17};
        else
            profile_info_table{info_row, 17} = max_index;
        end

        % Save the output table as an .xlsx file
        xls_fname = sprintf('Excel Files%s%s %s.xlsx',...
            filesep, location, year);
        xlswrite(xls_fname, output_table);
    end
end
