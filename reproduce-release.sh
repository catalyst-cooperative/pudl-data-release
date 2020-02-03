#!/bin/bash
# A script to generate a reproducible data release locally.
# Assumes:
#  - A Unix-like OS
#  - libsnappy is installed
#  - miniconda is installed in ~/miniconda3
#  - Should be run from a fresh directory containing only:
#    - this script
#    - the pudl-data-release-environment.yml conda environment file
#    - the pudl-data-release-settings.yml PUDL settings file

PUDL_VERSION=0.3.0
START_TIME=$(date --iso-8601="seconds")
EIA860_YEARS="--years 2011 2012 2013 2014 2015 2016 2017 2018"
EIA923_YEARS="--years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
# Default -- with no args -- is to load all available data:
EPACEMS_YEARS=""
#EPACEMS_YEARS="--years 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
#EPACEMS_STATES="--states ID"
EPACEMS_STATES=""
#FERC1_YEARS1="--years 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018"
FERC1_YEARS1=""
###############################################################################
# libsnappy needs to be installed for data validation since tox uses pip
###############################################################################
# sudo apt install libsnappy-dev libsnappy1v5

###############################################################################
# If conda isn't installed on your system, you can install it like this:
###############################################################################
#wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
#bash ~/miniconda.sh -b -p ~/miniconda3

###############################################################################
# Create, activate, and record the pudl-data-release conda environment
###############################################################################
echo "======================================================================"
echo $START_TIME
echo "Creating and archiving PUDL conda environment"
echo "======================================================================"
~/miniconda3/bin/conda init bash
export PATH=~/miniconda3/bin:$PATH
eval "$(~/miniconda3/bin/conda shell.bash hook)"
source ~/miniconda3/etc/profile.d/conda.sh
~/miniconda3/bin/conda env remove --name reproduce-pudl-data-release
~/miniconda3/bin/conda config --set channel_priority strict
~/miniconda3/bin/conda env create \
    --name reproduce-pudl-data-release \
    --file reproduce-environment.yml
source activate reproduce-pudl-data-release

ACTIVE_CONDA_ENV=$(conda env list | grep '\*' | awk '{print $1}')
echo "Active conda env: $ACTIVE_CONDA_ENV"

echo "======================================================================"
date --iso-8601="seconds"
echo "Setting up PUDL data management environment."
echo "======================================================================"
pudl_setup --clobber ./

echo "======================================================================"
date --iso-8601="seconds"
echo "Unzipping archived input data."
echo "======================================================================"
tar -xzf pudl-input-data.tgz

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
END_TIME=$(date --iso-8601="seconds")
echo "PUDL data release re-creation and validation complete."
echo "START TIME:" $START_TIME
echo "END TIME:  " $END_TIME
echo "======================================================================"
