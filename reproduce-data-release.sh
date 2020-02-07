#!/bin/bash

###############################################################################
# Create, activate, and record the pudl-data-release conda environment
###############################################################################
START_TIME=$(date --iso-8601="seconds")
echo "======================================================================"
echo $START_TIME
echo "Creating and archiving PUDL conda environment"
echo "======================================================================"
$CONDA_EXE init bash
eval "$($CONDA_EXE shell.bash hook)"
$CONDA_EXE env remove --name reproduce-pudl-data-release
$CONDA_EXE config --set channel_priority strict
$CONDA_EXE env create \
    --name reproduce-pudl-data-release \
    --file archived-environment.yml
source activate reproduce-pudl-data-release

ACTIVE_CONDA_ENV=$($CONDA_EXE env list | grep '\*' | awk '{print $1}')
echo "Active conda env: $ACTIVE_CONDA_ENV"

echo "======================================================================"
date --iso-8601="seconds"
echo "Setting up PUDL data management environment."
echo "======================================================================"
pudl_setup --clobber ./

echo "======================================================================"
date --iso-8601="seconds"
echo "Extracting archived input data."
echo "======================================================================"
tar -xzf pudl-input-data.tgz

echo "======================================================================"
date --iso-8601="seconds"
echo "Cloning FERC Form 1 into SQLite."
echo "======================================================================"
ferc1_to_sqlite --clobber data-release-settings.yml

echo "======================================================================"
date --iso-8601="seconds"
echo "Running PUDL ETL to generate data packages."
echo "======================================================================"
pudl_etl --clobber data-release-settings.yml

echo "======================================================================"
END_TIME=$(date --iso-8601="seconds")
echo "PUDL data release re-creation complete."
echo "START TIME:" $START_TIME
echo "END TIME:  " $END_TIME
echo "======================================================================"
