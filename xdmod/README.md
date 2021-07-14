## Overview

**NOTE:**
Due to this tutorial being virtual and much shorter than anticipated; this part of the tutorial is going to be a bit more of an interactive demo. Some parts are going to be skipped over quicker than usual, however, our team is available in SLACK and Zoom chat to answer any questions that you may have.

In this part of the tutorial we are going to go over the installation and configuration of Open XDMoD.
The base component of Open XDMoD uses the job accounting logs from your HPC
resource manager as the data source. We have also installed the optional Job Performance Module. This allows Open XDMoD to also display performance data for HPC jobs.

The asciinema media is not meant to be used on its own, they are intended for use in a "live" demonstration.

Command Line Demos in a Light color, are meant to be watched. Dark theme are interactive.

`vim` is used to edit files in this tutorial. If you prefer a different editor, please install it on the xdmod container.

## Submit some jobs to the cluster

**NOTE:** For the PEARC2021 tutorial the Presenter has already done this on their machine. If you are interested in running this on your own please do so.

Before we install and configure XDMoD we are going to submit
some HPC jobs to the cluster. This will ensure that we'll have something to view when we're done setting up XDMoD.

Login to frontend via SSH and user: `hpcadmin` password: `ilovelinux`:
```bash
ssh -p6222 hpcadmin@localhost
```

Run the provided script that submits several jobs to the cluster. These jobs
run as multiple different users with different job sizes and durations. The
purpose of this is to generate data to display in Open XDMoD.

**NOTE**: This, of course, would not be required on a production deployment.

This script should be run as the hpcadmin user as it uses `sudo` to submit jobs as different cluster users.
```bash
submit_jobs.sh
```

Output should look similar to:
```bash
[hpcadmin@xdmod ~]$ submit_jobs.sh 
Submitted batch job 2
Submitted batch job 3
Submitted batch job 4
Submitted batch job 5
Submitted batch job 6
Submitted batch job 7
Submitted batch job 8
Submitted batch job 9
Submitted batch job 10
Submitted batch job 11
Submitted batch job 12
Submitted batch job 13
Submitted batch job 14
Submitted batch job 15
Submitted batch job 16
Submitted batch job 17
Submitted batch job 18
Submitted batch job 19
```

## Open XDMoD Installation

**Note** This part will be brief in the PEARC2021 tutorial. These processes have been done already as part of the docker.

For this tutorial, the Open XDMoD software will be installed in the `xdmod` container.
Open XDMoD will use the MySQL database from the `mysql` container. Since we
will also be installing the optional Job Performance module we also run
a MongoDB database in the `mongodb` container. The various runtime scripts to process
the Job accounting and Job performance data will all be run in the `xdmod` container.

The [`hpc-toolset-tutorial/xdmod/install.sh`](https://github.com/ubccr/hpc-toolset-tutorial/blob/master/xdmod/install.sh) script contains the step-by-step
instructions to install the packages.

Reference: [RPM Installation Guide](https://open.xdmod.org/install-rpm.html)

Package Installation:
[![asciicast](https://asciinema.org/a/349235.svg)](https://asciinema.org/a/349235)

## Open XDMoD Configuration

**Note** This part will be brief in the PEARC2021 tutorial. These processes have been done already as part of the docker.

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
    - The width of the HPC center logo in pixels

You will also need the following technical information:

- The public url of Open XDMoD
- MySQL connection information
    - Host
    - Port
    - Admin Username
    - Admin Password
    - DB Username
    - DB Password

If you are installing the Job Performance module (as we are in this tutorial) 
- mongoDB connection information

### Prerequisites used in this Tutorial

- Name of the organization: `Tutorial` abbreviation: `hpcts`
- information for each HPC resource
    - Name: `hpc`
    - Number of compute nodes: `2`
    - Number of cores: `2`
    - Timezone: `UTC`
    - Whether it runs shared jobs: `no`
- An image file containing the HPC center logo: `/srv/xdmod/small-logo.png`
    - The width HPC center logo: `354`
- The public url of Open XDMoD: `https://localhost:4443`
- MySQL connection information
    - Host: `mysql`
    - Port: `3306`
    - Admin Username: `root`
    - Admin Password: ` leave blank `
    - DB Username: `xdmodapp`
    - DB Password: `ofbatgorWep0`
- mongoDB connection information `mongodb://xdmod:xsZ0LpZstneBpijLy7@mongodb:27017/supremm?authSource=admin`

### Basic Configuration
Open XDMoD provides an interactive configuration script that performs the
database initialization and generates configuration files. This script
handles the basic setup.

The [`hpc-toolset-tutorial/xdmod/entrypoint.sh`](https://github.com/ubccr/hpc-toolset-tutorial/blob/master/xdmod/entrypoint.sh) script automates this process.

Reference: [Configuration Guide](https://open.xdmod.org/configuration.html)

The following asciinema recordings are how an administrator would perform these actions:

General Setup:
[![asciicast](https://asciinema.org/a/349236.svg)](https://asciinema.org/a/349236)

Database Setup:
[![asciicast](https://asciinema.org/a/352844.svg)](https://asciinema.org/a/352844)

Organization Setup:
[![asciicast](https://asciinema.org/a/349238.svg)](https://asciinema.org/a/349238)

Resource Setup:
[![asciicast](https://asciinema.org/a/349240.svg)](https://asciinema.org/a/349240)

#### Advanced configuration

The `xdmod-setup` script is used for the basic setup of Open XDMoD. The script includes options to configure the Open XDMoD database, set up the admin user account and configure resources.
Open XDMoD's [Configuration](https://open.xdmod.org/configuration.html#location-of-configuration-files) files can be modified directly when needing more advanced customization.

*Have a heterogeneous cluster?*  You can modify `/etc/xdmod/resource_specs.json` and set the PPN to the average number of processors per node.

#### Hierarchy

Open XDMoD supports a three level hierarchy.
In this tutorial we use a hierarchy configuration that is typical of the organizational structure in a University.

Decanal Unit -> Department -> PI Group

Reference: [Hierarchy Guide](https://open.xdmod.org/hierarchy.html)

## Open XDMoD Job Performance

**Note** This part will be brief in the PEARC2021 tutorial. These processes have been done already as part of the docker.

The Job Performance module is optional, but highly recommended.

![Job Performance Dataflow](./tutorial-screenshots/admin-job-performance-dataflow.png)

### Job Performance Configuration

[Job Performance](https://supremm.xdmod.org) data - for the open source release we'll try to provide support for [Performance Co-Pilot (PCP)](https://pcp.io).
We chose PCP because it is included by default in Centos / RedHat.
In XSEDE we use tacc_stats and PCP (depending on the resource provider). We are also aware of groups using LDMS, Cray RUR and Ganglia too. We have a team now looking into Prometheus.

PCP has been [installed](https://github.com/ubccr/hpc-toolset-tutorial/blob/master/slurm/install.sh#L80-L87) and configured on the compute nodes.
This tutorial uses a cut-down list of PCP metrics from the recommended metrics for a production HPC system.
This shorter list is suitable for running inside the docker demo. On a
real HPC system the data collection should be setup following the
[PCP Data collection](https://supremm.xdmod.org/supremm-compute-pcp.html#configuration-templates) guide

The file used in this demo can be viewed here: https://github.com/ubccr/hpc-toolset-tutorial/blob/master/slurm/pmlogger-supremm.config#L56-L59

VERY IMPORTANT - Don't start the configuration of the Job Performance module until there is job data ingested into Open XDMoD
The Job performance setup relies on the accounting data from the Jobs realm in Open XDMoD.
This was done as part of this tutorial as part of setup and will be done again later in the tutorial.

Job Performance XDMoD Module Setup:
[![asciicast](https://asciinema.org/a/352845.svg)](https://asciinema.org/a/352845)

Job summarization (SUPReMM) configuration:
[![asciicast](https://asciinema.org/a/349243.svg)](https://asciinema.org/a/349243)

## Open XDMoD Operation

### Shredding Ingestion & Aggregation

Shredding
> Load logs from a scheduler (SLURM in this tutorial) and put them into the Open XDMoD databases.
> see [Open XDMoD](https://open.xdmod.org/) for notes on SGE/Grid Engine, Univa Grid Engine, PBS/TORQUE, LSF
> Reference: [Shredder Guide](https://open.xdmod.org/shredder.html)

Ingestion
> Prepare data that has already been loaded by the shredder into the Open XDMoD databases so that is can be queried by the Open XDMoD portal.
> Reference: [Ingestor Guide](https://open.xdmod.org/ingestor.html)

Aggregation
> What actually gets data into the Open XDMoD portal. For core xdmod this is part of ingestion. Job Performance has a separate script.

This tutorial provides a script [`shred-ingest-aggregate-all.sh`](https://github.com/ubccr/hpc-toolset-tutorial/blob/master/xdmod/scripts/shred-ingest-aggregate-all.sh)
that does this. In a typical setup this would be part of a cron job run when it is best suited for the HPC system.

Run this now on the `xdmod` container

Login to frontend via SSH and user: `hpcadmin` password: `ilovelinux`:

```bash
ssh -p6222 hpcadmin@localhost
```
SSH to the xdmod container:

```bash
ssh xdmod
```
Run the script as the xdmod user:

```bash
sudo -u xdmod /srv/xdmod/scripts/shred-ingest-aggregate-all.sh
```
This is going to produce A LOT of output. Each of these commands have flags that will turn this off. For the purpose of this tutorial they have not been silenced.

[![asciicast](https://asciinema.org/a/349242.svg)](https://asciinema.org/a/349242)

#### Expected Warnings
-  `[WARNING] ... RuntimeWarning: invalid value encountered in double_scalars`
    -  https://stackoverflow.com/questions/27784528/numpy-division-with-runtimewarning-invalid-value-encountered-in-double-scalars/27784588#27784588
-  `[WARNING] Autoperiod library not found, TimeseriesPatterns plugins will not do period analysis`
    -  The autoperiod code is used for detecting periodic I/O patterns in the parallel filesystem traffic. (not needed in the tutorial configuration)


## User / PI Names

**NOTE**: Feel Free to skip this part in the PEARC2021 Tutorial, as it does not impact the use of the system.

The resource manager logs contain the system usernames of the users that submitted jobs.
To display the full names in Open XDMoD you must provide a data file that contains the
full name of each user for each system username. This file is in a `csv` format.

![Group By User(names not imported)](./tutorial-screenshots/usernames.png)

This step has not been automated as we don't want you falling asleep!

Login to frontend via SSH and user: `hpcadmin` password: `ilovelinux`:

```bash
ssh -p6222 hpcadmin@localhost
```
SSH to the xdmod container:

```bash
ssh xdmod
```

Create a file as shown below: ( The file needs to be able to be read by the `xdmod` user, for this demo it will be created in /var/tmp )

```bash
vim /var/tmp/names.csv
```

The first column should include the username or group name used by your resource manager, the second column is the user’s first name, and the third column is the user’s last name.
(Feel free to change the First and Last names)

```csv
cgray,Carl,Gray
sfoster,Stephanie,Foster
csimmons,Charles,Simmons
astewart,Andrea,Stewart
hpcadmin,,HPC Administrators
```

Now this needs to be imported into xdmod with the command [`xdmod-import-csv`](https://open.xdmod.org/commands.html#xdmod-import-csv)

```bash
sudo -u xdmod xdmod-import-csv -t names -i /var/tmp/names.csv
```

Next we will need to re-ingest and aggregate the data:

```bash
sudo -u xdmod /srv/xdmod/scripts/shred-ingest-aggregate-all.sh
```
![Group By User](./tutorial-screenshots/fullnames.png)

Reference: [User/PI Names Guide](https://open.xdmod.org/user-names.html)

xdmod-import-csv -t names:
[![asciicast](https://asciinema.org/a/349325.svg)](https://asciinema.org/a/349325)

## Open XDMoD Functionality (Interactive Demo)

**Note** The Gateways2020 demo has additional anonymized historical data (about 2 months) that can be added, this takes a while (depending on your system, mine took about 3 hours...) to actually run. This data will be used by the presenter for this demonstration.

If / when you run this it will look a lot like when we ran `/srv/xdmod/scripts/shred-ingest-aggregate-all.sh`

```bash
sudo /srv/xdmod/historical/add-historical.sh
```

### Administration

You know that the user is an admin by the addition of the "Admin Dashboard"

![Admin User](./tutorial-screenshots/admin-user.png)

Admin Dashboard:

![Admin Dashboard](./tutorial-screenshots/admin-dashboard.png)

### End User

Let's actually use Open XDMoD now.

With a fully installed system we have quite a bit of data. Job information, Storage Usage, Cloud Usage, Job Performance (SUPREMM)
![Public User Usage](./tutorial-screenshots/public-user-options.png)

User Dashboard:
![Logged in User Dashboard](./tutorial-screenshots/loggedin-dashboard.png)

![Logged in User Job Performance](./tutorial-screenshots/loggedin-performance.png)

PI:
![Logged in PI Dashboard](./tutorial-screenshots/loggedin-pi-dashboard.png)

Center Staff:
![Logged in Center Staff Dashboard](./tutorial-screenshots/centerdirector-dashboard.png)

Report Generator:
![Report Generator](./tutorial-screenshots/report-generator.png)
## Tutorial Navigation
[Next - OnDemand](../ondemand/README.md)
[Previous Step - ColdFront](../coldfront/README.md)
[Back to Start](../README.md)
