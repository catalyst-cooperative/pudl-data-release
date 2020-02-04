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
Docs](https://catalystcoop-pudl.readthedocs.io/en/v0.3.0/). This data release
was generated using v0.3.0 of the `catalystcoop.pudl` python package.

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

# Data Validation and Quality
We have performed basic sanity checks on much but not all of the data compiled
in PUDL to ensure that we identify any major issues we might have introduced
through our processing prior to release. These checks have also identified some
issues in the originally reported data.

## Quality Control
* Reported ownership shares of plants add up to ~100%
* Fuel heat content per unit and prices are within reasonable bounds.
* Fuel sulfur, ash, moisture, chlorine, and mercury content are within
  reasonable bounds.
* EIA reported generation units are not split across more than one PUDL
  identified unit.
* ......
* ......
* ......
* ......
* ......

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

# Reproducing This Data Release
It's our intention that a user should be able to completely reproduce the data
processing pipeline that we've used to generate this data release, and get the
same outputs byte-for-byte, using only resources that are available in curated,
long-term archives. The main requirements are a copy of the same original
source data (archived here), and a specification of the software environment.

## Original Source Data
The original source data as downloaded from the public sources and used by the
PUDL software to generate this data release are archived here alongside the
outputs in the interest of reproducibility. The publishing agencies do not use
version control or provide access to historically published versions, meaning
that the same data may not remain available from them going forward. All of the
original input data can be found in the `pudl-input-data.tgz` compressed
archive distributed with this data release.

## Software Environment
This data release was generated using v0.3.0 of the `catalystcoop.pudl` Python
package, which is available on the official Python Package Index as well as
via `conda` using the community maintained `conda-forge` channel, and in
[the PUDL Github repository](https://github.com/catalyst-cooperative/pudl). It
is also [archived on Zenodo](https://doi.org/10.5281/zenodo.3631868).

The `archived-environment.yml` `conda` environment file enumerates the
Python packages that were installed in the environment used to generate this
data package, along with their versions.

## OS / Hardware
The data package was generated on an Ubuntu Linux 19.10 system. The only
specialized external library that was required outside of the `conda` framework
was `libsnappy-dev` version `1.1.7-1`.

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

# Using the Data
To How to organize the data for use with the PUDL library.


```
mkdir pudl-work
cd pudl-work
tar -xzf pudl-ferc1.tgz
tar -xzf pudl-eia860-eia923.tgz
tar -xzf pudl-eia860-eia923-epacems.tgz

conda create --yes --name pudl --channel conda-forge \
    --strict-channel-priority python=3.7 \
    catalystcoop.pudl=0.3.0 jupyter jupyterlab pip
conda activate pudl

pudl_setup ./

datapkg_to_sqlite
    datapkg/pudl-data-release/pudl-ferc1/datapackage.json \
    datapkg/pudl-data-release/pudl-eia860-eia923/datapackage.json \
    -o datapkg/pudl-data-release/pudl-merged/

epacems_to_parquet datapkg/pudl-data-release/pudl-eia860-eia923-epacems/datapackage.json

ferc1_to_sqlite data-release-settings.yml

```
* Exhortation for users to get in touch with us and let us know what they're
  using PUDL for.
* Instructions on how to report any data issues which were not listed in the
  README.

# Acknowledgments
* Sloan and Flora foundation

# DATA RELEASE REMAINING TODO:
* Write up data errata.
* Write up acknowledgements Section.
* Write up "Contact Us" section

* Check in README and scripts.
* Upload files to Zenodo Sandbox
* Try downloading files from Zenodo Sandbox and see if anything is wonky.

* Get a real DOI for the data release from Zenodo
* Insert real DOI into the README.
* Commit final README with real DOI.
* Tag v1.0.0 in the pudl-data-release repository
* Re-generate final v1.0.0 release using v1.0.0 tagged commit.
* Upload files to Zenodo for real
* Fill in archive metadata on Zenodo
