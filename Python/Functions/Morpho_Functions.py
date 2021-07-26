"""
Functions to extract morphology from profiles with Automorph

Michael Itzkin, 6/29/2021
"""

from sklearn.linear_model import LinearRegression
from scipy import signal, stats

import matplotlib.pyplot as plt
import numpy as np
import copy


"""
Functions to help identify various morphometrics
"""


def getPairStats(x, y):
    """
    https://towardsdatascience.com/how-to-perform-linear-regression
        -with-confidence-5ed8fc0bb9fe
    """

    # get number of entries
    n = len(x)

    # calculate sums
    x_sum = np.sum(x)
    x_sum_square = np.sum([xi ** 2 for xi in x])
    y_sum = np.sum(y)
    y_sum_square = np.sum([yi ** 2 for yi in y])
    xy_sum = np.sum([xi * yi for xi, yi in zip(x, y)])

    # calculcate remainder of equations
    s_xx = x_sum_square - (1 / n) * (x_sum ** 2)
    s_yy = y_sum_square - (1 / n) * (y_sum ** 2)
    s_xy = xy_sum - (1 / n) * x_sum * y_sum

    return s_xx, s_yy, s_xy


def store_morpho(idx, col, morpho, X, y, lats, lons, replace=False):
    """
    Place the morphometric values into the dict

    idx: Index for the metric location
    col: String with the morphometric name
    morpho: Dict with morphometrics
    X: Array with the cross-shore distance values
    y: Array with the elevation values
    lats: Array with the latitudes for the profile points
    lons: Array with the longitudes for the profile points
    """
    if replace:
        morpho[f'X{col}'][-1] = X[idx]
        morpho[f'Y{col}'][-1] = y[idx]
        morpho[f'{col} Lat'][-1] = lats[idx]
        morpho[f'{col} Lon'][-1] = lons[idx]
    else:
        morpho[f'X{col}'].append(X[idx])
        morpho[f'Y{col}'].append(y[idx])
        morpho[f'{col} Lat'].append(lats[idx])
        morpho[f'{col} Lon'].append(lons[idx])

    return morpho


"""
Functions to identify key morphometrics
"""


def beach_volume(X, y, morpho):
    """
    Calculate the beach volume

    X: Array of cross-shore distance values
    y: Array of the upper-elevation values
    morpho: Dict with morphometric values
    """

    # Find the mhw and toe indices
    if morpho['XMHW'][-1] < 9999:
        mhw_ix = np.argwhere(X == morpho['XMHW'][-1])[0][0]
    else:
        mhw_ix = 0
    toe_ix = np.argwhere(X == morpho['XToe'][-1])[0][0]

    # Set a base elevation based on whichever is
    # lower; the toe or heel
    if y[mhw_ix] > y[toe_ix]:
        base = y[toe_ix]
    else:
        base = y[mhw_ix]

    # Make a fake profile with values between the
    # toe and the heel set to the base
    fake_profile = copy.deepcopy(y)
    fake_profile[mhw_ix:toe_ix] = base

    # Integrate over the full profile and
    # the fake profile
    profile_vol = -np.trapz(y, X)
    fake_vol = -np.trapz(fake_profile, X)
    dune_vol = profile_vol - fake_vol

    # Put the dune volume in the morpho dict
    morpho['Beach Volume'].append(dune_vol)

    return morpho


def dune_volume(X, y, morpho):
    """
    Calculate the dune volume

    X: Array of cross-shore distance values
    y: Array of the upper-elevation values
    morpho: Dict with morphometric values
    """

    # Find the toe and heel indices
    toe_ix = np.argwhere(X == morpho['XToe'][-1])[0][0]
    heel_ix = np.argwhere(X == morpho['XHeel'][-1])[0][0]

    # Set a base elevation based on whichever is
    # lower; the toe or heel
    if y[toe_ix] > y[heel_ix]:
        base = y[heel_ix]
    else:
        base = y[toe_ix]

    # Make a fake profile with values between the
    # toe and the heel set to the base
    fake_profile = copy.deepcopy(y)
    fake_profile[toe_ix:heel_ix] = base

    # Integrate over the full profile and
    # the fake profile
    profile_vol = -np.trapz(y, X)
    fake_vol = -np.trapz(fake_profile, X)
    dune_vol = profile_vol - fake_vol

    # Put the dune volume in the morpho dict
    morpho['Dune Volume'].append(dune_vol)

    return morpho


def profile_volume(X, y, morpho):
    """
    Calculate the volume of the profile above mhw

    X: Array of cross-shore distance values
    y: Array of the upper-elevation values
    morpho: Dict with morphometric values
    """

    # Set the base elevation to mhw
    base = morpho['YMHW'][-1]

    # Make a fake profile with values between the
    # toe and the heel set to the base
    fake_profile = copy.deepcopy(y)
    fake_profile[fake_profile > base] = base

    # Integrate over the full profile and
    # the fake profile
    profile_vol = -np.trapz(y, X)
    fake_vol = -np.trapz(fake_profile, X)
    dune_vol = profile_vol - fake_vol

    # Put the dune volume in the morpho dict
    morpho['Profile Volume'].append(dune_vol)

    return morpho


def find_crest(morpho, X, y, lats, lons, mhw, threshold=0.6, crest_pct=0.2):
    """
    Identify the dune crest on the profile using the method
    from Mull and Ruggiero (2014) where the crest is identified
    as having a "backshore drop" of some vertical distance (0.6 m
    in the paper)

    morpho: Dict with morphometrics
    X: Array with the cross-shore distance values
    y: Array with the elevation values
    lats: Array with the latitudes for the profile points
    lons: Array with the longitudes for the profile points
    mhw: Float with the MHW level
    threshold: Float with the minimum rest-to-heel
               elevation distance (Default = 0.6 m)
    crest_pct: Float to check if a more seaward peak might be more appropriate
    """

    # Find peaks on the profile. The indices increase landwards
    pks_idx, _ = signal.find_peaks(y)

    # Remove peaks below MHW
    if len(pks_idx) > 0:
        pks_idx = pks_idx[y[pks_idx] > mhw]

    # If there aren't any peaks just take the maximum value
    if len(pks_idx) == 0:
        idx = np.argmax(y)

    else:

        # Loop through the peaks
        for idx in pks_idx:
            backshore_drop = 0

            # Set the current peak elevation
            curr_elevation = y[idx]

            # Loop landwards across the profile
            check_idx = idx
            while check_idx < len(y):

                # Check that the next landward point is lower
                if check_idx + 1 >= len(y):
                    break
                elif y[check_idx + 1] > y[idx]:
                    break
                else:

                    # Check the elevation distance
                    check_elevation = y[check_idx + 1]
                    backshore_drop = curr_elevation - check_elevation
                    if backshore_drop >= threshold:
                        break
                    else:
                        check_idx += 1

            if backshore_drop >= threshold:

                # Check the seaward peaks
                lo = y[idx] * (1 - crest_pct)
                pks_idx = pks_idx[y[pks_idx] > lo]
                if len(pks_idx) > 0:
                    idx = pks_idx[0]
                break

    # Put the crest into the DataFrame
    morpho = store_morpho(idx, 'Crest', morpho, X, y, lats, lons)

    return morpho


def find_heel(morpho, X, y, lats, lons, threshold=0.6):
    """
    Find the dune heel on the profile

    morpho: Dict with morphometrics
    X: Array with the cross-shore distance values
    y: Array with the elevation values
    lats: Array with the latitudes for the profile points
    lons: Array with the longitudes for the profile points
    threshold: Float with the minimum rest-to-heel
               elevation distance (Default = 0.6 m)
    """

    # Find the crest position
    crest_idx = np.argwhere(X == morpho['XCrest'][-1])[0][0]

    # If the crest is the last "index" then
    # just set the heel to equal the crest
    if crest_idx >= len(X) - 1:
        morpho['XHeel'].append(morpho['XCrest'][-1])
        morpho['YHeel'].append(morpho['YCrest'][-1])
        morpho['Heel Lat'].append(morpho['Crest Lat'][-1])
        morpho['Heel Lon'].append(morpho['Crest Lon'][-1])

    # Find the heel
    else:

        # Loop landward from the crest
        idx = crest_idx
        while idx < len(X):

            # Check the elevation difference
            elevation_difference = y[crest_idx] - y[idx]
            if idx + 1 >= len(X):
                break
            elif y[idx + 1] < y[idx]:
                idx += 1
            elif elevation_difference >= threshold:
                break
            elif y[idx + 1] * 0.95 >= y[idx]:
                break
            else:
                idx += 1

        # Store the heel position
        morpho = store_morpho(idx, 'Heel', morpho, X, y, lats, lons)

        # The crest may need to be re-adjusted here so set the crest
        # equal to the tallest point between the heel and the current
        # crest position
        new_crest_idx = np.argmax(y[crest_idx:idx]) + crest_idx
        morpho = store_morpho(new_crest_idx, 'Crest', morpho,
                              X, y, lats, lons, replace=True)

    return morpho


def find_mhw(morpho, X, y, lats, lons, mhw, pad=0.5):
    """
    Identify the MHW contour on the profile using a regression
    of points around the MHW contour. Keep performing regressions
    until a quality result is produced.

    Calculate positional uncertainty using the method
    from Hapke et al. (2013)

    The same method of finding the foreshore slope is used to perform the
    regression here (i.e., regressing through points within 0.5m of MHW). So
    return the slope of the regression performed while the pad is still set to
    0.5 to use as the foreshore slope for the profile

    morpho: Dict to store the morphometrics in
    X: Cross-shore distance values for the profile
    y: Elevation values for the profile
    lats: Array of latitudes for the profile
    lons: Array of longitudes for the profile
    mhw: Float with the MHW elevation for the profile
    pad: Float with the distance (+/-) around MHW to regress on (Default: 0.5)
    """

    # Pull out all points within the pad distance of MHW. The landward
    # end of some profiles fall into the right elevation range but should
    # not be included in this analysis. Mask out points in the back half
    # of the profile to correct for this
    lo, hi = mhw - pad, mhw + pad
    mask = (y >= lo) & (y <= hi) & (X > X.max()/2)
    X_use, y_use = X[mask], y[mask]
    n = len(X_use)

    # Check that y_use is long enough
    if n > 0:

        # Find the observed shoreline position
        y_search = np.abs(y_use - mhw)
        observed_mhw_ix = np.argmin(y_search)
        observed_x_mhw = X_use[observed_mhw_ix]
        observed_y_mhw = y_use[observed_mhw_ix]
        mhw_lat = lats[observed_mhw_ix]
        mhw_lon = lons[observed_mhw_ix]

        # Peform a linear regression on the X_use and y_use arrays
        reg = LinearRegression().fit(X_use.reshape(-1, 1), y_use.reshape(-1, 1))
        m = reg.coef_[0][0]
        b = reg.intercept_[0]

        # Find the X-Value where the regression slope equals MHW
        x_mhw = (mhw - b) / m

        # Multiply by negative 1 tomake the slope positive for convention
        # for use as the foreshore slope
        foreshore_slope = -m

        # Calculate the score
        score = reg.score(X_use.reshape(-1, 1), y_use)

    else:
        b = 9999
        foreshore_slope = 9999
        observed_x_mhw = 9999
        observed_y_mhw = 9999
        mhw_lat = 9999
        mhw_lon = 9999

    if n == 0:

        x_mhw = np.nan
        interval_val = np.nan
        horizontal_uncertainty = np.nan
        extrapolation_error = np.nan
        mhw_error = np.nan

    else:

        # Calculate the 95% confidence interval of the regression
        s_xx, s_yy, s_xy = getPairStats(X_use, y_use)
        sigma_hat = np.sqrt((1 / n) * (s_yy - m * s_xy))
        t_limit = stats.t.ppf(1 - 0.05 / 2, n - 2)
        interval_val = t_limit * sigma_hat * np.sqrt(n / ((n - 2) * s_xx))

        # Calculate the horizontal uncertainty assuming a 0.15m vertical error
        horizontal_uncertainty = m * 0.15

        # Find the distance between the observed and predicted MHW position
        extrapolation_error = observed_x_mhw - x_mhw

        # Sum the three error sources in quadrature to calculate the positional
        # uncertainty of the MHW position
        mhw_error = np.sqrt((interval_val**2) +
                            (horizontal_uncertainty**2) +
                            (extrapolation_error**2))

    # Store the values in the morpho dict
    morpho['XMHW'].append(observed_x_mhw)
    morpho['YMHW'].append(observed_y_mhw)
    morpho['MHW Lon'].append(mhw_lon)
    morpho['MHW Lat'].append(mhw_lat)
    morpho['MHW CI'].append(interval_val)
    morpho['MHW Lidar Error'].append(horizontal_uncertainty)
    morpho['MHW X Error'].append(extrapolation_error)
    morpho['MHW Error'].append(mhw_error)
    morpho['Foreshore Slope'].append(foreshore_slope)

    return morpho


def find_toe(morpho, X, y, lats, lons):
    """
    Find the dune toe on the profile using the stretched
    sheet method from Mitasova et al. (2011)

    morpho: Dict with morphometrics
    X: Array with the cross-shore distance values
    y: Array with the elevation values
    lats: Array with the latitudes for the profile points
    lons: Array with the longitudes for the profile points
    """

    # Get the crest and MHW indices
    crest_idx = np.argwhere(X == morpho['XCrest'][-1])[0][0]
    if morpho['XMHW'][-1] < 9999:
        mhw_idx = np.argwhere(X == morpho['XMHW'][-1])[0][0]
    else:
        mhw_idx = 1

    # Make a copy of the profile with a straight
    # line from the MHW to Crest positions
    y_copy = copy.deepcopy(y)
    y_copy[mhw_idx:crest_idx] = np.linspace(start=morpho['YMHW'][-1],
                                            stop=morpho['YCrest'][-1],
                                            num=crest_idx - mhw_idx)

    # Subtract the copy from the original profile and idenitfy
    # the maximum point
    y_diff = y_copy - y
    toe_idx = np.argmax(y_diff)

    # Store the toe location
    morpho = store_morpho(toe_idx, 'Toe', morpho, X, y, lats, lons)

    return morpho


def orientation(morpho, X, lats, lons):
    """
    Calculate the profile bearing pointing seawards

    Modified from:
    https://towardsdatascience.com/calculating-the-bearing-between-two-geospatial-coordinates-66203f57e4b4

    morpho: Dict with morphmetric values
    X: Array with the cross-shore distance values
    lats: Array with latitude values
    lons: Array with longitude values
    """

    # Get the heel and MHW indices
    if morpho['XMHW'][-1] < 9999:
        mhw_ix = np.argwhere(X == morpho['XMHW'][-1])[0][0]
    else:
        mhw_ix = 0
    heel_ix = np.argwhere(X == morpho['XHeel'][-1])[0][0]

    # Grab the starting and ending points
    a = {'lat': lons[heel_ix], 'lon': lats[heel_ix]}
    b = {'lat': lons[mhw_ix], 'lon': lats[mhw_ix]}

    # Calculate the change in longitude
    dl = b['lon'] - a['lon']

    # Calculate X and Y
    X = np.cos(b['lat']) * np.sin(dl)
    y = np.cos(a['lat']) * np.sin(b['lat']) - np.sin(a['lat']) * np.cos(b['lat']) * np.cos(dl)

    # Get the bearing and convert to degrees
    bearing = (np.arctan2(X, y) * (180 / np.pi)) % 360
    morpho['Orientation'].append(bearing)

    return morpho