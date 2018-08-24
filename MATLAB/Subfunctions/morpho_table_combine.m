% This script combines all of the individual sections data into one master
% morpho_table and then a "natural" and "fenced" areas table(s)
%
% Michael Itzkin, 6/11/2018
%-----------------------------------------------------------------------%
close all
clear all
clc

% Make a path to the data folder
data_folder = sprintf('G:%sSand Fences%sData', filesep, filesep);
mkdir(data_folder)

% Set the sections
letters = 'A':'Z';

% Make empty tables
data_1997 = [];
data_1998 = [];
data_1999 = [];
data_2000 = [];
data_2004 = [];
data_2005 = [];
data_2010 = [];
data_2011 = [];
data_2014 = [];
data_2016 = [];

% Loop through the data and combine into a big table for each year
for l = 1:length(letters)
    
    % 1997
    data_1997_fname = sprintf('Bogue %s%s1997%sMorphometrics for Bogue %s 1997.csv',...
        letters(l), filesep, filesep, letters(l));
    data_1997 = [data_1997; csvread(data_1997_fname, 2)];
    
    % 1998
    data_1998_fname = sprintf('Bogue %s%s1998%sMorphometrics for Bogue %s 1998.csv',...
        letters(l), filesep, filesep, letters(l));
    data_1998 = [data_1998; csvread(data_1998_fname, 2)];
    
    % 1999
    data_1999_fname = sprintf('Bogue %s%s1999%sMorphometrics for Bogue %s 1999.csv',...
        letters(l), filesep, filesep, letters(l));
    data_1999 = [data_1999; csvread(data_1999_fname, 2)];
    
    % 2000
    data_2000_fname = sprintf('Bogue %s%s2000%sMorphometrics for Bogue %s 2000.csv',...
        letters(l), filesep, filesep, letters(l));
    data_2000 = [data_2000; csvread(data_2000_fname, 2)];
    
    % 2004
    data_2004_fname = sprintf('Bogue %s%s2004%sMorphometrics for Bogue %s 2004.csv',...
        letters(l), filesep, filesep, letters(l));
    data_2004 = [data_2004; csvread(data_2004_fname, 2)];
    
    % 2005
    data_2005_fname = sprintf('Bogue %s%s2005%sMorphometrics for Bogue %s 2005.csv',...
        letters(l), filesep, filesep, letters(l));
    data_2005 = [data_2005; csvread(data_2005_fname, 2)];
    
    % 2010
    data_2010_fname = sprintf('Bogue %s%s2010%sMorphometrics for Bogue %s 2010.csv',...
        letters(l), filesep, filesep, letters(l));
    data_2010 = [data_2010; csvread(data_2010_fname, 2)];
    
    % 2011
    data_2011_fname = sprintf('Bogue %s%s2011%sMorphometrics for Bogue %s 2011.csv',...
        letters(l), filesep, filesep, letters(l));
    data_2011 = [data_2011; csvread(data_2011_fname, 2)];
    
    % 2014
    data_2014_fname = sprintf('Bogue %s%s2014%sMorphometrics for Bogue %s 2014.csv',...
        letters(l), filesep, filesep, letters(l));
    data_2014 = [data_2014; csvread(data_2014_fname, 2)];
    
    % 2016
    data_2016_fname = sprintf('Bogue %s%s2016%sMorphometrics for Bogue %s 2016.csv',...
        letters(l), filesep, filesep, letters(l));
    data_2016 = [data_2016; csvread(data_2016_fname, 2)];
             
end

% Renumber the first column for each data_*year* variable to be 1-length
data_1997(:,1) = 1:length(data_1997(:,1));
data_1998(:,1) = 1:length(data_1998(:,1));
data_1999(:,1) = 1:length(data_1999(:,1));
data_2000(:,1) = 1:length(data_2000(:,1));
data_2004(:,1) = 1:length(data_2004(:,1));
data_2005(:,1) = 1:length(data_2005(:,1));
data_2010(:,1) = 1:length(data_2010(:,1));
data_2011(:,1) = 1:length(data_2011(:,1));
data_2014(:,1) = 1:length(data_2014(:,1));
data_2016(:,1) = 1:length(data_2016(:,1));

% Create a cell array to use as the header for the .csv file
morpho_header = {'Profile No.', 'x_mhw', 'y_mhw', 'x_fence_toe',...
    'y_fence_toe', 'x_fence', 'y_fence', 'x_fence_crest', 'y_fence_crest',...
    'x_fence_heel', 'y_fence_heel', 'x_toe', 'y_toe', 'x_crest', 'y_crest',...
    'x_heel', 'y_heel', 'local_x_mhw', 'local_y_mhw', 'local_x_fence_toe',...
    'local_y_fence_toe', 'local_x_fence', 'local_y_fence',...
    'local_x_fence_crest', 'local_y_fence_crest', 'local_x_fence_heel',...
    'local_y_fence_heel', 'local_x_toe', 'local_y_toe', 'local_x_crest',...
    'local_y_crest', 'local_x_heel', 'local_y_heel', 'mhw_lon', 'mhw_lat',...
    'fence_toe_lon', 'fence_toe_lat', 'fence_lon', 'fence_lat',...
    'fence_crest_lon', 'fence_crest_lat', 'fence_heel_lon', 'fence_heel_lat',...
    'toe_lon', 'toe_lat', 'crest_lon', 'crest_lat', 'heel_lon', 'heel_lat'...
    'Natural Dune Volume', 'Fenced Dune Volume', 'Total Dune Volume',...
    'Beach Width', 'Start Crest Height', 'Start Crest Index',...
    'Start Fence Crest Height', 'Start Fence Crest Index', 'Beach Slope',...
    'Foreshore Slope', 'x_berm', 'y_berm', 'local_x_berm',...
    'local_y_berm', 'berm_lon', 'berm_lat'};

% Save the tables
fname_1997 = sprintf('%s%sMorphometrics for Bogue 1997.csv',...
    data_folder, filesep);
save_morpho(fname_1997, data_1997)

fname_1998 = sprintf('%s%sMorphometrics for Bogue 1998.csv',...
    data_folder, filesep);
save_morpho(fname_1998, data_1998)

fname_1999 = sprintf('%s%sMorphometrics for Bogue 1999.csv',...
    data_folder, filesep);
save_morpho(fname_1999, data_1999)

fname_2000 = sprintf('%s%sMorphometrics for Bogue 2000.csv',...
    data_folder, filesep);
save_morpho(fname_2000, data_2000)

fname_2004 = sprintf('%s%sMorphometrics for Bogue 2004.csv',...
    data_folder, filesep);
save_morpho(fname_2004, data_2004)

fname_2005 = sprintf('%s%sMorphometrics for Bogue 2005.csv',...
    data_folder, filesep);
save_morpho(fname_2005, data_2005)

fname_2010 = sprintf('%s%sMorphometrics for Bogue 2010.csv',...
    data_folder, filesep);
save_morpho(fname_2010, data_2010)

fname_2011 = sprintf('%s%sMorphometrics for Bogue 2011.csv',...
    data_folder, filesep);
save_morpho(fname_2011, data_2011)

fname_2014 = sprintf('%s%sMorphometrics for Bogue 2014.csv',...
    data_folder, filesep);
save_morpho(fname_2014, data_2014)

fname_2016 = sprintf('%s%sMorphometrics for Bogue 2016.csv',...
    data_folder, filesep);
save_morpho(fname_2016, data_2016)




function save_morpho(fname, data)

% Create a cell array to use as the header for the .csv file
morpho_header = {'Profile No.', 'x_mhw', 'y_mhw', 'x_fence_toe',...
    'y_fence_toe', 'x_fence', 'y_fence', 'x_fence_crest', 'y_fence_crest',...
    'x_fence_heel', 'y_fence_heel', 'x_toe', 'y_toe', 'x_crest', 'y_crest',...
    'x_heel', 'y_heel', 'local_x_mhw', 'local_y_mhw', 'local_x_fence_toe',...
    'local_y_fence_toe', 'local_x_fence', 'local_y_fence',...
    'local_x_fence_crest', 'local_y_fence_crest', 'local_x_fence_heel',...
    'local_y_fence_heel', 'local_x_toe', 'local_y_toe', 'local_x_crest',...
    'local_y_crest', 'local_x_heel', 'local_y_heel', 'mhw_lon', 'mhw_lat',...
    'fence_toe_lon', 'fence_toe_lat', 'fence_lon', 'fence_lat',...
    'fence_crest_lon', 'fence_crest_lat', 'fence_heel_lon', 'fence_heel_lat',...
    'toe_lon', 'toe_lat', 'crest_lon', 'crest_lat', 'heel_lon', 'heel_lat'...
    'Natural Dune Volume', 'Fenced Dune Volume', 'Total Dune Volume',...
    'Beach Width', 'Start Crest Height', 'Start Crest Index',...
    'Start Fence Crest Height', 'Start Fence Crest Index', 'Beach Slope',...
    'Foreshore Slope', 'x_berm', 'y_berm', 'local_x_berm',...
    'local_y_berm', 'berm_lon', 'berm_lat'};

fid = fopen(fname, 'w+'); 

% write header
for i = 1:length(morpho_header)
    fprintf(fid, '%s', morpho_header{i});
    if i ~= length(morpho_header)
        fprintf(fid, ',');
    else
        fprintf(fid, '\n' );
    end
end
% close file
fclose(fid);

% Append the data to the .csv file which should now have a header in the
% first row
dlmwrite(fname,...
    data,...
    '-append',...
    'Delimiter', ',',...
    'Precision', 9)
end