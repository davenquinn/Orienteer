import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from attitude.orientation import Orientation
from attitude.display.plot import strike_dip, normal, setup_figure
from matplotlib.patches import Polygon
from matplotlib.ticker import FuncFormatter

yloc = plt.MaxNLocator(4)
xloc = plt.MaxNLocator(5)

def func(val, pos):
    return u"{0}\u00b0".format(val)

formatter = FuncFormatter(func)

def error_ellipse(attitude):
    fig, ax = setup_figure(projection=None, figsize=(4,3))
    ax.yaxis.set_major_locator(yloc)
    ax.xaxis.set_major_locator(xloc)
    ax.xaxis.set_major_formatter(formatter)
    ax.yaxis.set_major_formatter(formatter)
    ax.invert_yaxis()

    fit = attitude.pca()
    strike_dip(fit,
        ax=ax,
        levels=[1,2,3],
        alpha=[0.5,0.4,0.3],
        facecolor='red')

    ax.autoscale_view()
    ax.set_ylabel("Dip")
    ax.set_xlabel("Strike")
    return fig

def plot_aligned(attitude):
    """ Plots the residuals of a principal component
        analysis of attiude data.
    """
    A = attitude.aligned_array
    fig, axes = plt.subplots(3,1,
            sharex=True, frameon=False)
    fig.subplots_adjust(hspace=0, wspace=0.1)
    kw = dict(c="#555555", s=40, alpha=0.5)

    #lengths = attitude.pca.singular_values[::-1]
    lengths = (A[:,i].max()-A[:,i].min() for i in range(3))

    titles = (
        "Plan view (axis 2 vs. axis 1)",
        "Long cross-section (axis 3 vs. axis 1)",
        "Short cross-section (axis 3 vs. axis 2)")

    for title,ax,(a,b) in zip(titles,axes,
            [(0,1),(0,2),(1,2)]):
        ax.scatter(A[:,a], A[:,b], **kw)
        ax.set_aspect("equal")
        ax.text(0,1,title,
            verticalalignment='top',
            transform=ax.transAxes)
        ax.autoscale(tight=True)
        ax.yaxis.set_ticks([])
        for spine in ax.spines.itervalues():
            spine.set_visible(False)
    ax.set_xlabel("Meters")
    return fig

def plot_residuals(attitude):
    rotated = attitude.aligned_array
    arr = attitude.array

    fig = plt.figure(figsize=(5,3.5))
    ax = fig.add_axes([0,0,1,1], frameon=False)

    sc = ax.scatter(arr[:,0]-arr[:,0].min(),arr[:,1]-arr[:,1].min(),
        c=rotated[:,2],
        cmap=matplotlib.cm.coolwarm,
        marker="h",
        s=500,
        edgecolor='black',
        linewidth=0,
        vmin=-2,
        vmax=2)

    cbar = plt.colorbar(sc, shrink=0.9, ticks=[-2,2])

    cbar.ax.set_ylabel('Deviation from planar (m)', rotation=270)

    ax.set_aspect('equal', 'datalim')
    ax.set_xlabel("Meters")
    ax.get_yaxis().set_visible(False)

    lengths = (rotated[:,i].max()-rotated[:,i].min() for i in range(3))

    ax.set_title("Spread along principal axes: "+", ".join(["{0:.1f} m".format(i)
        for i in lengths]))

    return fig
