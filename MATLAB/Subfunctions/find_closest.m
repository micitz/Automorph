function outvar = find_closest(a, n)
    % Find the closest point in vector a to value n. This returns the index
    % of the element in a.

    dist = abs(a-n);
    outvar = find(dist == nanmin(dist));

end