% This script loads an unformatted .xlsx file containing lidar profiles and
% formats it into a more convenient set of matrices for analysis. An X, Y,
% and Z matrix is made and saved as a .mat file. A plot of the profiles all
% lined up together is also made and saved.
%
% This is a slower script so if the data has been formatted before than it
% just loads the .mat file and moves on. If you have new data from a
% location, delete the existing .mat file first before running!
%
% Michael Itzkin, 3/26/2018
%------------------------------------------------------------------------%

% Load Excel Files
[pathstr, spreadsheet, ext] = fileparts(files(q).name); 
excel = xlsread(spreadsheet);
[~, col] = size(excel);
location = spreadsheet(1:end-4);
year = spreadsheet(end-3:end);
new_folder = sprintf('%s%s%s%sProfile Plots',location(1:end-1), filesep, year, filesep);
mkdir(new_folder)
profile_info % profile_info program

% Check if the profile has been formatted before by looking for the
% appropriate .mat files. If they exist, load them and skip the rest
check_profiles_fname = sprintf('%s%s%s%sProfiles for %s %s.mat',...
    location(1:end-1), filesep, year, filesep, location(1:end-1), year);
check_x_values_fname = sprintf('%s%s%s%sX Values for %s %s.mat',...
    location(1:end-1), filesep, year, filesep, location(1:end-1), year);
if exist(check_profiles_fname) && exist(check_x_values_fname)
    
    load(check_profiles_fname);
    load(check_x_values_fname);
    
else

    % Convert the elevations to meters
    excel(:,3:end) = excel(:,3:end) * 0.3048;

    % Create three empty matrices with as many rows as the max_index and as
    % many columns as transects
    x_profiles = ones(max_index, transects) * -1;
    y_profiles = ones(max_index, transects) * -1;
    z_profiles = ones(max_index, transects) * -1;

    row = 1;
    column = 1;
    for i = 1:(length(excel(:,3))-1)
        x_profiles(row, column) = excel(i, 1);
        y_profiles(row, column) = excel(i, 2);
        z_profiles(row, column) = excel(i, 3);
        row = row + 1;

        if (isnan(excel((i+1),1)) == 1)
            column = column + 1;
            row = 1;
        end
    end

    % Every even numbered column will just be -1 and NaN so remove all even
    % numbered columns
    column_numbers = 1:length(x_profiles(1,:));
    delete_columns = find(mod(column_numbers,2)==0);
    x_profiles(:,delete_columns) = [];
    y_profiles(:,delete_columns) = [];
    z_profiles(:,delete_columns) = [];

    % Delete the last row of the matrices as they are all -1
    x_profiles(end,:) = [];
    y_profiles(end,:) = [];
    z_profiles(end,:) = [];

    % To adjust all the numbers to be lined up perfectly, copy the matrices
    % from the second column to the end into temporary matrices. Delete the
    % first row from the temporary matrices and add a NaN row to the end. Put
    % the temporary matrices back into the main matrices and delete the last
    % rows again
    x_temp = x_profiles(:,2:end);
    y_temp = y_profiles(:,2:end);
    z_temp = z_profiles(:,2:end);

    x_temp(1,:) = [];
    y_temp(1,:) = [];
    z_temp(1,:) = [];

    x_temp(end+1,:) = NaN;
    y_temp(end+1,:) = NaN;
    z_temp(end+1,:) = NaN;

    x_profiles(:,2:end) = x_temp;
    y_profiles(:,2:end) = y_temp;
    z_profiles(:,2:end) = z_temp;

    x_profiles(end,:) = [];
    y_profiles(end,:) = [];
    z_profiles(end,:) = [];

    clear x_temp y_temp z_temp

    % Make an x-vector to accompany the y-data
    x_values = (linspace(profile_length,0,(length(x_profiles(:,1)))));

    % Plot profiles and save to the location folder
    Title = sprintf('Cross Shore Profiles for %s',spreadsheet);
    figure1 = figure('Name',Title);
    hold on
    plot(x_values, z_profiles)
    set(gca, 'Xdir', 'reverse')
    title(sprintf('Cross Shore Profiles for %s', spreadsheet))
    xlabel('Cross Shore Distance (m)')
    ylabel('Elevation (m, NAVD88)')
    save_name = sprintf('%s%s%s%s%s.png', location(1:end-1), filesep, year, filesep, Title);
    saveas(figure1, save_name, 'png')
    close()

    % Combine the x, y, and z matrices into a 3D matrix and save it as a.mat
    % file for faster access
    profiles(:,:,1) = x_profiles;
    profiles(:,:,2) = y_profiles;
    profiles(:,:,3) = z_profiles;
    profiles_fname = sprintf('%s%s%s%sProfiles for %s %s.mat',...
        location(1:end-1), filesep, year, filesep, location(1:end-1), year);
    save(profiles_fname, 'profiles', '-mat')

    % Save the x_values vector
    x_values_fname = sprintf('%s%s%s%sX Values for %s %s.mat',...
        location(1:end-1), filesep, year, filesep, location(1:end-1), year);
    save(x_values_fname, 'x_values', '-mat')

end

clear excel check_profiles_fname check_x_values_fname
