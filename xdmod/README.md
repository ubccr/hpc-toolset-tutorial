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

---
Below you'll find a step-by-step of each command we'll be running to install both Open XDMoD & it's pre-requisites.

### Pre-Requisites Installation:

We need to install Extra Packages for Enterprise Linux so that we can install some further dependencies
```shell
[root@xdmod /] yum install -y epel-release   
```

### RPM Installation

```shell
[root@xdmod /] yum install -y https://github.com/ubccr/xdmod/releases/download/v9.5.0/xdmod-9.5.0-1.0.el7.noarch.rpm
```

Congratulations! OpenXDMoD is now installed!

## Open XDMoD Configuration

**Note** This part will be brief in the PEARC2021 tutorial. These processes have been done already as part of the docker.

### System Configuration

PHP does not set a timezone by default, so we'll need to set one ourselves. We've selected `UTC` for this demo, but regardless of what timezone you end up using, the most important thing is to ensure that the XDMoD web server, the database server, and ideally the timezone of your HPC resources, are all be the same time zone.

```shell
[root@xdmod /] sed -i 's/.*date.timezone[[:space:]]*=.*/date.timezone = UTC/' /etc/php.ini
```

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

---

## Basic Configuration
Open XDMoD provides an interactive configuration script that performs the
database initialization and generates configuration files. 

To begin the setup process for XDMoD you will want to type the following: 
```shell
[root@xdmod /] xdmod-setup
```

After which you should be greeted by a screen that looks like: 
```shell
========================================================================
Open XDMoD Setup
========================================================================

1) General Settings
2) Database Settings
3) Organization
4) Resources
5) Create Admin User
6) Hierarchy
7) Data Warehouse Batch Export
8) Automatically Check for Updates
9) SUPReMM
q) Quit

Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q):
```

The next series of steps will involve completing each numbered setup item in turn from 1-8. We will complete SUPReMM setup after we have successfully shredded, ingested, and aggregated the accounting data generated by the jobs we submitted at the beginning of this tutorial.

### General Settings

```shell
1) General Settings
```

Press `1` followed by the `Enter` key to start the General Settings setup.

```shell 
Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q): 1
```

You should be presented with the screen you see below.

#### Site Address

The value you enter here should be the public facing URL that your XDMoD installation will be served from. For the purpose of this tutorial we'll be using the default value, to do so press the `Enter` key.

```shell
========================================================================
General Setup
========================================================================

The template Apache configuration file uses a virtual host
listening on HTTPS port 443. The Site Address specified
here should match the settings in the Apache configuration.

Site Address: [https://localhost:4443/]
```
*Note: values contained in `[ ]` are default values that can be used by simply pressing the `Enter` key. These values have been modified specifically for this tutorial and may be different from the values you encounter while installing XDMoD at your home institution.*

#### Email Address
Upon pressing enter, the next piece of information you will be prompted to provide is the email address your XDMoD installation will use as the recipient of contact and user account requests. We can again accept the default value by pressing the `Enter` key.

```shell
The email address you specify will be used as the destination for any
messages sent via the portal contact page as well as account requests.  In
addition, any log messages configured for delivery via e-mail will be sent to
this address.

Email Address: [ccr-xdmod-help@buffalo.edu]
```

#### Chromium Path
XDMoD utilizes Chromium Headless to generate its images and reports, so the next step will be telling XDMoD where it can be found. In our case, we can just press `Enter` to accept the default value.

```shell
Chromium Path: [/usr/lib64/chromium-browser/headless_shell]
```

#### Center Logo Path
XDMoD does support per center branding, so if you do have an image you would like to use in branding your XDMoD installation you can provide the path to said image here.


```shell
You have the ability to specify a logo which will appear on the upper-right
hand region of the portal.  It is advised that the height of the logo be at
most 32 pixels.

The logo is referenced by its absolute path on the file system and must
be readable by the user/group your web server is running as.

Center Logo Path: [/srv/xdmod/small-logo.png]
```

For this tutorial we will just accept the default value.

#### Center Logo Width ( in pixels )
If you do provide a custom center image, you will also need to provide its width in pixels.

```shell
Center Logo Width: [354]
```

#### XDMoD Dashboard
The new and improved XDMoD Dashboard provides users with carefully curated statistics and reports based on the level of 
access they've been granted in XDMoD. We highly recommend you turn this on in your installation as we will be doing here 
by pressing the `Enter` key.    

```shell
This release of XDMoD features an optional replacement for the summary
tab that is intended to provide easier access to XDMoD's many features.
Detailed information is available at https://open.xdmod.org/dashboard.html

Enable Dashboard Tab (on, off)? [on]
```

You will now be prompted to overwrite the config file `/etc/xdmod/portal_settings.ini`. If you are satisfied that the 
information you have provided thus far is correct, then press the `Enter` key to save. 

If you need to change one of your answers then you can type `no`, press `Enter` and you will be taken back to the main 
setup menu. At which point you can press `1` and to go through the General Settings setup again.   

### Database Settings

Now that we've successfully completed the `General Settings` setup, we can move on to `Database Settings`.

```shell
2) Database Settings
```

Press `2` followed by the `Enter` key to start the Database Settings setup.

```shell 
Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q): 2
```
#### DB Hostname or IP

The first piece of information you will be prompted for is the Hostname or IP of the server that XDMoD's MySQL / MariaDB database is located on. In our case we have a separate container hosting our mysql instance, so we can go ahead and press the `Enter` key to accept the default value.

*It's important to note that if you are setting up XDMoD for the first time and choose to have your database hosted on another server, you will need to have an SA database account created and allowed to log in from the XDMoD server. This SA account will only be used to create the more restricted db account and databases / schemas that are used during XDMoD's normal operation.*

```shell
========================================================================
Database Setup
========================================================================

Please provide the information required to connect to your MySQL database
server.  A user will be created using the username and password you provide.

NOTE: The database password cannot include single quote characters (') or
double quote characters (").

DB Hostname or IP: [mysql]
```

#### DB Port

Here you will enter the port that your database instance is exposed on. We can go ahead and accept the default value by 
pressing `Enter`.

```shell
DB Port: [3306]
```

#### DB Username

This is the name of the restricted database account that XDMoD will use to function. Go ahead and press `Enter` to 
accept the default value.

```shell
DB Username: [xdmodapp]
```

#### DB Password

This will be the password for the DB account you entered in the last step. Please enter the following: `ofbatgorWep0`. 
Note that when you type the password the keystrokes will not be displayed on the screen. This is expected, when you are
done typing the password you can finish this step by pressing `Enter`.  

```shell
DB Password:
```

You will then be prompted to type the password again to confirm your password choice. After you have typed the password
again, press `Enter` to continue.

```shell
(confirm) DB Password:
```

#### Administrative DB Username
After confirming the password for XDMoD's database account, you will be prompted for the username and password of the 
admin account. 

```shell
Please provide the password for the administrative account that will be
used to create the MySQL user and databases.

DB Admin Username: [root]
```

For the purposes of this tutorial you can accept the default value of `root`, pressing `Enter` to continue. 

#### Administrative DB User Password

We will next enter the administrative DB User's password by pressing `Enter`. Take note, never ever ever do this in 
production. We've only done it here to keep things simple.

```shell
DB Admin Password:
```

You will again be prompted to confirm the password you just entered, and so can continue by simply pressing `Enter`.

```shell
(confirm) DB Admin Password:
```

If you have supplied the correct database credentials then you should be presented with the following message. 

```shell
Creating User xdmodapp
```

#### Database Maintenance

Now that we have our database users created, the setup will proceed to detect if the databases XDMoD utilizes are 
present. If they are then it will ask if you want to Drop and recreate them.

```shell
Database `mod_shredder` already exists.
Drop and recreate database (yes, no)? [no]
```

For the purposes of this tutorial we will want to enter `yes` followed by pressing `Enter` each time we are prompted.

If successful you should see the following information: 
```shell
Dropping database `mod_shredder`.
Creating database `mod_shredder`.
Granting privileges on database `mod_shredder`.
Initializing database `mod_shredder`.
```

You should receive the same prompt for the following databases:
- `mod_hpcdb`
- `moddb`
- `modw`
- `modw_aggregates`
- `modw_filters`
- `mod_logger`

After you have dropped and re-created all of these databases you will be prompted to save the information you have entered
to the config file `/etc/xdmod/portal_settings.ini`. Go ahead and press `Enter` to do so.

```shell
Overwrite config file '/etc/xdmod/portal_settings.ini' (yes, no)? [yes]
```

If all goes well than you will see: 
```shell
Settings saved.

Press ENTER to continue.
```

Follow the prompt and press `Enter` this will return you to the main setup menu.

### Organization Settings

With the database settings taken care of we can move on to our Organization.

```shell
========================================================================
Open XDMoD Setup
========================================================================

1) General Settings
2) Database Settings
3) Organization
4) Resources
5) Create Admin User
6) Hierarchy
7) Data Warehouse Batch Export
8) Automatically Check for Updates
9) SUPReMM
q) Quit

Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q): 3
```

- Press `3` followed by `Enter`

#### Organization Name
The first piece of information you will be prompted for is your organization's name. This will be what's displayed to
your end users when XDMoD displays organization information. You can enter any value you'd like or accept the default
value by pressing `Enter`.

```shell
========================================================================
Organization Setup
========================================================================

Organization Name: [Tutorial]
```

#### Organization Abbreviation
This value should be a string of all lowercase letters with no spaces to be used as an abbreviation for your 
organization. You can again enter any value that conforms to these requirements or accept the default value by pressing
`Enter`.

```shell
Organization Abbreviation: [hpcts]
```

You will then be prompted to save these values to the organization configuration file. If you are satisfied with the 
values you have entered than press `Enter` to continue. If not then type `no`, press `Enter` and re-enter the 
Organization configuration menu by typing `3` and pressing `Enter`.

```shell
Overwrite config file '/etc/xdmod/organization.json' (yes, no)? [yes]
```

### Resource Setup

Next we will go through the process of adding a Resource to XDMoD. 

```shell
========================================================================
Open XDMoD Setup
========================================================================

1) General Settings
2) Database Settings
3) Organization
4) Resources
5) Create Admin User
6) Hierarchy
7) Data Warehouse Batch Export
8) Automatically Check for Updates
9) SUPReMM
q) Quit

Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q): 4
```

- Type `4` followed by `Enter` to continue.

You should be presented with the following sub-menu: 
```shell
========================================================================
Resources Setup
========================================================================

1) Add a new resource
2) List entered resources
s) Save (and return to main menu)

Select an option (1, 2, s):
```

Let's take a moment before adding a new resource and list the resources that have already been configured.

- Type `2` and press the `Enter` key.

```shell
========================================================================
Resources Added
========================================================================

Resource: hpc
Name: HPC
Type: hpc
Node count: 2
Processor count: 2
------------------------------------------------------------------------

Press ENTER to continue.
```

So we can see that we already have an hpc resource setup to represent our small SLURM cluster. With that in mind let's 
save our future selves some time by setting up an OnDemand resource that we will use in conjunction with the new 
Open Ondemand module that we'll be installing later on in the tutorial. Go ahead and press `Enter` to navigate back to 
the Resource sub-menu we were at previously. This time type `1` and press the `Enter` key to start the process of adding
a new Resource. 

```shell
========================================================================
Resources Setup
========================================================================

1) Add a new resource
2) List entered resources
s) Save (and return to main menu)

Select an option (1, 2, s): 1
```

#### Resource Name
The first piece of information you will be asked to provide is the Resource Name. This value has the same requirements 
as the Resource Abbreviation, all lowercase and no spaces.  

- Type `ondemand` and press the `Enter` key

```shell
========================================================================
Add A New Resource
========================================================================

The resource name you enter should match the name used by your resource
manager.  This is the resource name that you will need to specify during
the shredding process.  If you are using Slurm this must match the
cluster name used by Slurm.

Available resource types are:
HPC        - High-performance computing
HTC        - High-throughput computing
DIC        - Data-intensive computing
Grid       - Grid of resources
Cloud      - Cloud resource
Vis        - Visualization system
VM         - Virtual Machine system
Tape       - Tape storage resource
Disk       - Disk storage resource
StGrid     - Storage grid
US         - User Support
Gateway    - Web-based access to CI resources


Resource Name: ondemand
```

#### Formal Name

The Resource's Formal Name is the value that will be displayed by XDMoD to your end users.  

```shell
Formal Name: OnDemand
```

- Type `OnDemand` and press the `Enter` key.






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
