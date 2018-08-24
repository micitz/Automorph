function [x, y] = set_x_y(x_values, y_values, ind, k)
    % This function sets the x and y value of a point on the profile

    x = x_values(ind);
    y = y_values(ind, k);

end