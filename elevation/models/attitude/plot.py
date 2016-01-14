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
