% This is the main Automorph file to extract morphometrics from Lidar
% profil   es.
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%
tic;
clear all
close all
clc

% First load all the excel files to be used. Store the Excel files in the 
% "Excel files" folder. Automorph will make any other folder as it goes
addpath('Subfunctions')
addpath('Excel Files')
files = dir(['Excel Files' filesep '*.xlsx']);

% Set the location of the state plane coordinates. Check the "sp_proj"
% function in the Subfunctions folder for details
sp_loc = 'north carolina'; %% You can change this!!

% Set the backshore drop and buffer_pct for the crest_finder
backshore_drop = 0.3; %% You can change this!! (0.6 in Mull/Ruggiero 2014)
buffer_pct = 0.10; %% Can change this!!

% Set the dune slope threshold to ignore buildings (Stockdon et al, 2009)
dune_slope_threshold = 35;  % Degrees (35 in Stockdon et al, 2009)

% Set the starting year of analysis and the final year
start_year = '1997';
final_year = '2016';

% Set the number of columns for the morphometrics table, this should match
% the number of points being saved in the morpho_table_maker script.
% Shouldn't matter if the number is incorrect but the program will run
% faster if it is
num_cols = 59; %% You can change this!!

% Loop through the Excel files, ignoring the Profile Info Table
for q = 1:length(files)
    if ~strcmp(files(q).name, 'Profile Info Table.xlsx') &&...
            ~strcmp(files(q).name(end-10:end-5), 'Fences')
        
        % Excelload will open the .xlsx file with the profiles and format
        % it into a 3D matrix with a dimension for X, Y, and Z. If this has
        % been done before on the given .xlsx file than it will just load
        % the formatted data and move on.
        excelload
        
        % Load the morpho_table from the previous year, skip the header row.
        if ~strcmp(year, start_year)
           if strcmp(year, '1998')
               previous_year = '1997';
           elseif strcmp(year, '1999')
               previous_year = '1998';
           elseif strcmp(year, '2000')
               previous_year = '1999';
           elseif strcmp(year, '2004')
               previous_year = '2000';
           elseif strcmp(year, '2005')
               previous_year = '2004';
           elseif strcmp(year, '2010')
               previous_year = '2005';
           elseif strcmp(year, '2011')
               previous_year = '2010';
           elseif strcmp(year, '2014')
               previous_year = '2011';
           elseif strcmp(year, '2016')
               previous_year = '2014';
           end
           original_data_fname = sprintf('%s%s%s%sMorphometrics for %s %s.csv',...
               location(1:end-1), filesep, previous_year, filesep,...
               location(1:end-1), previous_year);
           original_data = csvread(original_data_fname, 1);
        end
        
        % Preallocate an empty matrix to loop data into
        morpho_table = NaN(transects, num_cols);
        
        % If the area has fences, find where all the fences are in the
        % study area. If this script ran before for the current study area
        % it will just load the "Fence Crossings" .mat file for the
        % study area
        if fenced
            fence_finder
        end
        clc
        
        local_x_values = NaN(max_index-2, transects);

        for pass = 1:2 %% Change to a 2 to use adjustment codes
            % Loop through the transects and plot the morphometrics
            
            % Initialize the progress bar
            progress_bar_label = sprintf('%s %s',...
                    location(1:end-1), year);
            progressbar(progress_bar_label)
            
            for k = 1:length(profiles(1,:,:))
                
                % Update the progress bar
                progressbar(k/length(profiles(1,:,:)))
                
                % Smooth the profile with a moving filter 
                profiles(:,k,3) = smooth(profiles(:,k,3),11,'moving');

                % Find MHW
                mhw_finder
                
                % Find the natural dune crest
                crest_finder
                
                % Find the natural dune toe
                toe_finder
                
                % Check that the dune slope is less than
                % the threshold value. Keep finding new crests
                % until it is
                dune_slope = atand((y_crest - y_toe) / abs(x_crest - x_toe));
                while (dune_slope >= dune_slope_threshold) &&...
                        (ignore_slope_threshold == 0)
                    
                    % Find the natural dune crest
                    crest_finder_slope_threshold
                    
                    % Find the natural dune toe
                    toe_finder
                    
                    % Recalculate the dune slope
                    dune_slope = atand((y_crest - y_toe) / abs(x_crest - x_toe));
                end

                % Find an possible berm
                berm_finder
                
                % Find the natural dune heel
                heel_finder

                % Find the natural dune volume 
                natural_dune_volume_finder               
                
                % If a fence exists and is seaward of
                % the natural dune crest, run extra methods
                if fenced 
                    fence_locator % Find where the fence is
                    if exist('fence_index') && (fence_index >= crest_index)
                        fence_crest_finder % Find where the fenced dune crest is
                        fence_heel_finder % Find the fenced dune heel
                        fence_toe_finder % Find the fenced dune toe
                        fenced_dune_volume_finder % Find the fenced dune volume
                        total_dune_volume_finder % Find the fenced+natural volume
                    end
                end

                % Calculate the beach width
                beach_width_finder
                
                % Calculate the beach and foreshore slope
                beach_slope_finder
                
                % Find the elevation of the crest height from the starting year
                find_starting_crest_location
                
                % Put the data into the morpho_table
                morpho_table_maker

                % Plot the profile with the morphometrics
                profile_plotter

                % Clear extraneous variables
                clear fence_heel_index x_fence_heel y_fence_heel...
                    local_x_fence_heel local_y_fence_heel fence_heel_lon...
                    fence_heel_lat fence_toe_index x_fence_toe y_fence_toe...
                    local_x_fence_toe local_y_fence_toe fence_toe_lon...
                    fence_toe_lat y_fence_crest fence_crest_index

            end
        end
        
        % Save the morphometrics to a .csv and .mat file
        save_morphometrics
        
        % Plot a 2D view of the results
        morpho_2d_plotter
        
        % Plot the crest_threshold over time
        crest_threshold_plotter
        
        % Clear profiles for the next location/year and the local_x_values
        clear profiles local_x_values
        
        % Move the file out of Excel files and into the location folder
        source = sprintf('Excel Files%s%s', filesep, files(q).name);
        destination = sprintf('%s%s%s', location(1:end-1), filesep, year);
        movefile(source, destination, 'f');
        
        % If it is the final year and there are fences, move the fences
        % file to the location folder as well
        fence_file = sprintf('Excel Files%s%s Fences.xlsx',...
            filesep, location(1:end-1));
        if strcmp(year, final_year) && exist(fence_file)
            movefile(fence_file, location(1:end-1),'f');
        end
        
    end   
end

toc;
sec = rem(toc,60);
min = floor(toc/60);
hr = floor(min/60);
min = min - (hr*60);
fprintf('The program completed in %d hour(s), %d minute(s), and %.2f seconds\n',...
    hr, min, round(sec))
