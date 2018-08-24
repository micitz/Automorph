function [gen_x, gen_y, local_x, local_y, lon, lat] =...
    set_locations(x_values, local_x_values, profiles, index, k, sp_loc)
    % This function takes the index of a feature and sets three coordinates for
    % it:
    % 1: The X and Y location using the normal x_values vector
    % 2: The local X and Y coordinates
    % 3: The longitude and latitude
    
    % Set the x_heel and y_heel location, which is the relative location on the
    % profile for heel. Also find the local x, y location to plot later
    [gen_x, gen_y] = set_x_y(x_values, profiles(:,:,3), index, k);
    [local_x, local_y] = set_x_y(local_x_values(:,k),...
        profiles(:,:,3), index, k);

    % Store the lat and lon location of heel
    [lon, lat] = lon_lat_finder(sp_loc, profiles, index, k);

end