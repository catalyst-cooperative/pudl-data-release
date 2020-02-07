#!/bin/bash
# A script to generate a reproducible data release locally.
# Assumes:
#  - A Unix-like OS
#  - libsnappy is installed
#  - conda is installed
#  - Environment variable $CONDA_EXE is path to conda
#  - Should be run from within a fresh git clone:
#    https://github.com/catalyst-cooperative/pudl-data-release.git

PUDL_VERSION=0.3.1
START_TIME=$(date --iso-8601="seconds")
EIA860_YEARS="--years 2011 2012 2013 2014 2015 2016 2017 2018"
EIA923_YEARS="--years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
# Default (with no args) is to load all available data:
EPACEMS_YEARS=""
EPACEMS_STATES=""
FERC1_YEARS1=""

###############################################################################
# Create, activate, and record the pudl-data-release conda environment
###############################################################################
echo "======================================================================"
echo $START_TIME
echo "Creating and archiving PUDL conda environment"
echo "======================================================================"
$CONDA_EXE init bash
eval "$($CONDA_EXE shell.bash hook)"
$CONDA_EXE env remove --name pudl-data-release
$CONDA_EXE create --yes --name pudl-data-release \
    --strict-channel-priority --channel conda-forge \
    python=3.7 pip git catalystcoop.pudl=$PUDL_VERSION
source activate pudl-data-release

ACTIVE_CONDA_ENV=$($CONDA_EXE env list | grep '\*' | awk '{print $1}')
echo "Active conda env: $ACTIVE_CONDA_ENV"

# Record exactly which software was installed for ETL:
$CONDA_EXE env export --no-build | grep -v "^prefix" > archived-environment.yml

echo "======================================================================"
date --iso-8601="seconds"
echo "Setting up PUDL data management environment."
echo "======================================================================"
pudl_setup --clobber ./

echo "======================================================================"
date --iso-8601="seconds"
echo "Downloading raw input data."
echo "======================================================================"
pudl_data --sources epacems $EPACEMS_STATES $EPACEMS_YEARS
pudl_data --sources eia860 $EIA860_YEARS
pudl_data --sources eia923 $EIA923_YEARS
pudl_data --sources ferc1 $FERC1_YEARS

echo "======================================================================"
date --iso-8601="seconds"
echo "Cloning FERC Form 1 into SQLite."
echo "======================================================================"
ferc1_to_sqlite --clobber data-release-settings.yml

echo "======================================================================"
date --iso-8601="seconds"
echo "Running PUDL ETL"
echo "======================================================================"
pudl_etl --clobber data-release-settings.yml

echo "======================================================================"
date --iso-8601="seconds"
echo "Archiving raw input data for distribution."
echo "======================================================================"
mkdir zenodo-archive
tar -czf zenodo-archive/pudl-input-data.tgz data/

echo "======================================================================"
date --iso-8601="seconds"
echo "Archiving PUDL datapackages for distribution."
echo "======================================================================"
tar -czf zenodo-archive/pudl-ferc1.tgz \
    datapkg/pudl-data-release/pudl-ferc1/

tar -czf zenodo-archive/pudl-eia860-eia923.tgz \
    datapkg/pudl-data-release/pudl-eia860-eia923/

tar -czf zenodo-archive/pudl-eia860-eia923-epacems.tgz \
    datapkg/pudl-data-release/pudl-eia860-eia923-epacems/

cp data-release.sh \
    reproduce-data-release.sh \
    data-release-settings.yml \
    archived-environment.yml \
    README.md \
    zenodo-archive

echo "======================================================================"
date --iso-8601="seconds"
echo "Loading FERC 1 & EIA 860/923 data into SQLite for validation."
echo "======================================================================"
# Load the FERC 1 and EIA datapackages into an SQLite DB:
datapkg_to_sqlite --clobber \
    datapkg/pudl-data-release/pudl-ferc1/datapackage.json \
    datapkg/pudl-data-release/pudl-eia860-eia923/datapackage.json \
    -o datapkg/pudl-data-release/pudl-merged/

# The CEMS is too large to usefully put into SQLite, so convert to Parquet.
# Note that we are not currently doing detailed validation of the CEMS data,
# but this conversion process will at least catch data type issues.
echo "======================================================================"
date --iso-8601="seconds"
echo "Converting EPA CEMS data to Apache Parquet for validation."
echo "======================================================================"
epacems_to_parquet --clobber $EPACEMS_YEARS $EPACEMS_STATES -- \
    datapkg/pudl-data-release/pudl-eia860-eia923-epacems/datapackage.json

echo "======================================================================"
date --iso-8601="seconds"
echo "Install packages required for data validation but not ETL."
echo "======================================================================"
# Obtain and install the most recent PUDL commit (or the tagged release...):
$CONDA_EXE install --yes pytest tox
rm -rf pudl
git clone --depth 1 --branch v$PUDL_VERSION \
    https://github.com/catalyst-cooperative/pudl.git
pip install --editable ./pudl

# Validate the data we've loaded
# Only want to do this when we're processing all the FERC 1 & EIA data...
echo "======================================================================"
date --iso-8601="seconds"
echo "Using Tox to validate PUDL data before release."
echo "======================================================================"
tox -v -c pudl/tox.ini -e validate

echo "======================================================================"
END_TIME=$(date --iso-8601="seconds")
ARCHIVE_SIZE=$(du -sh zenodo-archive)
echo "PUDL data release creation and validation complete."
echo "START TIME:" $START_TIME
echo "END TIME:  " $END_TIME
echo "Archive Size:" $ARCHIVE_SIZE
echo "======================================================================"
cp data-release.log zenodo-archive
