"""
Functions to load and format data for Automorph

Michael Itzkin, 6/28/2021
"""

from scipy.interpolate import interp1d

import statsmodels.nonparametric.smoothers_lowess as lowess
from pyproj import Proj, transform
import pandas as pd
import numpy as np
import os


# Set general information
DATA_DIR = os.path.join('..', 'Data')


def get_basic_information(file):
    """
    Identify the location, year, and number of
    profiles for the current set of profiles
    being worked on

    file: String with the filename of the current set of profiles
    """

    # Pull out the location and year from the filename
    location, year = file[:-4].split()

    # Identify the number of profiles in the file
    num_profiles = 0
    with open(os.path.join(DATA_DIR, file)) as topo_file:
        for line in topo_file:
            if 'Cross' in line:
                num_profiles += 1

    # Make a folder for the location to place locations into
    new_folder = os.path.join('..', f'{location}', f'{year}', 'Profiles')
    if not os.path.exists(new_folder):
        os.makedirs(new_folder)

    # Make a folder for the location to place locations into
    new_folder = os.path.join('..', f'{location}', f'{year}', 'Figures')
    if not os.path.exists(new_folder):
        os.makedirs(new_folder)

    return location, year, num_profiles


def make_profile_files(file, location, year, num_profiles, epsg):
    """
    Make individual profile files from the main data
    file and place them into the correct folder for
    the location and year

    file: String with the main data file name
    location: String with the profile location name
    year: String with the year of the data
    num_profiles: Int with the total number of profiles in the section
    epsg: Int with the number code for the in projection
    """

    # Loop through the profiles
    for profile in range(1, num_profiles + 1):

        # Load the data file and find the points for the current profile
        data_file = os.path.join(DATA_DIR, file)
        profile_file = os.path.join('..',
                                    f'{location}',
                                    f'{year}',
                                    'Profiles',
                                    f'{location} {year} {profile}.txt')

        # Write the profile files
        with open(data_file) as infile, open(profile_file, 'w') as outfile:
            copy = False
            for line in infile:
                if line.strip() == f'Cross Section {profile}':
                    copy = True
                    continue
                elif line.strip() == f'Cross Section {profile + 1}':
                    copy = False
                    continue
                elif copy:
                    outfile.write(line)

        # Reopen the profiles as a DataFrame
        df = pd.read_table(profile_file, header=0)
        new_cols = [col.strip() for col in df.columns]
        df.columns = new_cols

        # Add a column for lat and lon
        inProj = Proj(init=f'epsg:{epsg}', preserve_units=True)
        outProj = Proj(init='epsg:4326')
        df['Lat'], df['Lon'] = transform(inProj, outProj, list(df['X']), list(df['Y']))

        # Save the DataFrame again as a .txt file
        df.to_csv(profile_file, sep='\t', index=False)

    print(f'Finished parsing out profiles for {location} {year}...')


def morpho_dict():
    """
    Return a blank dictionary with a key, value
    combination for every morphometric value being
    calculated
    """

    return {'Profile': [],
            'XMHW': [],
            'YMHW': [],
            'MHW Lat': [],
            'MHW Lon': [],
            'MHW CI': [],
            'MHW Lidar Error': [],
            'MHW X Error': [],
            'MHW Error': [],
            'XCrest': [],
            'YCrest': [],
            'Crest Lat': [],
            'Crest Lon': [],
            'XHeel': [],
            'YHeel': [],
            'Heel Lat': [],
            'Heel Lon': [],
            'XToe': [],
            'YToe': [],
            'Toe Lat': [],
            'Toe Lon': [],
            'Foreshore Slope': [],
            'Dune Volume': [],
            'Beach Volume': [],
            'Profile Volume': [],
            'Orientation': []}


def setup_profile(location, year, profile, grid=0.5):
    """
    Determine the cross-shore distance of the profile
    and interpolate onto a 1m spaced grid

    location: String with the location
    year: String with the year being looked at
    profile: Int with the profile number
    grid: Interpolate onto the grid of spacing

    This comes from Paige's field profile code
    """

    # Load the profiles into a Pandas DataFrame
    fname = os.path.join('..',
                         f'{location}',
                         f'{year}',
                         'Profiles',
                         f'{location} {year} {profile}.txt')
    df = pd.read_table(fname, header=0, names=['X', 'Y', 'Z', 'Lat', 'Lon'])

    # Loop over the Z-Values
    for ix in df['Z'].index:
        if 'NoData' in str(df['Z'][ix]):
            df['Z'].iloc[ix] = np.nan
    df = df.fillna(method='ffill').fillna(method='bfill')

    # Compute the cross-shore distance by identifying maximum easting
    idx = df['Y'].idxmin()
    xstart, ystart = df['X'].iloc[idx], df['Y'].iloc[idx]
    dist_cross = np.sqrt((df['X'] - xstart) ** 2 + (df['Y'] - ystart) ** 2)
    elev_cross = lowess.lowess(df['Z'], dist_cross, frac=0, return_sorted=False)

    # Interpolate onto a regularly spaced grid
    x_new = np.arange(start=0, stop=np.around(np.nanmax(dist_cross)), step=grid)
    f = interp1d(dist_cross, elev_cross)
    y_new = f(x_new)

    # Convert all to Numpy arrays for consistency
    dist_cross = np.asarray(dist_cross)
    x_new = np.asarray(x_new)
    y_new = np.asarray(y_new)
    lats = np.asarray(df['Lat'])
    lons = np.asarray(df['Lon'])

    # Flip the profile if needed to guarantee
    # that the indices increase landwards
    if dist_cross[-1] > dist_cross[0]:
        dist_cross = np.flip(dist_cross)
        elev_cross = np.flip(elev_cross)
        x_new = np.flip(x_new)
        y_new = np.flip(y_new)
        lats = np.flip(lats)
        lons = np.flip(lons)

    return dist_cross, elev_cross, x_new, y_new, lats, lons
