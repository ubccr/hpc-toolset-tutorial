## ColdFront installation & Configuration
- View `hpc-toolset-tutorial/coldfront/install.sh` to see how ColdFront is installed
- View `hpc-toolset-tutorial/coldfront/local_settings.py` to see how ColdFront is configured
- This is where you'd enable or disable any plugins and set variables for your local installation

[![asciicast](https://asciinema.org/a/347965.svg)](https://asciinema.org/a/347965)

NOTE: you can also install ColdFront using pip: https://pypi.org/project/coldfront/

## Login to ColdFront website
- URL https://localhost:2443/
- You'll need to login as some of the users for this tutorial to get things started:
- Login locally as user `hpcadmin` password: `ilovelinux`
- Logout
- Login locally as user `cgray` password: `test123`
- Logout
- Login locally as `admin:admin`
- Go to Admin interface, Users
- Click on the hpcadmin user
- Make this user a 'superuser' by checking the boxes next to "Staff Status" and "Superuser Status" - SAVE
- Go to Admin interface, User Profiles
- Click on `cgray` check ``"Is pi"``  SAVE
- Go back to Admin interface, Click on Resources
- Add a resource: `cluster, cluster name=hpc, attribute: slurm_cluster=hpc`
- Logout
- Login using OpenID as PI `cgray:test123`
- Create a new project
- Request an allocation for resource: hpc
- Logout
- Login as `hpcadmin`
- Activate the allocation and set the appropriate allocation attributes:  
`slurm_account:cgray, slurm_specs:Fairshare=100, slurm_user_specs:Fairshare=parent`

![ColdFront demo](../docs/cf_demo.gif)

## Run slurm plugin to sync active allocations from ColdFront to slurm
- Login to the frontend container first, then to the coldfront container:  
`ssh -p 6222 hpcadmin@localhost`  
`ssh coldfront`  
`cd /srv/www`  
`source venv/bin/activate`  
`cd coldfront`  

- Let's see what slurm access cgray currently has:  
`sacctmgr show user cgray -s list`
- Now dump the slurm account/association info from ColdFront's active allocations:  
`coldfront slurm_dump -c hpc -o ~/slurm_dump`
- Let's see what was created:  
`ls -al ~/slurm_dump`  
`cat ~/slurm_dump/hpc.cfg`  
- Load the slurm dump into slurm database:  
`sacctmgr load file=~/slurm_dump/hpc.cfg`  
`Type 'Y'` to add the new account & associations for cgray
- Let's look at cgray's slurm account again:  
`sacctmgr show user cgray -s list`

[![asciicast](https://asciinema.org/a/347945.svg)](https://asciinema.org/a/347945)

## Login (or go back) to frontend container
`ssh -p 6222 hpcadmin@localhost`
- check slurm associations for cgray again: they should now show access to the hpc cluster
`sacctmgr show user cgray -s list`    
`su - cgray`  
`sbatch --wrap "sleep 600"`  
`squeue`  (the job should be running on a node)  
`ssh` to the allocated node  
`ps -ef |grep cgray`  

[![asciicast](https://asciinema.org/a/347948.svg)](https://asciinema.org/a/347948)

## Login to OnDemand website
- Login to Open OnDemand as ` cgray (test123)`  https://localhost:3443/
- Go to Active Jobs and click on your running job
- Delete (cancel) the job
- Submit a job using job template
- Launch an interactive Job

![ColdFront OnDemand demo](../docs/cf_demo2.gif)


## Login to Open XDMoD website
- Login to Open XDMoD as `cgray (test123)`  https://localhost:4443/
- Change date to include today
- There is currently no data in XDMoD

![XDMoD no data](../docs/xdmod_empty.PNG)


## Login to Open XDMoD container
- `ssh hpcadmin@xdmod`
- In order to see the job data just generated in slurm, we need to ingest the data into Open XDMoD and aggregate it.  This is normally done once a day on a typical system but for the purposes of this demo, we have created a script that you can run now:
`sudo -u xdmod /srv/xdmod/scripts/shred-ingest-aggregate-all.sh`

The contents of the script are:
```bash
#!/bin/bash
yesterday=`date +%Y-%m-%d --date="-1 day"`
tomorrow=`date +%Y-%m-%d --date="+1 day"`

xdmod-slurm-helper -r hpc --start-time $yesterday --end-time $tomorrow
xdmod-ingestor
indexarchives.py -a
summarize_jobs.py
aggregate_supremm.sh
```
[![asciicast](https://asciinema.org/a/347955.svg)](https://asciinema.org/a/347955)

**Note: More information about this script in the Open XDMoD portion of this tutorial**

## Login to Open XDMoD website
- Login to Open XDMoD as `cgray (test123)`  https://localhost:4443/
- Change date to include today
- You should see the data from the job you just ran
NOTE: There won't be much info except that we ran a few jobs. More will be presented in the XDMoD portion of the tutorial

![XDMoD job data](../docs/xdmod_jobs.PNG)

## Adding new users to project & allocation (time permitting)
- Login to ColdFront as `csimmons (ilovelinux)` https://localhost:2443/
- Notice there are no projects and no allocations.  Logout
- Login as `cgray (test123)`
- Click on project
- Click on Add User - search for `csimmons`
- Add to allocation
- Login to coldfront container and re-run slurm plug-in commands to add csimmons to slurm associations  
`ssh coldfront`
- Let's see what slurm access csimmons currently has:  
`sacctmgr show user csimmons -s list`
- Now dump the slurm account/association info from ColdFront's active allocations:  
`coldfront slurm_dump -c hpc -o /tmp/slurm_dump`
- Let's see what was created:  
`ls -al /tmp/slurm_dump`  
`cat /tmp/slurm_dump/hpc.cfg`  
- Load the slurm dump into slurm database:  
`sacctmgr load file=/tmp/slurm_dump/hpc.cfg`  
`Type 'Y'` to add the new association for csimmons
- Let's look at csimmons's slurm account again:  
`sacctmgr show user csimmons -s list`



## Tutorial Navigation
[Next - Open XDMoD](../xdmod/README.md)  
[Previous Step - Accessing the Applications](../docs/applications.md)  
[Back to Start](../README.md)
