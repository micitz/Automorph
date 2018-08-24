% This program helps select the appropriate parameters for each study area
% It requires a "Profile Info Table" Excel sheet to be in the path. It
% is faster and more convenient thant the original version
%
% Michael Itzkin, 5/22/2018
%----------------------------------------------------------------------%

% Load the Profile Info Table
profile_info_table = readtable('Excel Files\Profile Info Table.xlsx');

% Find the row for the current location
for i = 1:height(profile_info_table)
    if strcmp(profile_info_table{i,1}, location(1:end-1)) &&...
            (profile_info_table{i,2}==str2double(year))
        info_row = i;
    end
end

% Use the info_row varaible to load some parameters regarding the location
transects = profile_info_table{info_row, 3};
index = profile_info_table{info_row, 4};
profile_length = profile_info_table{info_row, 5};
fenced = profile_info_table{info_row, 6};
MHW = profile_info_table{info_row, 7};
Bermed = profile_info_table{info_row, 8};
toe_correct = profile_info_table{info_row, 9};
berm_toe = profile_info_table{info_row, 10};
shallow_peak_correct = profile_info_table{info_row, 11};
hummock_correct = profile_info_table{info_row, 12};
fence_toe_correct = profile_info_table{info_row, 13};
OSU_toe = profile_info_table{info_row, 14};
crest_threshold = profile_info_table{info_row, 15};
heel_threshold = profile_info_table{info_row, 16};
max_index = profile_info_table{info_row, 17};