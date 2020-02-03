# PUDL Data Release 1.0.0

This is the first data release from the [Public Utility Data Liberation (PUDL)
project](https://catalyst.coop/pudl). It can be referenced & cited using
https://doi.org/10.5281/zenodo.XXXXXXX.
The most recent release of these data can be found using this concept DOI:
https://doi.org/10.5281/zenodo.XXXXXXX.

# Included Data Packages
This data release consists of three tabular data packages, conforming to the
standards published by [Frictionless Data](https://frictionlessdata.io) and the
[Open Knowledge Foundation](https://okfn.org). The data are stored in CSV files
(some of which are compressed using gzip), and the associated metadata is
stored as JSON. These tabular data can be used to populate a relational
database.

## `pudl-eia860-eia923`
Data originally collected and published by the US Energy Information
Administration (US EIA). The data from Form 860 covers the years 2011-2018. The
Form 923 data covers 2009-2018. The overwhelming majority of the data published
in the original data sources has been included, but some parts, like fuel
stocks on hand, have not yet been integrated.

Note that because there 2009-2010 EIA 860 data has not yet been fully
integrated into PUDL, the earliest years of EIA 923 data may not have as much
detail in terms of the utilities, plants, and generators associated with the
various data reported in that form.

## `pudl-eia860-eia923-epacems`
This data package contains all of the same data as the pudl-eia860-eia923
package above, as well as the Hourly Emissions data from the US Environmental
Protection Agency's (EPA's) Continuous Emissions Monitoring System (CEMS) from
1995-2018. The EPA CEMS data covers thousands of power plants at hourly
resolution for decades, and contains close to a billion records.

## `pudl-ferc1`
Seven tables from FERC Form 1, mostly related to individual power plants,
covering the years 1994-2018 (the entire span of time for which FERC provides
this data).

* `plants_steam_ferc1`
* `fuel_ferc1`
* `plants_small_ferc1`
* `plants_hydro_ferc1`
* `plants_pumped_hydro_ferc1`
* `plant_in_service_ferc1`
* `purchased_power_ferc1`

These tables are the only ones which have been extensively cleaned and
organized for programmatic use within PUDL. The complete, raw FERC Form 1
database contains 116 different tables with many thousands of columns of mostly
financial data. We will archive a complete copy of the multi-year FERC Form 1
Database as a file-based SQLite database at Zenodo, independent of this data
release. It can also be re-generated using the `catalystcoop.pudl` Python
package and the original source data files archived as part of this data
release.

# Data Validation and Quality

## Quality Control
* Explanation of what kinds of data validation have and have not been performed
  on the various data sets which are included.

## Known Issues
* Missing 2009-2010 EIA 860 data.
* Harvesting of entity values.
* High Hg content in some coal data.
* Imperfect assignment of PUDL Plant IDs in FERC Form 1.
* Lack of unique connections between FERC Steam and FERC Fuel tables.
* Boiler Generator Associations for natural gas plants pre-2015(?).
* Poorly cleaned small plants table / no PUDL ID assignments.

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
that the same data may not remain available from them going forward.

## Software Environment
This data release was generated using v0.3.0 of the `catalystcoop.pudl` Python
package, which is available on the official Python Package Index as well as
via `conda` using the community maintained `conda-forge` channel, and in
[the PUDL Github repository](https://github.com/catalyst-cooperative/pudl). It
is also archived on Zenodo at https://doi.org/10.5281/zenodo.3631868.

This archive contains a `conda` environment file `export-environment.yml` which
enumerates every Python package that was installed in the environment used to
generate this data package.

## OS / Hardware
The data package was generated on an Ubuntu Linux 19.10 system. The only
specialized external library that should be required outside of the `conda`
framework is `libsnappy-dev` version `1.1.7-1`.

The data processing pipeline used to generate this data release required ~24 GB
of memory, mostly due to record linkage between years of the large steam plants
in the FERC Form 1 data.

## Data Release Script
The `data-release.sh` script used to generate this data release is included in
the archive. That script downloads fresh original data from the public agencies
and processes it. In order to reproduce the outputs archived here, a different
script `reproduce-data-release.sh` that uses the archived data must be used
instead.

# Using the Data
* Instructions for how to load the data release into SQLite or Apache Parquet
  (for CEMS).
* Pointer to the PUDL documentation on readthedocs for more information on how
  to make use of the data once it is loaded, using the PUDL output objects and
  other tools.
* Exhortation for users to get in touch with us and let us know what they're
  using PUDL for.
* Instructions on how to report any data issues which were not listed in the
  README.

# Acknowledgments
* Sloan and Flora foundation
