"""
Automatically extract dune and beach morphometrics
from LiDAR profiles

Michael Itzkin, 6/28/2021
"""

from Functions import Data_Functions as dfuncs
from Functions import Morpho_Functions as mfuncs
from Functions import Plot_Functions as pfuncs

import pandas as pd
import shutil
import os


# Set paths to other folders
DATA_DIR = os.path.join('..', 'Data')


def main():
    """
    Run the analysis
    """

    # Set parameters
    use_extension = '.xyz'
    epsg = 3358             # St. Pete = 2778, NC = 3358
    grid_size = 0.5         # Doesn't matter: The gridded profiles aren't used
    mhw = 0.34              # St. Pete = 0.187, NC = 0.34
    heel_threshold = 0.6
    crest_pct = 0.1

    # Loop through the files in the data directory. Only
    # consider profiles with an .xyz extension
    for file in os.listdir(DATA_DIR):
        if file.endswith(use_extension):

            # Setup a dictionary with blank lists to loop into
            morpho = dfuncs.morpho_dict()

            # Get basic information about the current set of profiles and
            # make a folder to store results in
            location, year, num_profiles = dfuncs.get_basic_information(file)

            # Print out a header to the terminal
            print('\n------------------------------------------------')
            print(f'Currently Working On: {location} {year}')
            print(f'Profiles: {num_profiles}')
            print('------------------------------------------------')

            # Parse out the individual profiles from the main file
            # into individual .txt files
            dfuncs.make_profile_files(file, location, year, num_profiles, epsg)

            # Loop over the profiles
            for profile in range(1, num_profiles + 1):

                # Store the profile number
                morpho['Profile'].append(profile)

                # Determine the profile length and interpolate onto a grid
                # of a pre-defined spacing
                dist_cross, elev_cross, ex, why, lats, lons =\
                    dfuncs.setup_profile(location, year, profile, grid_size)

                # Identify the MHW contour. This function also calculates
                # the foreshore slope since the error method for MHW includes
                # calculating it.
                morpho = mfuncs.find_mhw(morpho, dist_cross, elev_cross,
                                         lats, lons, mhw)

                # Identify the dune crest
                morpho = mfuncs.find_crest(morpho, dist_cross, elev_cross,
                                           lats, lons, mhw,
                                           heel_threshold, crest_pct)

                # Identify the dune heel
                morpho = mfuncs.find_heel(morpho, dist_cross, elev_cross,
                                          lats, lons)

                # Identify the dune toe
                morpho = mfuncs.find_toe(morpho, dist_cross, elev_cross,
                                         lats, lons)

                # Calculate volumes
                morpho = mfuncs.dune_volume(dist_cross, elev_cross, morpho)
                morpho = mfuncs.beach_volume(dist_cross, elev_cross, morpho)
                morpho = mfuncs.profile_volume(dist_cross, elev_cross, morpho)

                # Calculate the profile bearing from heel to MHW
                morpho = mfuncs.orientation(morpho, dist_cross, lats, lons)

                # Plot the profile
                pfuncs.plot_profile(morpho, dist_cross, elev_cross, location,
                                    year, profile, mhw, save=True)

            # Convert morpho to a DataFrame
            df = pd.DataFrame.from_dict(morpho)

            # Calculate metrics that can be done without
            # looping through the profiles
            df['Dune Height'] = df['YCrest'] - df['YToe']
            df['Dune Width'] = df['XToe'] - df['XHeel']
            df['Dune Aspect Ratio'] = df['Dune Height'] / df['Dune Width']
            df['Dune Face Slope'] = df['Dune Height'] / (df['XToe'] - df['XCrest'])
            df['Beach Width'] = df['XMHW'] - df['XToe']
            df['Beach Slope'] = (df['YToe'] - df['YMHW']) / df['Beach Width']

            # Save the DataFrame
            path = os.path.join('..', f'{location}', f'{year}')
            fname = os.path.join(path, f'Morphometrics for {location} {year}.csv')
            df.to_csv(fname, index=False)

        # Move the .txt file to the location and year sub-folder
        src = os.path.join(DATA_DIR, file)
        dst = os.path.join('..', f'{location}', f'{year}', file)
        shutil.move(src, dst)


if __name__ == '__main__':
    main()
