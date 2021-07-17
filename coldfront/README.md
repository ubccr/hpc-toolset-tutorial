## ColdFront installation & Configuration
- View `hpc-toolset-tutorial/coldfront/install.sh` to see how ColdFront is installed
- View `hpc-toolset-tutorial/coldfront/coldfront.env` to see how ColdFront is configured  
- This is where you'd enable or disable any plugins and set variables for your local installation.  Check out the [full configuration options available in the ColdFront documentation](https://coldfront.readthedocs.io/en/latest/config/)  
- View `hpc-toolset-tutorial/coldfront/coldfront-nginx.conf` for an example of ColdFront web configuration  


## Login to ColdFront website
- URL https://localhost:2443/
- You'll need to login as some of the users for this tutorial to get things started:
- Login locally as username `hpcadmin` password: `ilovelinux`
- Logout
- Login locally as username `cgray` password: `test123`
- Logout  
- Login locally as username `csimmons`  password: `ilovelinux`  
- Login locally as username `sfoster` password: `ilovelinux`  
- Login locally as username `admin` password: `admin`
- Go to Admin interface, Users
- Click on the hpcadmin user
- Make this user a `superuser` by checking the boxes next to `Staff Status` and `Superuser Status` - SAVE  
- Click on the sfoster account and check the box next to `Staff Status`  Also under the `User Permissions` section add permissions for `allocation|allocation|Can view all allocations` and `project|project|Can view all projects`  Make sure to SAVE the changes.  
- Click on the Home link to go to back to the Admin interface, then click "User Profiles"  
- Click on `cgray` check ``"Is pi"``  SAVE
- Click on the Home link to go to back to the Admin interface, Click on Resources
- Add a resource: `cluster, cluster name=hpc, description: anything you want, resource attribute: slurm_cluster=hpc` - click SAVE  
- Logout
- Login as the PI using local account username: `cgray` password: `test123`
- Create a new project, filling in the name, description, and selecting any field of science  
- Request an allocation for resource: hpc  
- Add a user to the project - search for `csimmons` and add to the HPC cluster allocation  
- Logout
- Login using local account username: `hpcadmin` password: `ilovelinux`  
- Activate the allocation and set the appropriate allocation attributes:  
`slurm_account:cgray, slurm_specs:Fairshare=100, slurm_user_specs:Fairshare=parent`

## Login to OnDemand website
- Login to Open OnDemand  https://localhost:3443/ as username: `cgray` password: `test123`
- Try to launch an interactive Job - you will get an error message that you do not have permission to run on the cluster  
`sbatch: error: Batch job submission failed: Invalid account or account/partition combination specified`  


## Run Slurm plugin to sync active allocations from ColdFront to Slurm
- Login to the frontend container first, then to the coldfront container:  
`ssh -p 6222 hpcadmin@localhost`  
password: `ilovelinux`  
`ssh coldfront`  
`cd /srv/www`  
`source venv/bin/activate`  


- Let's see what slurm access cgray currently has:  
`sacctmgr show user cgray -s list`  
- Let's see what slurm access csimmons currently has:  
`sacctmgr show user csimmons -s list`
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
- Let's look at csimmons's slurm account again:  
`sacctmgr show user csimmons -s list`  
NOTE: The csimmons user is under the cgray slurm account  
- Logout of ColdFront container  
`exit`  


## Login (or go back) to frontend container
NOTE: you should already be on the frontend but just in case you're not:  
`ssh -p 6222 hpcadmin@localhost`  
password: `ilovelinux`  

Check slurm associations for cgray again: they should now show access to the hpc cluster  
`sacctmgr show user cgray -s list`    
`su - cgray`  
password: `test123`  
`sbatch --wrap "sleep 600"`  
`squeue`  (the job should be running on a node)  
`exit` (logout from cgray account)  


## Login to OnDemand website
- Login back into or refresh your login to Open OnDemand  https://localhost:3443/ as username: `cgray` password: `test123`  
- Try to launch an interactive job again.  Does it work this time?  
- Go to Active Jobs and click on your running jobs to see more details    
- Delete (cancel) the jobs so they show the `completed` status  



## Login to Open XDMoD website
- Login to Open XDMoD https://localhost:4443/  
 -- Click on `Sign In` at the top left  
 -- Under the section "Sign in with local XDMoD account:"  Click on "Login Here" and enter username: `admin` password: `admin`  
- Notice there is currently no data in XDMoD

![XDMoD login](../docs/xdmod_login.PNG)

![XDMoD no data](../docs/xdmod_empty.PNG)


## Login to Open XDMoD container
- `ssh hpcadmin@xdmod`  
password: `ilovelinux`  
- In order to see the job data just generated in slurm, we need to ingest the data into Open XDMoD and aggregate it.  This is normally done once a day on a typical system but for the purposes of this demo, we have created a script that you can run now:  
`sudo -u xdmod /srv/xdmod/scripts/shred-ingest-aggregate-all.sh`  
`exit`  


**Note: More information about this script in the Open XDMoD portion of this tutorial**

## Login to Open XDMoD website
- Login to Open XDMoD https://localhost:4443/  
 -- Click on 'Sign In' at the top left  
 -- Under the section "Sign in with tutorial:"  Click on "Login Here" and enter username: `cgray` password: `test123`  
- You should see the data from the job you just ran  
NOTE: There won't be much info except that we ran a few jobs. More will be presented in the XDMoD portion of the tutorial

![XDMoD job data](../docs/xdmod_jobs.PNG)

## Integrating OnDemand with ColdFront    
This is a very simple example of modifying the ColdFront configuration to use a plugin.  This  plugin allows us to provide a link to our OnDemand instance for any allocations for resources that have "OnDemand enabled"  

We have already added the OnDemand instance info to the ColdFront config.  You can see this outside the containers in your git directory:  See `hpc-toolset-tutorial/coldfront/coldfront.env`  

Now let's enable OnDemand for our cluster resource:  
- Log back in to the ColdFront Administration site https://localhost:2443/admin/ as the `hpcadmin` acccount - password `ilovelinux`:  
- Navigate to the Resources section and click on the 'HPC' cluster resource.  Add a new resource attribute:  `OnDemand = "Yes"`  
- Log out and log in as the PI user `cgray` password `test123`  
- Notice on the ColdFront home page next to the allocation for the HPC cluster resource you see the OnDemand logo.  Click on the Project name and see this logo also shows up next to the allocation.  When we click on that logo, it directs us to the OnDemand instance.  

## Staff Role  
At the start of the tutorial we configured the user `sfoster` with the 'Staff Status' role and gave permissions to view all projects and all allocations.  Login as `sfoster` password `ilovelinux` to see what additional menus and functionality this account has access to.


## Annual Project Review (time permitting)
When the project review functionality is enabled (it is by default) a PI will be forced to review their project once every 365 days.  To change this time frame, edit the default in `coldfront.env`  We can force a project to be under review in less than a year which is what we'll do for the cgray project.  

Login as `hpcadmin` password `ilovelinux` and go to the ColdFront Administration interface.  Click on Projects and click on the cgray project that we created earlier.  Check the box next to 'Force Review'  
NOTE: If there is a project you never want project reviews on, uncheck 'Requires review'  

Now login as `cgray` password `test123` and notice the warning banner.  Click on the allocation and try to renew it.  You should see a warning banner telling you it can't be done because the project review is due.  When a project review is required, a PI can't request new allocations or renew expiring allocations.  They can, however, add/remove users, publications, grants, and research output.   

Click the "Review Project" link.  Provide a reason for not providing grant or publication information, check the box to acknowledge the update and click the Submit button.  Now try to renew the expiring allocation.  Log out as `cgray`

Login as `hpcadmin` password `ilovelinux`  
View the pending allocation requests.  Note that the project review status is pending.  View the pending project reviews.  Mark this one complete and go back to the pending allocation requests.  Click the "Activate" button and ColdFront activates the allocation for another year.  

## Tutorial Navigation
[Next - Open XDMoD](../xdmod/README.md)  
[Previous Step - Accessing the Applications](../docs/applications.md)  
[Docker Tips](../docs/docker_tips.md)  
[Back to Start](../README.md)
