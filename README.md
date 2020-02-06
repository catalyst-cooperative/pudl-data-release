# PUDL Data Release 1.0.0

This is the first data release from the [Public Utility Data Liberation (PUDL)
project](https://catalyst.coop/pudl). It can be referenced & cited using
https://doi.org/10.5281/zenodo.XXXXXXX.
The most recent release of these data can be found using this concept DOI:
https://doi.org/10.5281/zenodo.XXXXXXX. For more information about the free and
open source software used to generate this data release, see [Catalyst
Cooperative's PUDL repository on
Github](https://github.com/catalyst-cooperative/pudl), and the associated
[documentation on Read The
Docs](https://catalystcoop-pudl.readthedocs.io/en/v0.3.1/). This data release
was generated using v0.3.1 of the `catalystcoop.pudl` python package.

# Included Data Packages
This release consists of three tabular data packages, conforming to the
standards published by [Frictionless Data](https://frictionlessdata.io) and the
[Open Knowledge Foundation](https://okfn.org). The data are stored in CSV files
(some of which are compressed using gzip), and the associated metadata is
stored as JSON. These tabular data can be used to populate a relational
database.

## `pudl-eia860-eia923`
Data originally collected and published by the [US Energy Information
Administration](https://www.eia.gov/) (US EIA). The data from [EIA Form
860](https://www.eia.gov/electricity/data/eia860/)
covers the years 2011-2018. The [Form 923
data](https://www.eia.gov/electricity/data/eia923/) covers 2009-2018. The
overwhelming majority of the data published in the original data sources has
been included, but some parts, like fuel stocks on hand, have not yet been
integrated.

## `pudl-eia860-eia923-epacems`
This data package contains all of the same data as the `pudl-eia860-eia923`
package above, as well as the Hourly Emissions data from the US Environmental
Protection Agency's (EPA's) [Continuous Emissions Monitoring
System](https://www.epa.gov/emc/emc-continuous-emission-monitoring-systems)
(CEMS) from 1995-2018. The EPA CEMS data covers thousands of power plants at
hourly resolution for decades, and contains close to a billion records.

## `pudl-ferc1`
Seven data tables from [FERC Form
1](https://www.ferc.gov/docs-filing/forms/form-1/data.asp) are included,
primarily relating to individual power plants, and covering the years 1994-2018
(the entire span of time for which FERC provides this data).

These tables are the only ones which have been subjected to any cleaning or
organization for programmatic use within PUDL. The complete, raw FERC Form 1
database contains 116 different tables with many thousands of columns of mostly
financial data.  We will archive a complete copy of the multi-year FERC Form 1
Database as a file-based SQLite database at Zenodo, independent of this data
release. It can also be re-generated using the `catalystcoop.pudl` Python
package and the original source data files archived as part of this data
release.

# Using the Data
The data packages are just CSVs (data) and JSON (metadata) files. They can be
used with a variety of tools on many platforms. However, the data is organized
primarily with the idea that it will be loaded into a relational database, and
the PUDL Python package that was used to generate this data release can
facilitate that process. Once the data is loaded into a database, you can
access that DB however you like.

## Make sure conda is installed
None of these commands will work without the `conda` Python package manager
installed, either via Anaconda or `miniconda`:
* [Install Anaconda](https://www.anaconda.com/distribution/)
* [Install miniconda](https://docs.conda.io/en/latest/miniconda.html)

## Download the data
First download the files from the Zenodo archive into a new empty
directory. **A couple of them are very large (5-10 GB)**, and depending on what
you're trying to do you may not need them.
* If you don't want to recreate the data release from scratch by re-running the
  entire ETL process yourself, and you don't want to create full clone of the
  original FERC Form 1 database, including all of the data that has not yet
  been integrated into PUDL, then you don't need to download
  `pudl-input-data.tgz`.
* If you don't need the EPA CEMS Hourly Emissions data, you do not need to
  download `pudl-eia860-eia923-epacems.tgz`.

## Load All of PUDL in a Single Line
Use `cd` to get into your new directory at the terminal (in Linux or Mac OS),
or open up an Anaconda terminal in that directory if you're on Windows.

**If you have downloaded all of the files from the archive**, and you want it
all to be accessible locally, you can run a single shell script, called
`load-pudl.sh`:

```
bash pudl-load.sh
```
This will do the following:
* Load the FERC Form 1, EIA Form 860, and EIA Form 923 data packages into a
SQLite database which can be found at `sqlite/pudl.sqlite`.
* Convert the EPA CEMS data package into an Apache Parquet dataset which can be
  found at `parquet/epacems`.
* Clone all of the FERC Form 1 annual databases into a single SQLite database
  which can be found at `sqlite/ferc1.sqlite`.

## Selectively Load PUDL Data
If you don't want to download and load all of the PUDL data, you can load each
of the above datasets separately.

### Create the PUDL `conda` Environment
This installs the PUDL software locally, and a couple of other useful packages:
```
conda create --yes --name pudl --channel conda-forge \
    --strict-channel-priority \
    python=3.7 catalystcoop.pudl=0.3.1 dask jupyter jupyterlab seaborn pip
conda activate pudl
```
### Create a PUDL data management workspace
Use the PUDL setup script to create a new data management environment inside
this directory. After you run this command you'll see some other directories
show up, like `parquet`, `sqlite`, `data` etc.
```
pudl_setup ./
```
### Extract and load the FERC Form 1 and EIA 860/923 data
If you just want the FERC Form 1 and EIA 860/923 data that has been integrated
into PUDL, you downloaded just `pudl-ferc1.tgz` and `pudl-eia860-eia923.tgz`
and extract them in the same directory where you ran `pudl_setup`:
```
tar -xzf pudl-ferc1.tgz
tar -xzf pudl-eia860-eia923.tgz
```
To make use of the FERC Form 1 and EIA 860/923 data, you'll probably want to
load them into a local database. The `datapkg_to_sqlite` script that comes with
PUDL will do that for you:
```
datapkg_to_sqlite \
    datapkg/pudl-data-release/pudl-ferc1/datapackage.json \
    datapkg/pudl-data-release/pudl-eia860-eia923/datapackage.json \
    -o datapkg/pudl-data-release/pudl-merged/
```

### Extract EPA CEMS and convert to Apache Parquet
If you want to work with the EPA CEMS data, which is much larger, we recommend
converting it to an Apache Parquet dataset with the included
`epacems_to_parquet` script. Then you can read those files into dataframes
directly. In Python you can use the `pandas.DataFrame.read_parquet()` method.
If you need to work with more data than can fit in memory at one time, we
recommend using Dask dataframes. Converting the entire dataset from
datapackages into Apache Parquet may take an hour or more:
```
tar -xzf pudl-eia860-eia923-epacems.tgz
epacems_to_parquet datapkg/pudl-data-release/pudl-eia860-eia923-epacems/datapackage.json
```

### Clone the raw FERC Form 1 Databases
If you want to access the entire set of original, raw FERC Form 1 data (of
which only a small subset has been cleaned and integrated into PUDL) you can
extract the original input data that's part of the Zenodo archive and run the
`ferc1_to_sqlite` script using the same settings file that was used to generate
the data release:
```
tar -xzf pudl-input-data.tgz
ferc1_to_sqlite data-release-settings.yml
```

# Data Quality Control
We have performed basic sanity checks on much but not all of the data compiled
in PUDL to ensure that we identify any major issues we might have introduced
through our processing prior to release. These checks have also identified some
issues in the originally reported data.

## Data Validation Test Cases
We've compiled a collection of data validation test cases which were run
against the data in this release prior to publication. These include:
* For reported values that have a physically constrained valid range of values
  do the vast majority of reported records fall within that valid range? This
  includes quantities like heat content per unit of fuel delivered/consumed,
  the sulfur, ash, moisture, chlorine, and mercury content of coal.
* Do ownership shares of individual generators reported in EIA 860 sum to 100%?
* Are derived IDs that are used to group units of infrastructure together
  internally self consistent? For example, are there ever cases where a
  reported EIA generation unit appears in more than one inferred PUDL
  generation unit?
* For quantities that may not have a physically constrained range of valid
  values, do annual slices of the data at least statistically consistent with
  the historical values reported for that quantity? For example, fuel prices
  per unit delivered and per unit heat content.
* ......
* ......
* ......
* ......
* ......

For the complete details see the `pudl.validate` module and the PyTest routines
organized under `test/validate` in [the PUDL repository on
Github](https://github.com/catalyst-cooperative/pudl). A summary

## Known Issues

### No EIA 860 Data For 2009-2010
Because of differences in formatting, The 2009-2010 EIA 860 data has not yet
been fully integrated into PUDL. However, the EIA 923 data relies heavily on
EIA 860 for detailed information about the utilities, plants, and generators it
references, as well as the boiler-generator mappings. As a result, the entities
which only appear in 2009-2010 may not have as much available detail.

### Consistency of Harvested Entity Attributes
EIA 860 reports the same information about utilities, plants, and generators
over the years. Many of the reported attributes (like a plant's latitude and
longitude...) should be constant over time. We associate these attributes with
the entity ID and store them in one table. However, in some cases the reported
values are not perfectly consistent across all the available years of data.
When that happens, PUDL chooses the most consistently reported value, so long
as at least 70% of the reported values are identical (or very nearly identical
in the case of numeric values). If the reported values are too inconsistent,
the field is assigned N/A for that entity.

### Incomplete Boiler Generator Associations for Gas Plants
Prior to 2015, EIA did not collect sufficient information to be able to infer
complete boiler generator associations (and thus heat rates) for natural gas
fired generators. In effect the fuel consumption of combustion turbines and the
combustion turbine portions of combined cycle plants were excluded since they
aren't really "boilers." In the case of combined cycle plants, this can result
in impossibly low heat rates, since only additional fuel injected after the
combustion turbine counts as fuel input associated with the power generated
by the steam turbine.

### Unrealistically High Coal Mercury Content
In 2012 a significant portion of the coal deliveries reported in the EIA 923
Fuel Receipts and Costs table had mercury content orders of magnitude higher
than was possible, and higher than in any other report year.

### Imperfect FERC Form 1 Plant ID Assignments
Because FERC does not assign unique identifiers to the individual plants whose
data are reported, and FERC Form 1 respondents are free to identify those
facilities however they like from year to year, there is no entirely reliable
way to link records pertaining to a given plant in one year to records
pertaining to the same plant in another year. We use a record linkage algorithm
that considers the reported plant names, capacities, years of construction,
primary fuels, and other attributes to attempt to associate plant records with
each other across years, but the process is imperfect. The `plant_id_ferc1`
values found in the `plants_steam_ferc1` and `fuel_ferc1` tables should be
considered experimental and used with caution.

### Non-unique Mappings Between `plants_steam_ferc1` & `fuel_ferc1`
While the plant names and utility IDs found in the `plants_steam_ferc1` and
`fuel_ferc1` in any given year for a particular plant are guaranteed to be the
same, they are not guaranteed to be **unique** which means that in a few cases
it is not possible to identify exactly how much or what kind of fuel is
associated with a particular plant record.

### Imperfect Data Entry Error Correction
In some cases obvious errors have been made in data entry or units of measure.
We have attempted to fix some of them (e.g. converting heat content reported in
BTU per lb of coal into mmbtu per ton) and we are confident that overall these
corrections have improved the quality of the dataset, but there are likely a
few cases in which they have been applied incorrectly.

### Imperfect Coding
FERC does not restrict the vocabulary respondents may use to describe plant and
fuel types, resulting in thousands of different strings being used. We have
done our best to identify and categorize them all in the steam plants table,
but this process is imperfect.

Many other tables still have not been similarly coded, the `plants_small_ferc1`
and `purchased_power_ferc1` tables remain especially messy.

# Reproducibility
It's our intention that a user should be able to completely reproduce the data
processing pipeline that we've used to generate this data release, and get the
same outputs byte-for-byte, using only resources that are available in curated,
long-term archives. The main requirements are a copy of the same original
source data (archived as part of this data release), and a specification of the
software environment (which can be reconstructed with packages from
`conda-forge` or the Python Package Index).

## Original Source Data
The original source data as downloaded from the public sources and used by the
PUDL software to generate this data release are archived here alongside the
outputs in the interest of reproducibility. The publishing agencies do not use
version control or provide access to historically published versions, meaning
that the same data may not remain available from them going forward. All of the
original input data can be found in the `pudl-input-data.tgz` compressed
archive distributed with this data release. The data it contains were
downloaded from FERC, EIA, and EPA between January 31st and February 3rd, 2020.

## Software Environment
This data release was generated using v0.3.1 of the `catalystcoop.pudl` Python
package, which is available on the official Python Package Index as well as via
`conda` using the community maintained `conda-forge` channel. It's also
archived in [the PUDL Github
repository](https://github.com/catalyst-cooperative/pudl/releases/tag/v0.3.1).
and [on Zenodo](https://doi.org/10.5281/zenodo.3647661)

The `archived-environment.yml` file distributed in this archive describes the
`conda` software environment in which this data release was generated.

## OS / Hardware
The data package was generated on an Ubuntu Linux 19.10 system. The only
specialized external library that was required outside of the `conda` framework
was `libsnappy-dev` version `1.1.7-1`. This library should not be required if
you use `conda`.

The data processing pipeline used to generate this data release required ~24 GB
of memory, mostly due to record linkage between years of the large steam plants
in the FERC Form 1 data. If you run the release reproduction script described
below, it will require ~50 GB of free disk space.

## Data Release Scripts
The `data-release.sh` script used to generate this data release is included in
the archive. That script downloads fresh original data from the public agencies
and processes it. Output from the script was saved to the `data-release.log`
file included with the release.

In order to reproduce the outputs archived here using the archived inputs, you
should be able to simply place all of the files form the Zenodo archive in an
empty directory, and run the `reproduce-data-release.sh` script from within
that directory, subject to the hardware requirements mentioned above.

# Acknowledgments
* Alfred P. Sloan
* Flora Family Fund
* Frictionless Data / Open Knowledge Foundation

# TODO:

## Writing:
* Finish data errata / validation.
* Acknowledgments
* Contact Us / Bug Reports

## Deployment / Publication
* Create a pudl@catalyst.coop Zenodo organizational account
* Get a real DOI for the data release from Zenodo using PUDL account
* Insert real DOI into the README & ETL settings file.
* Commit final README & ETL settings file with real DOI (ALL CEMS STATES).
* Tag v1.0.0 in the pudl-data-release repository
* Re-generate final v1.0.0 release using tagged commit.
* Upload files to Zenodo for real
* Fill in additional archive metadata on Zenodo
* Save and Publish the Release!
