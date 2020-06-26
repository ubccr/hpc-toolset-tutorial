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

## Login to XDMoD container
- `ssh hpcadmin@xdmod`
- In order to see the job data just generated in slurm, we need to ingest the data into xdmod.  This is normally done once a day but for the purposes of this demo, we'll run it now:
```
xdmod-slurm-helper -v -r linux --end-time 2020-07-31
xdmod-ingestor --start-date 2020-01-01 --end-date 2020-12-31 --last-modified-start-date 2020-01-01
```

## Login to XDMoD website
- URL  https://localhost:4443/ (cgray:test123)
- Change date to include today
- You should see the data from the job you just ran


## Tutorial Navigation
[Next - XDMoD](../xdmod/README.md)  
[Previous Step - Accessing the Applications](../docs/applications.md)  
[Back to Start](../README.md)  
