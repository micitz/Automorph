"""
Analyze morphometrics identified from running Automorph

Michael Itzkin, 7/2/2021
"""


import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
import os


# General plot parameters
font = {'fontname': 'Arial', 'fontsize': 14, 'fontweight': 'normal'}
inches = 3.8
dpi = 300


"""
Functions to load and format data
"""


def load_morphometrics(loc, years):
    """
    Load all of the morphometrics into a single DataFrame

    loc: String with the data location
    years: List of ints with years of available data
    """

    # Set a generic component of the path to the data
    path = os.path.join('..', loc)

    # Create a blank DataFrame
    df = pd.DataFrame()

    # Loop through the years
    for yy in years:

        # Load the data and add a column with the year and
        # append it to the main DataFrame
        fname = os.path.join(path, f'{yy}', f'Morphometrics for {loc} {yy}.csv')
        temp_df = pd.read_csv(fname, header=0, delimiter=',')
        temp_df['Year'] = yy
        df = pd.concat([df, temp_df])

    return df


"""
Functions to make figures
"""


def annual_boxplots(df, metric, ylabel, yhi, ylo=0, save=False):
    """
    Make a boxplot showing the annual evolution of some metric

    df: DataFrame with the morphometrics
    metric: String with the column name of the metric to look at
    ylabel: String with the Y-Axis label
    yhi: Y-Axis upper limit
    ylo: Y-AXis lower limit
    save: Display the data (False) or close and save the figure (True)
    """

    # Setup the figure
    fig, ax = plt.subplots(figsize=(inches * 2, inches), dpi=dpi)

    # Plot the data
    sns.boxplot(x='Year', y=metric, data=df, ax=ax)

    # iterate over boxes
    for i, box in enumerate(ax.artists):
        box.set_edgecolor('black')
        box.set_facecolor('white')

        # iterate over whiskers and median lines
        for j in range(6 * i, 6 * (i + 1)):
            ax.lines[j].set_color('black')

    # Set the X-Axis
    ax.set_xlabel('')

    # Set the Y-Axis
    ax.set_ylim(ylo, yhi)
    ax.set_ylabel(ylabel, **font)

    # Save and close the figure
    title = f'Annual {metric} Boxplot'
    save_figure(title, fig, save)


def save_figure(title, figure, save):
    """
    Save and close the figure. Add a
    transparent background first

    title: String with the figure title
    figure: Figure object to save
    save: Bool to save the figure (True) or display it (False)
    """

    if save:

        # Set a tight and transparent background
        plt.tight_layout()
        figure.patch.set_color('w')
        figure.patch.set_alpha(0.0)

        # Set the save directory
        title_w_extension = os.path.join(FIG_DIR, f'{title}.png')

        # Save the figure and print out a notification
        plt.savefig(title_w_extension,
                    bbox_inches='tight',
                    facecolor=figure.get_facecolor(),
                    dpi='figure')
        print(f'Figure Saved: {title_w_extension}')

        # Close the figure
        plt.close()

    else:
        plt.show()


"""
Run the analysis
"""


def main():
    """
    Run the analysis
    """

    # Set parameters
    num_profiles = 50
    location = 'Nags_Head_A'
    years = [1998, 1999, 2001, 2004, 2005, 2008, 2009, 2012,
             2013, 2014, 2015, 2016, 2017, 2018, 2019]

    # Make a folder for the results
    global FIG_DIR
    FIG_DIR = os.path.join('..', f'{location}', 'Figures')
    if not os.path.exists(FIG_DIR):
        os.makedirs(FIG_DIR)

    # Load the morphometrics into a single DataFrame
    df = load_morphometrics(location, years)

    # Plot the profiles on a Basemap

    # Plot overlays of the profiles for all years

    # Make boxplots of the metrics by year
    annual_boxplots(df, 'YCrest', 'D$_{high}$ (m NAVD88)', 15, save=True)
    annual_boxplots(df, 'Dune Volume', 'Dune Volume (m$^{3}$/m)', 300, save=True)
    annual_boxplots(df, 'Beach Width', 'Beach Width', 300, save=True)

    # Make yearly alongshore plots of the metrics
    sns.scatterplot(x='Beach Width', y='YCrest', data=df)
    plt.show()



if __name__ == '__main__':
    main()
