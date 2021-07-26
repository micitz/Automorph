"""
Functions to make figures while Automorph runs

Michael Itzkin, 6/28/2021
"""


import matplotlib.pyplot as plt
import numpy as np
import os


# General plot parameters
font = {'fontname': 'Arial', 'fontsize': 14, 'fontweight': 'normal'}
inches = 3.8
dpi = 300


"""
Functions to assist in figure making
"""


def save_figure(title, figure, location, year, save):
    """
    Save and close the figure. Add a
    transparent background first

    title: String with the figure title
    figure: Figure object to save
    location: String with the profile location
    year: String with the year of the data
    save: Bool to save the figure (True) or display it (False)
    """

    if save:

        # Set the figure directory
        FIG_DIR = os.path.join('..', f'{location}', f'{year}', 'Figures')

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
Functions to make figures
"""


def plot_profile(morpho, x, y, location, year, profile, mhw, save=True):
    """
    Plot the profile with the morphometrics annotated on it

    morpho: Dict with the morphometrics
    x: X-Values for plotting
    y: Y-Values for plotting
    location: String with the profile location
    year: String with the year of the profile
    profile: Int with the profile number
    save: Display the figure (False) or save and close it (True)
    """

    # Setup the figure
    fig, ax = plt.subplots(figsize=(inches * 2, inches), dpi=dpi)
    title = f'{location} {year} {profile}'
    morphos = ['MHW', 'Toe', 'Crest', 'Heel']
    colors = ['Yellow', 'Blue', 'Magenta', 'Green']

    # Add a grid
    ax.grid(color='lightgrey', linewidth=0.5, zorder=0)

    # Plot the profile
    ax.fill_between(x, mhw, y2=-5, facecolors='cornflowerblue', zorder=2)
    ax.fill_between(x, y, y2=-5, facecolors='#c2b280', zorder=4)

    # Plot the metrics
    for mm, cc in zip(morphos, colors):
        ax.scatter(x=morpho[f'X{mm}'][-1],
                   y=morpho[f'Y{mm}'][-1],
                   facecolors=cc,
                   edgecolors='black',
                   linewidths=1,
                   zorder=6,
                   label=mm)

    # Add a legend
    ax.legend(loc='upper right', fancybox=False, edgecolor='black')

    # Set the X-Axis
    ax.set_xlim(left=0, right=np.nanmax(x))
    ax.set_xlabel('Cross-Shore Distance (m)', **font)

    # Set the Y-Axis
    ax.set_ylim(bottom=np.floor(np.nanmin(y)), top=np.ceil(np.nanmax(y)) + 2)
    ax.set_ylabel('Elevation (m NAVD88)', **font)

    # Save and close the figure
    save_figure(title, fig, location, year, save)

