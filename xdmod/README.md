## Overview

**NOTE:**
Due to this tutorial being virtual and much shorter than anticipated; this part of the tutorial is going to be a bit more of an interactive demo. Some parts are going to be skipped over quicker than usual, however, our team is available in SLACK and Zoom chat to answer any questions that you may have.

In this part of the tutorial we are going to go over the installation and configuration of Open XDMoD.
The base component of Open XDMoD uses the job accounting logs from your HPC
resource manager as the data source. We have also installed the optional Job Performance Module. This allows Open XDMoD to also display performance data for HPC jobs.

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

---

## Open XDMoD Installation [Documentation](https://open.xdmod.org/9.5/install.html)

**Note** This part will be brief in the PEARC2021 tutorial. These processes have been done already as part of the docker.

For this tutorial, the Open XDMoD software will be installed in the `xdmod` container.
Open XDMoD will use the MySQL database from the `mysql` container. Since we
will also be installing the optional Job Performance module we also run
a MongoDB database in the `mongodb` container. The various runtime scripts to process
the Job accounting and Job performance data will all be run in the `xdmod` container.

The [`hpc-toolset-tutorial/xdmod/install.sh`](https://github.com/ubccr/hpc-toolset-tutorial/blob/master/xdmod/install.sh) script contains the step-by-step
instructions to install the packages.

Reference: [RPM Installation Guide](https://open.xdmod.org/install-rpm.html)

### Pre-Requisites Installation [Documentation](https://open.xdmod.org/9.5/software-requirements.html)

We need to install the "Extra Packages for Enterprise Linux" package so that we can install some further dependencies
```shell
[root@xdmod /] yum install -y epel-release   
```

### Open XDMoD RPM Installation [Documentation](https://open.xdmod.org/9.5/install-rpm.html)

```shell
[root@xdmod /] yum install -y https://github.com/ubccr/xdmod/releases/download/v9.5.0/xdmod-9.5.0-1.0.el7.noarch.rpm
```

--- 

## Open XDMoD Configuration [Documentation](https://open.xdmod.org/9.5/configuration.html)

**Note** This part will be brief in the PEARC2021 tutorial. These processes have been done already as part of the docker.

### System Configuration

PHP does not set a timezone by default, so we'll need to set one ourselves. We've selected `UTC` for this demo, but 
regardless of what timezone you end up using, the most important thing is to ensure that the XDMoD web server, the 
database server, and ideally the timezone of your HPC resources, are all set to the same time zone.

```shell
[root@xdmod /] sed -i 's/.*date.timezone[[:space:]]*=.*/date.timezone = UTC/' /etc/php.ini
```

### Prerequisites

The following information is needed by Open XDMoD:

- Name of the organization
- information for each HPC resource
    - Name
    - Number of compute nodes
    - Total Number of cores
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
To begin the setup process for XDMoD you will want to type the following: 
```shell
[root@xdmod /] xdmod-setup
```

After which you should be greeted by the following screen: 
```
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

The next series of steps will involve completing each numbered setup item in turn from 1-8. We will complete the SUPReMM
setup after we have successfully shredded, ingested, and aggregated the accounting data generated by the jobs we 
submitted at the beginning of this tutorial.

### General Settings [Documentation](https://open.xdmod.org/9.5/configuration.html#general-settings)

```shell
1) General Settings
```

- Press `1` followed by the `Enter` key to start the General Settings setup.

```shell 
Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q): 1
```

#### Site Address

The value you enter here should be the public facing URL that your XDMoD installation will be served from. For the 
purpose of this tutorial we'll be using the default value.

```
========================================================================
General Setup
========================================================================

The template Apache configuration file uses a virtual host
listening on HTTPS port 443. The Site Address specified
here should match the settings in the Apache configuration.

Site Address: [https://localhost:4443/]
```
*Note: values contained in `[ ]` are default values that can be used by simply pressing the `Enter` key. These values have been modified specifically for this tutorial and may be different from the values you encounter while installing XDMoD at your home institution.*

- Press the `Enter` key.

#### Email Address
This is the email address your XDMoD installation will use as the recipient of contact and user account requests.

```
The email address you specify will be used as the destination for any
messages sent via the portal contact page as well as account requests.  In
addition, any log messages configured for delivery via e-mail will be sent to
this address.

Email Address: [ccr-xdmod-help@buffalo.edu]
```
- Press the `Enter` key.

#### Chromium Path
XDMoD utilizes Chromium Headless to generate its images and reports, so the next step will be telling XDMoD where it can
be found.

```shell
Chromium Path: [/usr/lib64/chromium-browser/headless_shell]
```
- Press the `Enter` key.

#### Center Logo Path
XDMoD supports a customizable logo image that is displayed in the web portal. If you have an image you would like to use in branding your XDMoD 
installation you can provide the path to said image here.

```shell
You have the ability to specify a logo which will appear on the upper-right
hand region of the portal.  It is advised that the height of the logo be at
most 32 pixels.

The logo is referenced by its absolute path on the file system and must
be readable by the user/group your web server is running as.

Center Logo Path: [/srv/xdmod/small-logo.png]
```
 - Press the `Enter` key.

#### Center Logo Width ( in pixels )
If you do provide a custom center image, you will also need to provide its width in pixels.

```shell
Center Logo Width: [354]
```
- Press the `Enter` key to accept the default value.

#### XDMoD Dashboard [Documentation](https://open.xdmod.org/9.5/dashboard.html)
The XDMoD Dashboard provides users with targeted statistics and reports based on the level of 
access they've been granted in XDMoD. We highly recommend you turn this feature on in your installation.

```
This release of XDMoD features an optional replacement for the summary
tab that is intended to provide easier access to XDMoD's many features.
Detailed information is available at https://open.xdmod.org/dashboard.html

Enable Dashboard Tab (on, off)? [on]
```
- Press the `Enter` key.

You will now be prompted to overwrite the config file `/etc/xdmod/portal_settings.ini`. If you are satisfied that the 
information you have provided thus far is correct, then press the `Enter` key to save. 

If you need to change any of your answers then you can type `no`, press `Enter` and you will be taken back to the main 
setup menu. At which point you can press `1` and to go through the General Settings setup again.   

### Database Settings [Documentation](https://open.xdmod.org/9.5/configuration.html#database-settings)

Now that we've successfully completed the `General Settings` setup, we can move on to `Database Settings`.

```shell
2) Database Settings
```

Press `2` followed by the `Enter` key to start the Database Settings setup.

```shell 
Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q): 2
```
#### DB Hostname or IP

The first piece of information you will be prompted for is the Hostname or IP of the server that XDMoD's MySQL / 
MariaDB database is located on. In our case we have a separate container hosting our mysql instance andthat hostname has
been set as the default value. We can accept that value by pressing the `Enter` key.

*It's important to note that if you are setting up XDMoD for the first time and choose to have your database hosted on another server, you will need to have an SA database account created and allowed to log in from the XDMoD server. This SA account will only be used to create the more restricted db account and databases / schemas that are used during XDMoD's normal operation.*

```
========================================================================
Database Setup
========================================================================

Please provide the information required to connect to your MySQL database
server.  A user will be created using the username and password you provide.

NOTE: The database password cannot include single quote characters (') or
double quote characters (").

DB Hostname or IP: [mysql]
```
- Press the `Enter` key.

#### DB Port
Here you will enter the port that your database instance is exposed on. 

```shell
DB Port: [3306]
```
- Press the `Enter` key.

#### DB Username

This is the name of the restricted database account that XDMoD will use to function.

```shell
DB Username: [xdmodapp]
```
- Press the `Enter` key

#### DB Password

This will be the password for the DB account you entered in the last step. Please enter the following: `ofbatgorWep0`. 
Note that when you type the password the keystrokes will not be displayed on the screen. This is expected, when you are
done typing the password you can finish this step by pressing `Enter`.  

```shell
DB Password:
```
- Type `ofbatgorWep0` and press the `Enter` key.

You will then be prompted to type the password again to confirm your password choice.

```shell
(confirm) DB Password:
```
- Type `ofbatgorWep0` and press the `Enter` key.

#### Administrative DB Username
After confirming the password for XDMoD's database account, you will be prompted for the username and password of the 
admin account. 

```
Please provide the password for the administrative account that will be
used to create the MySQL user and databases.

DB Admin Username: [root]
```
- Press the `Enter` key.

#### Administrative DB User Password

We will next enter the administrative DB User's password. In our case that is an empty password. 

*Note, a blank password should never be used in a production system. We only do it here for ease of use during the tutorial.*

```shell
DB Admin Password:
```
- Press the `Enter` key.

You will again be prompted to confirm the password you just entered, or lack there of.

```shell
(confirm) DB Admin Password:
```
- Press the `Enter` key.

If you have supplied the correct database credentials then you should be presented with the following message. 

```shell
Creating User xdmodapp
```

#### Database Maintenance

Now that we have our database user created, the setup will proceed to detect if the databases XDMoD utilizes are 
present. If they are then it will ask if you want to drop and recreate them.

```shell
Database `mod_shredder` already exists.
Drop and recreate database (yes, no)? [no]
```
- Type `yes` and press the `Enter` key.

For the purposes of this tutorial we will want to enter `yes` followed by pressing `Enter` each time we are prompted.

If successful you should see the following information: 
```shell
Dropping database `mod_shredder`.
Creating database `mod_shredder`.
Granting privileges on database `mod_shredder`.
Initializing database `mod_shredder`.
```

You should receive the same prompt for the following databases:
- `mod_shredder`
- `mod_hpcdb`
- `moddb`
- `modw`
- `modw_aggregates`
- `modw_filters`
- `mod_logger`

After you have dropped and re-created all of these databases you will be prompted to save the information you have entered
to the config file `/etc/xdmod/portal_settings.ini`. 

```shell
Overwrite config file '/etc/xdmod/portal_settings.ini' (yes, no)? [yes]
```

- Press the `Enter` key.

If all goes well than you will see: 
```shell
Settings saved.

Press ENTER to continue.
```
- Press the `Enter` key again, this will return you to the main setup menu.

### Organization Settings [Documentation](https://open.xdmod.org/9.5/configuration.html#organization-settings)

```shell
3) Organization
```

With the database settings taken care of we can move on to setting up our Organization.

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

- Type `3` followed by `Enter`

#### Organization Name
The first piece of information you will be prompted for is your organization's name. This will be what's displayed to
your end users when XDMoD displays organization information. You can enter any value you'd like or accept the default
value.

```shell
========================================================================
Organization Setup
========================================================================

Organization Name: [Tutorial]
```
- Either type your desired Organization Name and press the `Enter` key or just press the `Enter` key to accept the default value.

#### Organization Abbreviation
This value should be a string of all lowercase letters with no spaces to be used as an abbreviation for your 
organization. You can again enter any value that conforms to these requirements or accept the default value.

```shell
Organization Abbreviation: [hpcts]
```
- Either type your desired Organization Abbreviation and press the `Enter` key or just press the `Enter` key to accept the default value.

You will then be prompted to save these values to the organization configuration file. If you are satisfied with the 
values you have entered than press `Enter` to continue. If not then type `no`, press `Enter` and re-enter the 
Organization configuration menu by typing `3` and pressing `Enter`.

```shell
Overwrite config file '/etc/xdmod/organization.json' (yes, no)? [yes]
```
- Press the `Enter` key.

### Resource Setup [Documentation](https://open.xdmod.org/configuration.html#resources)

Next we will go through the process of adding a Resource to XDMoD. 

```
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
the Resource sub-menu we were at previously. This time we'll select the `Add a new resource` option.

```shell
========================================================================
Resources Setup
========================================================================

1) Add a new resource
2) List entered resources
s) Save (and return to main menu)

Select an option (1, 2, s): 1
```
- Type `1` and press the `Enter` key.

#### Resource Name
The first piece of information you will be asked to provide is the Resource Name. This value has the same requirements 
as the Resource Abbreviation, all lowercase and no spaces.  

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

- Type `ondemand` and press the `Enter` key

#### Formal Name

The Resource's Formal Name is the value that will be displayed by XDMoD to your end users.  

```shell
Formal Name: OnDemand
```

- Type `OnDemand` and press the `Enter` key.

#### Resource Type

The Resource Type is used to determine if various modules should be displayed to the user. i.e. if you don't have a 
`cloud` resource setup than you aren't ingesting cloud data so there's no reason to show the Cloud Realm. 

For the OnDemand resource we'll want to select the `gateway` resource type.

```shell
Resource Type (hpc, htc, dic, grid, cloud, vis, vm, tape, disk, stgrid, us, gateway): [hpc]
```

- Type `gateway` and press the `Enter` key.

#### Resource Nodes
For a general HPC-type resource you will want to enter the number of nodes the resource has here. In our case, as we're
adding a gateway resource it doesn't really have nodes or cores per se, so we'll enter 0 for both as if it were a 
storage resource. 

```
The number of nodes and processors are used to determine resource
utilization.

If this is a storage resource you may enter 0 for the number of nodes
and processors.

How many nodes does this resource have?
```

- Type `0` and press the `Enter` key.


```shell
How many total processors (cpu cores) does this resource have?
```  

- Type `0` and press the `Enter` key.


#### Saving the newly added OnDemand Resource

Now that the OnDemand Resource has been added all that's left to do is to save it and continue on with the rest of
XDMoD's configuration.

```shell
========================================================================
Resources Setup
========================================================================

1) Add a new resource
2) List entered resources
s) Save (and return to main menu)

Select an option (1, 2, s): s
```
- Type `s` and press the `Enter` key.

You will then be prompted to overwrite the resource configuration file

```shell
Overwrite config file '/etc/xdmod/resources.json' (yes, no)? [yes]
```

- Press the `Enter` key to accept the default value of `yes`.

If all goes well you will see the following: 
```shell
Writing configuration to '/etc/xdmod/resources.json'

Settings saved.

Press ENTER to continue.
```
- Press the `Enter` key.

You will then be prompted to save the resource_specs configuration file

```shell
Overwrite config file '/etc/xdmod/resource_specs.json' (yes, no)? [yes]
```

- Press the `Enter` key to accept the default value of `yes`. 

You should see the same messages as were provided when you chose to save `resources.json`, this time for `resource_specs.json`

```shell
Writing configuration to '/etc/xdmod/resource_specs.json'

Settings saved.

Press ENTER to continue.
```

- Press the `Enter` key once more to be taken back to the main XDMoD configuration menu.

## Create Admin User [Documentation](https://open.xdmod.org//configuration.html#create-admin-user)

```shell
5) Create Admin User
```
The XDMoD Admin user has access to the XDMoD admin dashboard. The admin dashboard is used to manage XDMoD portal user
accounts and view log information. 

```
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

Select an option (1, 2, 3, 4, 5, 6, 7, 8, 9, q): 5
```
- Type `5` and press the `Enter` key.

The first value you will be prompted for is the Admin user's username.

```shell
========================================================================
Create Admin User
========================================================================

Username:
```
- Type `admin` and press the `Enter` key.

Next, it will prompt for the user's password. 
```shell
Password:
```
- Type `admin123` and press the `Enter` key.

It will next ask us to confirm the password we just entered.
```shell
(confirm) Password:
```
- Type `admin123` and press the `Enter` key.
*Make a note of this user's username and password as we'll be using it later*

If the two passwords match, then it will proceed to gathering the user's first name.
```shell
First name: XDMoD

```
- Type `XDMoD` and press the `Enter` key.

Followed by the user's last name
```shell
Last name: Admin
```
- Type `Admin` and press the `Enter` key.

Finally, it will ask for the email address to associate with the admin user. 
```shell
Email address: xdmod.admin@xdmod.com
```
- Type `xdmod.admin@xdmod.com` and press the `Enter` key.

So long as all the information has been entered correctly you should now see.
```shell
Admin user created.

Press ENTER to continue.
```

## Hierarchy Setup [Documentation](https://open.xdmod.org/hierarchy.html)

```shell
6) Hierarchy
```

XDMoD supports a three level organizational hierarchy. By default, this is based on the hierarchy in use at the 
University at Buffalo.
- Top Level:    Decanal Unit
- Middle Level: Department
- Bottom Level: PI Group

- Type `6` and press the `Enter` key.

```
========================================================================
Hierarchy Setup
========================================================================

Specify the levels (top, middle, and bottom) in your organization which would
be analogous to the following structure:

Top Level: Decanal Unit
Middle Level: Department
Bottom Level: PI Group

Top Level Name: [Decanal Unit]
```

For this tutorial we're going to leave the Hierarchy with its default values, but if you are setting this up for production
then please see our [Hierarchy Guide](https://open.xdmod.org//hierarchy.html) as it will more completely describe how
the hierarchy works as well as how to populate it.

```shell
========================================================================
Hierarchy Setup
========================================================================

Specify the levels (top, middle, and bottom) in your organization which would
be analogous to the following structure:

Top Level: Decanal Unit
Middle Level: Department
Bottom Level: PI Group

Top Level Name: [Decanal Unit]
Top Level Description: [Decanal Unit]
Middle Level Name: [Department]
Middle Level Description: [Department]
Bottom Level Name: [PI Group]
Bottom Level Description: [PI Group]

Overwrite config file '/etc/xdmod/hierarchy.json' (yes, no)? [yes]
```

- Press the `Enter` key to accept the default value of `yes`

If the save is successful than you should see the following: 
```shell
Writing configuration to '/etc/xdmod/hierarchy.json'

Settings saved.

Press ENTER to continue.
```

- Press the `Enter` key to continue.

## Data Warehouse Batch Export [Documentation](https://open.xdmod.org/dw-export.html#configuration)

```shell
7) Data Warehouse Batch Export
```

The Data Warehouse Batch Export feature gives users access to the raw underlying data contained within Open XDMoD's data
warehouse. This configuration option allows for an administrator to set which directory will be used to contain the 
exports, as well as how long those exports will be kept on disk.

We'll quickly go through the configuration now

- Type `7` and press the `Enter` key

#### Export Directory
The first value we're prompted to provide is the export directory. This is the directory that will be used when saving 
the data from a user request. 


```
========================================================================
Data Warehouse Batch Export
========================================================================

The data warehouse batch export feature allows users to create requests to
export data which is then generated by a cron job and stored on the server.
The directory where this data is stored and the duration that the data will be
retained are configurable.

Export Directory: [/var/spool/xdmod/export]
```

- Press the `Enter` key to accept the default value.

#### Export File Retention Duration
Next you will be prompted to enter the number of days these exports should be retained on disk.

```
If the export directory does not exist, it must be created and assigned the
correct permissions and ownership.  It must be readable by the web server and
both readable and writable by the user that is used to generate the export
files.  By default, the web server user is expected to be apache and
the group is expected to be xdmod.  If your system uses a different
user and group then the automatic process will fail and you must set the
permissions manually.

Export File Retention Duration in Days: [31]
```

- Press the `Enter` key to accept the default value.

You should then be prompted to save these settings in the `portal_settings.ini` file
```shell
Overwrite config file '/etc/xdmod/portal_settings.ini' (yes, no)? [yes]
```

- Press the `Enter` key to accept the default value.

If the save is successful then you should see the following:
```shell
Writing configuration to '/etc/xdmod/portal_settings.ini'

Settings saved.

Press ENTER to continue.
```

### Automatically Check for Updates

```
8) Automatically Check for Updates
```

This is the final piece of setup that, while not strictly necessary for a fully operational Open XDMoD installation, 
means you will be kept up to date when the newest version is released.

- Type `8` and press the `Enter` key.

---
========================================================================
Automatic Update Check Setup
========================================================================

When enabled, Open XDMoD will periodically connect to a remote server to
check if a new version of Open XDMoD is available.  After a new version
has been released you will recieve an email.

You may also subscribe to our mailing list at:
http://listserv.buffalo.edu/cgi-bin/wa?SUBED1=ccr-xdmod-list&A=1

Enable automatic update check (yes, no)? [yes]
```
- Press `Enter` to accept the default value of `yes`

This feature will both notify you when we release new versions of XDMoD and also let's us know who is using XDMoD which 
helps us justify our funding to NSF.

#### Email Address
If you enable the automatic update check, then you will be prompted for the email address that should receive the update
notice. 

```shell
Email address: [ccr-xdmod-help@buffalo.edu]
```

- press the `Enter` key to accept the default value.

#### Name

```shell
Name:
```

- Type any value you'd like and press the `Enter` key 

#### Organization

```shell
Organization: [Tutorial]
```

- Press the `Enter` key to accept the default value.

You should now be prompted to overwrite the `update_check.json` file 
```shell
Overwrite config file '/etc/xdmod/update_check.json' (yes, no)? [yes]
```

- Press `Enter` to accept the default value of `yes`

If the save is successful then you will see the following: 
```shell
Writing configuration to '/etc/xdmod/update_check.json'

Settings saved.

Press ENTER to continue.
```
- Press `Enter` to continue

#### Advanced Configuration

The `xdmod-setup` script is used for the basic setup of Open XDMoD. The script includes options to configure the Open
XDMoD database, set up the admin user account and configure resources. Open XDMoD's
[Configuration](https://open.xdmod.org/configuration.html#location-of-configuration-files) files can be modified
directly when needing more advanced customization.

## Congratulations! Your XDMoD instance should now be fully configured! 

Now that we have XDMoD setup, it's time to ingest some data. The jobs that we started at the beginning of the tutorial 
should be complete so let's walk through the shred, ingest, and aggregate steps for job accounting data.

### Shredding [Documentation](https://open.xdmod.org/shredder.html)
XDMoD provides a special command line tool for working with directly with slurm via `sacct` called `xdmod-slurm-helper`.
To see what command line arguments it accepts you can run `xdmod-slurm-helper -h`. For our purposes we will be using it
as follows: 

```shell
[root@xdmod ~] sudo -u xdmod xdmod-slurm-helper -r hpc --start-time $yesterday --end-time $tomorrow
```
*Note, you will need to replace `$yesterday` and `$tomrrow` with their respective values in YYYY-MM-DD format.*

If your organization doesn't use Slurm or will be using the log files instead of querying `sacct` directly, then 
`xdmod-shredder` will be the command for you. You can find our Shredder guide at [Shredder Guide](https://open.xdmod.org/shredder.html)

Upon running `xdmod-slurm-helper` you should see output similar to: 
```shell
2021-07-15 20:20:03 [notice] xdmod-slurm-helper start (process_start_time: 2021-07-15 20:20:03)
2021-07-15 20:20:03 [notice] Shredding file '/tmp/sacct-log-hpc-0jZjXr'
2021-07-15 20:20:03 [notice] Shredded 18 records
2021-07-15 20:20:03 [notice] Normalizing data
2021-07-15 20:20:03 [notice] Finished ingestion (class: PDODBMultiIngestor, start_time: 1626380403.9138, end_time: 1626380403.9264, records_examined: 18, records_loaded: 18)
2021-07-15 20:20:03 [notice] Done normalizing data
2021-07-15 20:20:03 [notice] xdmod-slurm-helper end (process_end_time: 2021-07-15 20:20:03)
[root@xdmod ~]#
```

### Ingesting & Aggregating [Documentation](https://open.xdmod.org/ingestor.html)
Now that the accounting logs have been shredded we can now ingest and aggregate the information from them, thus making the 
information available in XDMoD.

```shell
[root@xdmod ~] sudo -u xdmod xdmod-ingestor
```

This will produce **A LOT** of output:
```shell
2021-07-15 20:28:38 [notice] xdmod-ingestor start (process_start_time: 2021-07-15 20:28:38)
2021-07-15 20:28:38 [notice] Start processing section 'xdmod.staging-ingest-common'
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-common.organization (ETL\Ingestor\StructuredFileIngestor), start_time: 1626380918.5262, end_time: 1626380918.594, elapsed_time: 0.06779, records_examined: 1, records_loaded: 1)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-common.resource-types (ETL\Ingestor\StructuredFileIngestor), start_time: 1626380918.5976, end_time: 1626380918.6714, elapsed_time: 0.07374, records_examined: 12, records_loaded: 12)
2021-07-15 20:28:38 [notice] Processing SQL file '/etc/xdmod/etl/etl_sql.d/cloud_openstack/unknown_resource_type.sql' using delimiter '//' containing 2 statements
2021-07-15 20:28:38 [notice] Finished Processing 2 SQL statements
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-common.ResourceTypesStagingUnknown (ETL\Maintenance\ExecuteSql), start_time: 1626380918.6748, end_time: 1626380918.6818, elapsed_time: 0.007)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-common.resource-config (ETL\Ingestor\StructuredFileIngestor), start_time: 1626380918.6845, end_time: 1626380918.7183, elapsed_time: 0.03379, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-common.resources (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.7218, end_time: 1626380918.7392, elapsed_time: 0.01741, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-common.resource-specs (ETL\Ingestor\StructuredFileIngestor), start_time: 1626380918.7427, end_time: 1626380918.7715, elapsed_time: 0.02878, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:38 [notice] Finished processing section 'xdmod.staging-ingest-common'
2021-07-15 20:28:38 [notice] Start processing section 'xdmod.staging-ingest-jobs'
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.pi-resource (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.7769, end_time: 1626380918.7953, elapsed_time: 0.01833, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.pi (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.7987, end_time: 1626380918.8165, elapsed_time: 0.01786, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.resource (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.8202, end_time: 1626380918.8355, elapsed_time: 0.01527, records_examined: 0, records_loaded: 0)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.union-user-pi--pi (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.8393, end_time: 1626380918.8568, elapsed_time: 0.01747, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.union-user-pi--user (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.8604, end_time: 1626380918.8758, elapsed_time: 0.0154, records_examined: 0, records_loaded: 0)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.union-user-pi-resource--pi (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.8793, end_time: 1626380918.897, elapsed_time: 0.01768, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.union-user-pi-resource--user (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.9009, end_time: 1626380918.9165, elapsed_time: 0.01564, records_examined: 0, records_loaded: 0)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.user-pi-resource (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.9205, end_time: 1626380918.9394, elapsed_time: 0.01891, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:38 [notice] (action: xdmod.staging-ingest-jobs.job (ETL\Ingestor\DatabaseIngestor), start_time: 1626380918.9435, end_time: 1626380918.9639, elapsed_time: 0.02039, records_examined: 18, records_loaded: 18)
2021-07-15 20:28:38 [notice] Finished processing section 'xdmod.staging-ingest-jobs'
2021-07-15 20:28:39 [notice] Start processing section 'xdmod.hpcdb-ingest-common'
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.resource-types (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.1505, end_time: 1626380919.1685, elapsed_time: 0.01802, records_examined: 13, records_loaded: 13)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.organizations (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.1724, end_time: 1626380919.1908, elapsed_time: 0.01847, records_examined: 1, records_loaded: 1)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.resources (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.1946, end_time: 1626380919.2138, elapsed_time: 0.01921, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.resource-specs (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.2175, end_time: 1626380919.2366, elapsed_time: 0.019, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.resource-allocated (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.2406, end_time: 1626380919.2594, elapsed_time: 0.01885, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.accounts (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.2633, end_time: 1626380919.2817, elapsed_time: 0.01841, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.allocations (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.2854, end_time: 1626380919.3043, elapsed_time: 0.0189, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.people (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.3082, end_time: 1626380919.3274, elapsed_time: 0.01924, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.requests (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.3313, end_time: 1626380919.3507, elapsed_time: 0.01946, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.allocation-breakdown (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.3549, end_time: 1626380919.3739, elapsed_time: 0.01907, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.allocations-on-resources (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.3777, end_time: 1626380919.3966, elapsed_time: 0.01885, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.email-addresses (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.4003, end_time: 1626380919.4188, elapsed_time: 0.01849, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.principal-investigators (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.4226, end_time: 1626380919.4414, elapsed_time: 0.01882, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-common.system-accounts (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.4453, end_time: 1626380919.4645, elapsed_time: 0.01921, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] Finished processing section 'xdmod.hpcdb-ingest-common'
2021-07-15 20:28:39 [notice] Start processing section 'xdmod.hpcdb-ingest-jobs'
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-ingest-jobs.jobs (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.4706, end_time: 1626380919.4939, elapsed_time: 0.02328, records_examined: 18, records_loaded: 18)
2021-07-15 20:28:39 [notice] Finished processing section 'xdmod.hpcdb-ingest-jobs'
2021-07-15 20:28:39 [notice] Start processing section 'xdmod.hpcdb-prep-xdw-job-ingest-by-new-jobs'
2021-07-15 20:28:39 [notice] Table `mod_hpcdb`.`hpcdb_jobs_to_ingest` does not exist, creating.
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-prep-xdw-job-ingest-by-new-jobs.jobs (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.598, end_time: 1626380919.62, elapsed_time: 0.02205, records_examined: 18, records_loaded: 18)
2021-07-15 20:28:39 [notice] Finished processing section 'xdmod.hpcdb-prep-xdw-job-ingest-by-new-jobs'
2021-07-15 20:28:39 [notice] Start processing section 'xdmod.hpcdb-xdw-ingest-common'
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-xdw-ingest-common.account (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.8678, end_time: 1626380919.8866, elapsed_time: 0.01876, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-xdw-ingest-common.allocation-breakdown (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.8902, end_time: 1626380919.9084, elapsed_time: 0.01819, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-xdw-ingest-common.allocation (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.9123, end_time: 1626380919.932, elapsed_time: 0.0197, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-xdw-ingest-common.resource (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.9358, end_time: 1626380919.9556, elapsed_time: 0.0198, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:39 [notice] (action: xdmod.hpcdb-xdw-ingest-common.allocation-on-resource (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.9595, end_time: 1626380919.9779, elapsed_time: 0.0184, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.field-of-science (ETL\Ingestor\DatabaseIngestor), start_time: 1626380919.9817, end_time: 1626380920.0004, elapsed_time: 0.0187, records_examined: 1, records_loaded: 1)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.field-of-science-hierarchy (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.0042, end_time: 1626380920.0379, elapsed_time: 0.03364, records_examined: 1, records_loaded: 1)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.organization (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.0417, end_time: 1626380920.0759, elapsed_time: 0.03423, records_examined: 1, records_loaded: 1)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.pi-person (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.0796, end_time: 1626380920.1129, elapsed_time: 0.03332, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.person (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.1168, end_time: 1626380920.1526, elapsed_time: 0.03573, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.people-under-pi (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.158, end_time: 1626380920.178, elapsed_time: 0.01995, records_examined: 0, records_loaded: 0)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.principal-investigator (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.1817, end_time: 1626380920.2017, elapsed_time: 0.01998, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.request (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.207, end_time: 1626380920.2317, elapsed_time: 0.0247, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.resource-type (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.2373, end_time: 1626380920.2602, elapsed_time: 0.02289, records_examined: 13, records_loaded: 13)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.resource-spec (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.2641, end_time: 1626380920.2835, elapsed_time: 0.01938, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.resource-allocated (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.2877, end_time: 1626380920.307, elapsed_time: 0.0193, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.service-provider (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.3111, end_time: 1626380920.329, elapsed_time: 0.01792, records_examined: 1, records_loaded: 1)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-common.system-account (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.3331, end_time: 1626380920.3515, elapsed_time: 0.01838, records_examined: 3, records_loaded: 3)
2021-07-15 20:28:40 [notice] Finished processing section 'xdmod.hpcdb-xdw-ingest-common'
2021-07-15 20:28:40 [notice] Start processing section 'xdmod.hpcdb-xdw-ingest-jobs'
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-jobs.node-count (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.3577, end_time: 1626380920.3768, elapsed_time: 0.01904, records_examined: 2, records_loaded: 2)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-jobs.queue (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.3807, end_time: 1626380920.3985, elapsed_time: 0.01787, records_examined: 1, records_loaded: 1)
2021-07-15 20:28:40 [notice] SQL warnings on table 'hosts' generated by action xdmod.hpcdb-xdw-ingest-jobs.hosts (filtering codes: 1062)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-jobs.hosts (ETL\Ingestor\HpcdbHostsIngestor), start_time: 1626380920.4022, end_time: 1626380920.4638, elapsed_time: 0.06155, records_examined: 27, records_loaded: 27)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-jobs.job-hosts (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.4676, end_time: 1626380920.4863, elapsed_time: 0.01869, records_examined: 27, records_loaded: 27)
2021-07-15 20:28:40 [notice] Processing SQL file '/etc/xdmod/etl/etl_sql.d/jobs/jobhosts-post-ingest-truncate.sql' using delimiter '//' containing 1 statements
2021-07-15 20:28:40 [notice] Finished Processing 1 SQL statements
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-jobs.jobhosts-post-truncate (ETL\Maintenance\ExecuteSql), start_time: 1626380920.4901, end_time: 1626380920.4943, elapsed_time: 0.00423)
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-jobs.job-records-job-tasks (ETL\Ingestor\DatabaseIngestor), start_time: 1626380920.4972, end_time: 1626380920.6029, elapsed_time: 0.10574, records_examined: 18, records_loaded: 18)
2021-07-15 20:28:40 [notice] Processing SQL file '/etc/xdmod/etl/etl_sql.d/jobs/job-record-hpc-post-ingest.sql' using delimiter '//' containing 2 statements
2021-07-15 20:28:40 [notice] Finished Processing 2 SQL statements
2021-07-15 20:28:40 [notice] (action: xdmod.hpcdb-xdw-ingest-jobs.HpcdbPostIngestJobUpdates (ETL\Maintenance\ExecuteSql), start_time: 1626380920.6067, end_time: 1626380920.6135, elapsed_time: 0.00678)
2021-07-15 20:28:40 [notice] Finished processing section 'xdmod.hpcdb-xdw-ingest-jobs'
2021-07-15 20:28:46 [notice] Start processing section 'xdmod.jobs-xdw-aggregate'
2021-07-15 20:28:46 [notice] Table `modw_aggregates`.`jobfact_by_day_joblist` does not exist, creating.
2021-07-15 20:28:46 [notice] (action: xdmod.jobs-xdw-aggregate.table-create (ETL\Maintenance\ManageTables), start_time: 1626380926.381, end_time: 1626380926.397, elapsed_time: 0.016)
2021-07-15 20:28:46 [notice] Table `modw_aggregates`.`jobfact_by_day` does not exist, creating.
2021-07-15 20:28:46 [notice] aggregate start (action: xdmod.jobs-xdw-aggregate.aggregate-days (ETL\Aggregator\JobListAggregator), unit: day, start_date: none, end_date: none)
2021-07-15 20:28:46 [notice] aggregate end (action: xdmod.jobs-xdw-aggregate.aggregate-days (ETL\Aggregator\JobListAggregator), unit: day, periods: 1, start_date: none, end_date: none, start_time: 1626380926.412, end_time: 1626380926.4408, elapsed_time: 0.02877)
2021-07-15 20:28:46 [notice] end (action: xdmod.jobs-xdw-aggregate.aggregate-days (ETL\Aggregator\JobListAggregator), start_time: 1626380926.4001, end_time: 1626380926.4442, elapsed_time: 0.001m)
2021-07-15 20:28:46 [notice] Table `modw_aggregates`.`jobfact_by_month` does not exist, creating.
2021-07-15 20:28:46 [notice] aggregate start (action: xdmod.jobs-xdw-aggregate.aggregate (ETL\Aggregator\SimpleAggregator), unit: month, start_date: none, end_date: none)
2021-07-15 20:28:46 [notice] aggregate end (action: xdmod.jobs-xdw-aggregate.aggregate (ETL\Aggregator\SimpleAggregator), unit: month, periods: 1, start_date: none, end_date: none, start_time: 1626380926.4589, end_time: 1626380926.4874, elapsed_time: 0.02848)
2021-07-15 20:28:46 [notice] Table `modw_aggregates`.`jobfact_by_quarter` does not exist, creating.
2021-07-15 20:28:46 [notice] aggregate start (action: xdmod.jobs-xdw-aggregate.aggregate (ETL\Aggregator\SimpleAggregator), unit: quarter, start_date: none, end_date: none)
2021-07-15 20:28:46 [notice] aggregate end (action: xdmod.jobs-xdw-aggregate.aggregate (ETL\Aggregator\SimpleAggregator), unit: quarter, periods: 1, start_date: none, end_date: none, start_time: 1626380926.5013, end_time: 1626380926.5299, elapsed_time: 0.02859)
2021-07-15 20:28:46 [notice] Table `modw_aggregates`.`jobfact_by_year` does not exist, creating.
2021-07-15 20:28:46 [notice] aggregate start (action: xdmod.jobs-xdw-aggregate.aggregate (ETL\Aggregator\SimpleAggregator), unit: year, start_date: none, end_date: none)
2021-07-15 20:28:46 [notice] Duplicate column after substitution: ("${aggregation_unit}: ${:PERIOD_VALUE}") '${aggregation_unit}' -> 'year'
2021-07-15 20:28:46 [notice] aggregate end (action: xdmod.jobs-xdw-aggregate.aggregate (ETL\Aggregator\SimpleAggregator), unit: year, periods: 1, start_date: none, end_date: none, start_time: 1626380926.5435, end_time: 1626380926.574, elapsed_time: 0.0306)
2021-07-15 20:28:46 [notice] end (action: xdmod.jobs-xdw-aggregate.aggregate (ETL\Aggregator\SimpleAggregator), start_time: 1626380926.447, end_time: 1626380926.5776, elapsed_time: 0.002m)
2021-07-15 20:28:46 [notice] (action: xdmod.jobs-xdw-aggregate.aggregation-joblist (ETL\Ingestor\ExplodeTransformIngestor), start_time: 1626380926.5806, end_time: 1626380926.6315, elapsed_time: 0.0509, records_examined: 18, records_loaded: 18)
2021-07-15 20:28:46 [notice] Finished processing section 'xdmod.jobs-xdw-aggregate'
2021-07-15 20:28:46 [notice] start (action: Jobs.build-filter-list)
2021-07-15 20:28:46 [notice] start (action: Jobs.build-filter-list.provider)
2021-07-15 20:28:46 [notice] end (action: Jobs.build-filter-list.provider, start_time: 1626380926.684, end_time: 1626380926.7636)
2021-07-15 20:28:46 [notice] start (action: Jobs.build-filter-list.pi)
2021-07-15 20:28:46 [notice] end (action: Jobs.build-filter-list.pi, start_time: 1626380926.7648, end_time: 1626380926.8055)
2021-07-15 20:28:46 [notice] start (action: Jobs.build-filter-list.person)
2021-07-15 20:28:46 [notice] end (action: Jobs.build-filter-list.person, start_time: 1626380926.8067, end_time: 1626380926.8272)
2021-07-15 20:28:46 [notice] start (action: Jobs.build-filter-list.queue)
2021-07-15 20:28:46 [notice] end (action: Jobs.build-filter-list.queue, start_time: 1626380926.8285, end_time: 1626380926.9076)
2021-07-15 20:28:46 [notice] start (action: Jobs.build-filter-list.resource)
2021-07-15 20:28:46 [notice] end (action: Jobs.build-filter-list.resource, start_time: 1626380926.9088, end_time: 1626380926.9873)
2021-07-15 20:28:46 [notice] start (action: Jobs.build-filter-list.username)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.username, start_time: 1626380926.9885, end_time: 1626380927.068)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.resource_type)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.resource_type, start_time: 1626380927.0692, end_time: 1626380927.1471)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.parentscience)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.parentscience, start_time: 1626380927.1483, end_time: 1626380927.2279)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.nsfdirectorate)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.nsfdirectorate, start_time: 1626380927.2292, end_time: 1626380927.3178)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.jobwaittime)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.jobwaittime, start_time: 1626380927.3189, end_time: 1626380927.4025)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.gpucount)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.gpucount, start_time: 1626380927.4037, end_time: 1626380927.4873)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.jobsize)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.jobsize, start_time: 1626380927.4886, end_time: 1626380927.5723)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.fieldofscience)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.fieldofscience, start_time: 1626380927.5734, end_time: 1626380927.6583)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.jobwalltime)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.jobwalltime, start_time: 1626380927.6595, end_time: 1626380927.7376)
2021-07-15 20:28:47 [notice] start (action: Jobs.build-filter-list.nodecount)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list.nodecount, start_time: 1626380927.7388, end_time: 1626380927.8241)
2021-07-15 20:28:47 [notice] end (action: Jobs.build-filter-list, start_time: 1626380926.6387, end_time: 1626380927.8256)
2021-07-15 20:28:47 [notice] Cloud realm not enabled, not aggregating
2021-07-15 20:28:47 [notice] Storage realm not enabled, not aggregating
2021-07-15 20:28:47 [notice] xdmod-ingestor end (process_end_time: 2021-07-15 20:28:47)
[root@xdmod ~]
```

Congratulations! You should now have a fully configured and populated ( with job accounting data ) XDMoD instance up and running.

---

### Explore the XDMoD interface
With a fully installed system we have quite a bit of data. Job information, Storage Usage, Cloud Usage, Job Performance (SUPREMM)
![Public User Usage](./tutorial-screenshots/public-user-options.png)

User Dashboard:
![Logged in User Dashboard](./tutorial-screenshots/loggedin-dashboard.png)

PI:
![Logged in PI Dashboard](./tutorial-screenshots/loggedin-pi-dashboard.png)

Center Staff:
![Logged in Center Staff Dashboard](./tutorial-screenshots/centerdirector-dashboard.png)

Report Generator:
![Report Generator](./tutorial-screenshots/report-generator.png)

### Import User Names & Re-Ingest / Aggregate
**NOTE**: This part of the tutorial does not impact the functioning of XDMoD, but it does make the information XDMoD provides more human-readable.

The resource manager logs contain the system usernames of the users that submitted jobs.
To display the full names in Open XDMoD you must provide a data file that contains the
full name of each user for each system username. This file is in a `csv` format.

![Group By User(names not imported)](./tutorial-screenshots/usernames.png)

This step has not been automated as we don't want you falling asleep!

Login to frontend via SSH and user: `hpcadmin` password: `ilovelinux`:

```shell
[awesome_pearc_attendant@home_box /] ssh -p6222 hpcadmin@localhost
```

SSH to the xdmod container:

```shell
[hpcadmin@frontend /] ssh xdmod
```

Change users to root

```shell
[hpcadmin@xdmod /] sudo su - 
```

Create a file as shown below: ( The file needs to be able to be read by the `xdmod` user, for this demo it will be created in /var/tmp )

```shell
[root@xdmod /] sudo -u xdmod vim /var/tmp/names.csv 
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

```shell
[root@xdmod /] sudo -u xdmod xdmod-import-csv -t names -i /var/tmp/names.csv 
```

Next we will need to re-ingest and aggregate the data:

```shell
[root@xdmod /] sudo -u xdmod /srv/xdmod/scripts/shred-ingest-aggregate-all.sh 
```

![Group By User](./tutorial-screenshots/fullnames.png)

Reference: [User/PI Names Guide](https://open.xdmod.org/user-names.html)

xdmod-import-csv -t names:
[![asciicast](https://asciinema.org/a/349325.svg)](https://asciinema.org/a/349325)

### Configure Job Performance Module
[Job Performance](https://supremm.xdmod.org) data - for the open source release we try to provide support for [Performance Co-Pilot (PCP)](https://pcp.io).
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

### Ingest Job Performance Data

To ingest the Job Performance Data we will need to run a couple of commands:

```shell
[root@xdmod /] sudo -u xdmod indexarchives.py -m $yesterday -m $tomorrow
```
*Note, you will need to replace `$yesterday` and `$tomorrow` with YYYY-MM-DD formatted dates as we did previously* 

To summarize the newly ingested Job Performance data we will run:
```shell
[root@xdmod /] sudo -u xdmod summarize_jobs.py
```

Finally, to aggregate the Job Performance data: 
```shell
[root@xdmod /] sudo -u xdmod aggregate_supremm.sh
```

*Note, there is a helper script that will take care of running the full Job Accounting and Job Performance scripts that you can run. `/srv/xdmod/scripts/shred-ingest-aggregate-all.sh`* 

---

## xdmod-ondemand module
The xdmod-ondemand module is an optional addon for XDMoD that allows the display
and analysis of Open OnDemand usage. This is intended to be used by HPC center
staff to analyse who, how and what OnDemand is used.

### Prerequisites
Since the xdmod-ondemand module displays usage of Open OnDemand you need to
have used Open OnDemand! The xdmod container includes an example log
file generated from Open OnDemand so there is data to show in XDMoD.

### Installation
The xdmod-ondemand RPM is already installed on the `xdmod` instance. To install
it manually you would run the following:
```shell
[hpcadmin@xdmod /] sudo yum install -y https://github.com/ubccr/xdmod-ondemand/releases/download/v10.0.0/xdmod-ondemand-10.0.0-1.0.el7.noarch.rpm
```

### Configuration
The setup of the OnDemand module involves using the interactive `xdmod-setup` tool
to initialize the database tables and to add a resource.
The module has been configured in the container already.  The following instuctions
step through how this was performed, but do not need to be manually run.
```bash
[root@xdmod /] xdmod-setup
```

To continue, we'll select the Open OnDemand menu item: 
```shell
10) Open OnDemand
```
- Type `10` and press `Enter`

You should now see the Open OnDemand setup sub-menu: 
```shell
========================================================================
Open OnDemand module setup
========================================================================

d) Setup database
q) Quit configuration

Select an option (d, q):
```

Next, we'll want to set up the database
```shell
Select an option (d, q): d
```
- Type `d` and press `Enter`

The first piece of information we're asked for is the DB Admin's username 
```shell
========================================================================
Open OnDemand module Setup
========================================================================

The Open OnDemand module stores information in the modw_ondemand
SQL database. This database must have the same access permissions
as the existing Open XDMoD databases.

Please provide the password for the administrative account that will be
used to create the database.

DB Admin Username: [root]
```
- Press `Enter` to accept the default value.

You will then be prompted for the DB Admin's password
```shell
DB Admin Password:
```
- Press `Enter`

Next, you'll be asked to confirm the DB Admin's password
```shell
(confirm) DB Admin Password:
```
- Press `Enter`

The setup program will now use the credentials you have supplied to detect if the `modw_ondemand` database exists. If it
does exist than it will ask if you want to drop and recreate the database.
```shell
Database `modw_ondemand` already exists.
Drop and recreate database (yes, no)? [no]
```
- Type `yes` and press the `Enter` key.

A configuration syncing script will now be run to make sure that all changes to XDMoD's configuration files are synced 
up to its database. If no errors are generated you can skip the display of its output.
```shell
========================================================================
Acl Database Configuration
========================================================================

Verifying that the information contained in the following files are valid:
    - CONFIG_DIR/datawarehouse.json
    - CONFIG_DIR/datawarehouse.d/*.json
    - CONFIG_DIR/roles.json
    - CONFIG_DIR/roles.d/*.json
    - CONFIG_DIR/hierarchies.json
    - CONFIG_DIR/hierarchies.d/*.json

Populating the appropriate Acl related tables from the information found in said
configuration files.

Note: If you would like to execute this script outside of the setup script it is
located at: <xdmod_install_dir>/bin/acl-config

This may take a minute or two...

The script executed without error.
Do you want to see the output (yes, no)? [no]
```
- Press `Enter` to accept the default value.


### Obtaining Open OnDemand logs
The xdmod-ondemand module parses the webserver log files from Open OnDemand.
The `xdmod` container in this tutorial includes a example log file that
was generated from Open OnDemand and is stored in the `/scratch/ondemand/logs` directory.

In this tutorial we will also show how to manually copy the webserver logs from the `ondemand` instance
to the `xdmod` instance.
In a production environment you would either ensure the files were available via
a shared mounted filesystem or configure a periodic cronjob to copy them.

In this tutorial we will use the `/scratch/ondemand/logs` directory on the `xdmod` instance for the
staging area of the Open OnDemand logs to be ingested into XDMoD. The file permissions are set so
that the `xdmod` user has read permission and the `hpcadmin` user has write access.

We now need to copy the files from the `ondemand` instance to the `xdmod` instance. To accomplish this we will first 
need to ssh to the `ondemand` instance.
```shell
[hpcadmin@xdmod /] ssh ondemand
```

Then we will be using scp to copy Open OnDemands Apache access log to our newly created directory on the `xdmod` instance. 
```shell
[hpcadmin@ondemand ~] sudo scp /var/log/httpd/localhost_access_ssl.log hpcadmin@xdmod:/scratch/ondemand/logs/
```

When you are prompted for `hpcadmin`s password, go ahead and provide it. If successful you should see the file being transferred. 
```
hpcadmin@xdmod's password:
localhost_access_ssl.log                                                            100%   24KB  34.2MB/s   00:00
[hpcadmin@ondemand ~]$
```

We can now log off of the `ondemand` instance
```shell
[hpcadmin@ondemand /] exit 
```

Finally, we can ingest the data that we have just copied over
```shell
[hpcadmin@xdmod /] sudo -u xdmod xdmod-ondemand-ingestor -r ondemand -u https://localhost:3443 -d /scratch/ondemand/logs
```

Then login to the XDMoD web portal as a user account that has center staff or center director access, and the "OnDemand"
realm should now show in the metric catalog.


### Administration

You know that the user is an admin by the addition of the "Admin Dashboard"

![Admin User](./tutorial-screenshots/admin-user.png)

Admin Dashboard:

![Admin Dashboard](./tutorial-screenshots/admin-dashboard.png)

## Tutorial Navigation
[Next - OnDemand](../ondemand/README.md)
[Previous Step - ColdFront](../coldfront/README.md)
[Back to Start](../README.md)
