% This script plots DEMs and difference DEMs of the profiles
%
% Michael Itzkin, 5/23/2018
%------------------------------------------------------------------------%
close all
clear all
clc

% Load all the current folders into a struct.
files = dir();

% Loop over all the folders, only consider those which are for Bogue.
% Checking for bytes==0 prevents the loop from trying to open
% "Bogue_Profile_Overlays.m" as a folder
for i = 7%1:length(files)
    if length(files(i).name) > 5 &&...
            strcmp(files(i).name(1:5), 'Bogue') &&...
            files(i).bytes == 0
        
        % Set the filenames
        x_values_fname = sprintf('%s%s2010%sX Values for %s 2010.mat',...
            files(i).name, filesep, filesep, files(i).name);
        profiles_2010_fname = sprintf('%s%s2010%sProfiles for %s 2010.mat',...
            files(i).name, filesep, filesep, files(i).name);
        morpho_2010_fname = sprintf('%s%s2010%sMorphometrics for %s 2010.mat',...
            files(i).name, filesep, filesep, files(i).name);
        profiles_2011_fname = sprintf('%s%s2011%sProfiles for %s 2011.mat',...
            files(i).name, filesep, filesep, files(i).name);
        morpho_2011_fname = sprintf('%s%s2011%sMorphometrics for %s 2011.mat',...
            files(i).name, filesep, filesep, files(i).name);
        profiles_2014_fname = sprintf('%s%s2014%sProfiles for %s 2014.mat',...
            files(i).name, filesep, filesep, files(i).name);
        morpho_2014_fname = sprintf('%s%s2014%sMorphometrics for %s 2014.mat',...
            files(i).name, filesep, filesep, files(i).name);
        profiles_2016_fname = sprintf('%s%s2016%sProfiles for %s 2016.mat',...
            files(i).name, filesep, filesep, files(i).name);
        morpho_2016_fname = sprintf('%s%s2016%sMorphometrics for %s 2016.mat',...
            files(i).name, filesep, filesep, files(i).name);
        
        % Load the data.
        x_values = load(x_values_fname);
        profiles_2010 = load(profiles_2010_fname);
        profiles_2011 = load(profiles_2011_fname);
        profiles_2014 = load(profiles_2014_fname);
        profiles_2016 = load(profiles_2016_fname);
        morpho_2010 = load(morpho_2010_fname);
        morpho_2011 = load(morpho_2011_fname);
        morpho_2014 = load(morpho_2014_fname);
        morpho_2016 = load(morpho_2016_fname);
        
        x = x_values.x_values;
        profiles_2010 = profiles_2010.profiles;
        profiles_2011 = profiles_2011.profiles;
        profiles_2014 = profiles_2014.profiles;
        profiles_2016 = profiles_2016.profiles;
        crest_2010 = morpho_2010.morpho_table(:,55);
        fcrest_2010 = morpho_2010.morpho_table(:,57);
        crest_2011 = morpho_2011.morpho_table(:,55);
        fcrest_2011 = morpho_2011.morpho_table(:,57);
        crest_2014 = morpho_2014.morpho_table(:,55);
        fcrest_2014 = morpho_2014.morpho_table(:,57);
        crest_2016 = morpho_2016.morpho_table(:,55);
        fcrest_2016 = morpho_2016.morpho_table(:,57);
        
        % Make a directory to store figures in
        new_folder = sprintf('%s%sDEMs',...
            files(i).name, filesep);
        mkdir(new_folder)
        
        % Plot a DEM for 2010
        hold on
        colormap(bluewhitered)
        contourf(1:1500, x_values.x_values, profiles_2011(:,:,3)-profiles_2010(:,:,3), 5)
        plot(1:length(crest_2010), x_values.x_values(crest_2010), 'c', 'LineWidth', 3)
        colorbar()
    end
end
