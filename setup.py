from setuptools import setup, find_packages

install_requires = [
    'numpy',
    'scipy',
    'fiona',
    'shapely',
    'rasterio',
    'flask',
    'sqlalchemy',
    'pyproj',
    'mplstereonet',
    'gunicorn',
    'pg-projector',
    'Flask-SQLAlchemy'
    ]

setup(
    name='orienteer',
    version=0.1,
    description="""
        The 'elevation' module provides a frontend for
        analysis of bedding attitude data.""",
    license='MIT',
    install_requires=install_requires,
    packages=find_packages(),
    package_dir={'orienteer':'elevation',
                 'attitude': 'bundled-deps/Attitude/attitude',
                 'pg_projector': 'bundled-deps/pg-projector/pg_projector'},
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Science/Research',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Scientific/Engineering :: GIS',
    ],
)
