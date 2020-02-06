#!/bin/bash

# This is some setup required to make conda work in a shell script.  If you
# wanted to run the commands below in the terminal it wouldn't be needed
$CONDA_EXE init bash
eval "$($CONDA_EXE shell.bash hook)"

# Remove any existing pudl conda environment, just to make sure we're clean:
$CONDA_EXE env remove --name pudl

# Create a minimal new conda environment for PUDL to work within. Important
# that the version of catalystcoop.pudl match the one used to generate the
# data release... otherwise it probably won't work:
$CONDA_EXE create --yes --name pudl --channel conda-forge \
    --strict-channel-priority python=3.7 \
    catalystcoop.pudl=0.3.1 dask jupyter jupyterlab seaborn pip git
source activate pudl

# Create a new PUDL data management environment here, clobbering your existing
# settings saying where PUDL lives... just in case. Note that you'll have to
# manually edit your ~/.pudl.yml file to go back to your normal workspace:
pudl_setup --clobber ./

# Extract the distributed data packages:
tar -xzf pudl-ferc1.tgz
tar -xzf pudl-eia860-eia923.tgz
tar -xzf pudl-eia860-eia923-epacems.tgz

# Load the FERC Form 1, and EIA Forms 860/923 into SQLite:
datapkg_to_sqlite \
    datapkg/pudl-data-release/pudl-ferc1/datapackage.json \
    datapkg/pudl-data-release/pudl-eia860-eia923/datapackage.json \
    -o datapkg/pudl-data-release/pudl-merged/

# Convert the EPA CEMS Hourly Emissions tables into an Apache Parquet dataset
# that is partitioned by year and state.
EPACEMS_STATES=""
#EPACEMS_STATES="--states ID"
epacems_to_parquet $EPACEMS_STATES -- \
    datapkg/pudl-data-release/pudl-eia860-eia923-epacems/datapackage.json

# Generate the entire raw FERC Form 1 database, which contains far more FERC
# data than what has been integrated into PUDL:
tar -xzf pudl-input-data.tgz
ferc1_to_sqlite data-release-settings.yml
