## ColdFront installation
View `hpc-toolset-tutorial/coldfront/install.sh` to see how ColdFront is installed
![ColdFront installation script](../docs/cf_install.gif)

## Login to Coldfront container
- Review `hpc-toolset-tutorial/coldfront/local_settings.py`
- This is where you'd enable or disable any plugins and set variables for your local installation

## Login to the frontend
- `ssh -p 6222 hpcadmin@localhost`
- Look at current slurm associations
- `sacctmgr show user cgray -s list`

## Login to ColdFront website
- URL https://localhost:2443/
- Login as admin:admin
- Go to Admin interface, users and search for hpcadmin, make this user a 'superuser'
- Logout
- Login as 'hpcadmin' user (ilovelinux)
- Add a resource: cluster, cluster name=hpc
- Logout
- Login as PI (cgray:test123)
- Request an allocation for resource: hpc
- Logout
- Login as 'hpcadmin'
- Activate the allocation and set the appropriate allocation attributes:
slurm_account:cgray, slurm_specs:Fairshare=100, slurm_user_specs:Fairshare=parent
- Run slurm plugin to sync active allocations from ColdFront to slurm associations

## Login (or go back) to frontend container
- check slurm associations for cgray again: they should now show access to the linux Cluster
- `su - cgray`
- `sbatch --wrap "sleep 600"`
- `squeue`  (the job should be running on a node)
- `ssh` to node
- `ps -ef |grep cgray`

## Login to OnDemand website
- URL https://localhost:3443/ (cgray:test123)
- Go to Active Jobs and click on your running job
- Delete (cancel) the job

## Login to Open XDMoD container
- `ssh hpcadmin@xdmod`
- In order to see the job data just generated in slurm, we need to ingest the data into Open XDMoD and aggregate it.  This is normally done once a day on a typical system but for the purposes of this demo, we have created a script that you can run now:
`sudo /srv/xdmod/scripts/shred-ingest-aggregate-all.sh`

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

**Note: More information about this script in the Open XDMoD portion of this tutorial

## Login to Open XDMoD website
- URL  https://localhost:4443/ (cgray:test123)
- Change date to include today
- You should see the data from the job you just ran


## Tutorial Navigation
[Next - Open XDMoD](../xdmod/README.md)
[Previous Step - Accessing the Applications](../docs/applications.md)
[Back to Start](../README.md)
