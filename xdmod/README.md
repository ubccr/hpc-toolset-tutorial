## Overview

In this part of the tutorial we are going to install and configure Open XDMoD.
The base component of Open XDMoD uses the job accounting logs from the HPC
resource manager as the data source.  We are also going to install the optional Job Performance Module. This
allows Open XDMoD to also display performance data for HPC jobs.

## Submit some jobs to the cluster
Before we install and configure XDMoD we are going to submit
some HPC jobs to the cluster. These jobs will run while we go through
the install and then we will be able to view the job information
in Open XDMoD.

Login to frontend via SSH and user: `hpcadmin` password: `ilovelinux`:
```bash
ssh -p6222 hpcadmin@localhost
```

Run the provided script that submits several jobs to the cluster. These jobs
run as multiple different users with different job sizes and durations. The
purpose of this is to generate data to display in Open XDMoD. This, of course,
would not be required on a production deployment. This script should be run
as the hpcadmin user as it uses `sudo` to submit jobs as different cluster:
users.
```bash
submit_jobs.sh
```

## Open XDMoD Installation

For this tutorial, the Open XDMoD software will be installed in the `xdmod` container.
Open XDMoD will use the MySQL database from the `mysql` container. Since we
will also be installing the optional Job Performance module we also run
a MongoDB database in the `mongodb` container. The various runtime scripts to process
the Job accounting and Job performance data will all be run in the `xdmod` container.

The Open XDMoD software is installed via RPMs. The majority of the software dependencies
are automatically installed via RPM. However, the `phantomjs` software
that Open XDMoD uses for its image export must be installed seperately.

Open XDMoD provides an interactive configuration script that performs the
database initialization and generates configuration files. This script
handles the basic setup.

The `hpc-toolset-tutorial/xdmod/install.sh` script contains the step-by-step
instructions to install the packages.

## Open XDMoD Configuration

### Prerequisites

The following information is needed by Open XDMoD:

- Name of the organization
- information for each HPC resource
    - Name
    - Number of compute nodes
    - Number of cores
    - Timezone
    - Whether it runs shared jobs

Optionally:

- An image file containing the HPC center logo

Also the following technical information:

- The public url of Open XDMoD
- Paths to installed dependencies (phantomjs)
- MySQL connection information


## Open XDMoD Job Performance
The Job Performance module is optional, but highly recommended.
The Job Performance
TODO: PCP Configuration (mention alternatives, TACC,...)
https://github.com/ubccr/hpc-toolset-tutorial/blob/master/slurm/pmlogger-supremm.config#L56-L59

Done: Names.csv

TODO: FOS

## Open XDMoD Operation
TODO: SHRED INGEST AGGREGATE
TODO: SUPREMM SHRED INGEST
## It is Known
-  `[WARNING] ... RuntimeWarning: invalid value encountered in double_scalars`
  -  https://stackoverflow.com/questions/27784528/numpy-division-with-runtimewarning-invalid-value-encountered-in-double-scalars/27784588#27784588
-  `[WARNING] Autoperiod library not found, TimeseriesPatterns plugins will not do period analysis`
  -  The autoperiod code is used for detecting period I/O patterns in the parallel filesystem traffic. (not needed in the tutorial configuration)
TODO: User Dashboard?

## Open XDMoD Functionality
TODO: User
TODO: PI
TODO: Center
TODO: Basic Admin

## Tutorial Navigation
[Next - OnDemand](../ondemand/README.md)  
[Previous Step - ColdFront](../coldfront/README.md)  
[Back to Start](../README.md)
