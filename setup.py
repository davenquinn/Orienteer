from setuptools import setup, find_packages

install_requires = [
    'numpy',
    'scipy',
    'fiona',
    'shapely',
    'rasterio',
    'gdal',
    'flask',
    'sqlalchemy',
    'pyproj',
    'mplstereonet'
    ]

setup(
    name='elevation',
    version=0.1,
    description="""
        The 'elevation' module provides a frontend for
        analysis of bedding attitude data.""",
    license='MIT',
    install_requires=install_requires,
    packages=find_packages(),
    package_dir={'elevation':'elevation'},
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Science/Research',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Scientific/Engineering :: GIS',
    ],
)
