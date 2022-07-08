## ColdFront installation & Configuration
- View `hpc-toolset-tutorial/coldfront/install.sh` to see how ColdFront is installed
- View `hpc-toolset-tutorial/coldfront/coldfront.env` to see how ColdFront is configured  
- This is where you'd enable or disable any plugins and set variables for your local installation.  Check out the [full configuration options available in the ColdFront documentation](https://coldfront.readthedocs.io/en/latest/config/)  
- View `hpc-toolset-tutorial/coldfront/coldfront-nginx.conf` for an example of ColdFront web configuration  


### Login to ColdFront, setup account permissions & create resource  
URL https://localhost:2443/  
You'll need to login as some of the users for this tutorial to get things started.  Do NOT use the OpenID Connect login option at this point.
- Login locally as username `hpcadmin` password: `ilovelinux`
- Logout
- Login locally as username `cgray` password: `test123`
- Logout  
- Login locally as username `csimmons`  password: `ilovelinux`  
- Login locally as username `sfoster` password: `ilovelinux`  
- Login locally as username `admin` password: `admin`
- Go to Admin menu and click on `ColdFront Administration`  Once there, scroll halfway down to the `Authentication and Authorization` section.  Then click on the `Users` link.  
- Click on the hpcadmin user and scroll down to the `Permissions` section  
- Make this user a `superuser` by checking the boxes next to `Staff Status` and `Superuser Status` - scroll to the bottom and click SAVE  
- Click on the sfoster account and check the box next to `Staff Status`  Also under the `User Permissions` section add permissions to make this user the Center Director  
 `allocation | allocation | Can manage invoice`   
 `allocation | allocation | Can view all allocations`  
 `grant | grant | Can view all grants`  
 `project | project | Can view all projects`  
 `project | project | Can review pending project reviews`  
 `publication | publication | Can view publication`  
  Make sure to SAVE the changes.  
- Click on the Home link to go to back to the Admin interface, scroll to the bottom of the page under the `User` section and click `User Profiles`  
- Click on `cgray` check ``"Is pi"`` - click SAVE  

Create a new resource:  
- Click on the Home link to go to back to the Admin interface, scroll down near the bottom to the `Resource` section and Click on `Resources` then click the `Add Resource` button  
- Add a resource with the following settings:  
Resource type: select `cluster`  
Name: type `hpc`  
Description: enter anything you want
Ensure that the following are checked:  `Is available`, `Is public`, `Is allocatable`  
Under the resource attributes section, click `Add another Resource attribute` and select `slurm_cluster` from the drop down menu.  In the `value` field, enter `hpc`
Click `Add another Resource attribute` and select `OnDemand` from the drop down menu.  In the `value` field, enter `Yes`  
- Then click SAVE  
 **See more info on the OnDemand plugin at the end**

Make an allocation attribute changeable:  
- Under the `Allocation` section, click on `Allocation Attribute Types`  Click on `slurm_account_name` check the box next to `Is changeable` and then click the SAVE button.   
- Logout  

### Create a project & request an allocation  
As the PI user: Request an allocation for the new resource:  
- Login as the PI using local account username: `cgray` password: `test123`
- Click the `Add a project` button to reate a new project, filling in the name, description, and selecting any field of science  
- Once redirected to the project detail page, request an allocation by clicking on the `Request Resource Allocation` button.  Select the `hpc` resource from the drop down menu, provide any justification, and click the `Submit` button    
- Click the `Add Users` button to add a user to the project - search for `csimmons`, select the HPC cluster allocation, check the box next to the username, and click the `Add Selected Users to Project`  
- Logout  

### Activate the allocation request  
As the HPC admin user, activate and setup the new allocation:  
- Login using local account username: `hpcadmin` password: `ilovelinux`  
- Navigate to the `Admin` menu and click on `Allocation Requests`  
- Click on the `Detail` button to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu:  
`slurm_account_name` Enter: `cgray`  
`slurm_specs` Enter: `Fairshare=100:DefaultQOS=normal`  
`slurm_user_specs` Enter: `Fairshare=parent:DefaultQOS=normal`  
Set the status to `Active`, set the start date to today, and set the expiration date to the end of this month (you'll see why later)  
Click the `Update` button   

### Login to OnDemand & test interactive app  
- Login to Open OnDemand  https://localhost:3443/ as username: `cgray` password: `test123`
- Click on the `Interactive Apps` menu and click on `HPC Desktop`
- Try to launch an interactive Job by clicking on the `Launch` button  
You will get an error message that you do not have permission to run on the cluster  
`sbatch: error: Batch job submission failed: Invalid account or account/partition combination specified`  
This is because we have not synced the allocation information in ColdFront with Slurm yet.  


### Run Slurm plugin to sync active allocations from ColdFront to Slurm
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


### Login (or go back) to frontend container
NOTE: you should already be on the frontend but just in case you're not:  
`ssh -p 6222 hpcadmin@localhost`  
password: `ilovelinux`  

Check slurm associations for cgray account: they should now show access to the hpc cluster  
`sacctmgr show account cgray -s list`    
`su - cgray`  
password: `test123`  
`sbatch --wrap "sleep 600"`  
`squeue`  (the job should be running on a node)  
`exit` (logout from cgray account)  


### Try interactive app in OnDemand again  
- Login back into or refresh your login to Open OnDemand  https://localhost:3443/ as username: `cgray` password: `test123`  
- Try to launch an interactive job again.  Does it work this time?  
- Go to the `Jobs` menu and click `Active Jobs` and click on your running jobs to see more details    
- Delete (cancel) the jobs so they show the `completed` status  


### Annual Project Review, Allocation Renewal & Allocation Change Requests
When the project review functionality is enabled (it is by default) a PI will be forced to review their project once every 365 days.  To change this time frame, edit the default in `coldfront.env`  We can force a project to be under review in less than a year which is what we'll do for the cgray project.  

Login as `hpcadmin` password `ilovelinux`  
Navigate to the `Admin` menu and click on the `ColdFront Administration` link.  Scroll to the `Project` section and click on `Projects`  Then click on the project that we created earlier.  Check the box next to `Force Review`  
NOTE: If there is a project you never want project reviews on, uncheck 'Requires review'  

- Logout as `hpcadmin` and login as `cgray` password `test123` and notice the `Needs Review` label next to the project.  Click on the allocation and try to renew it.  You should see a warning banner telling you it can't be done because the project review is due.  When a project review is required, a PI can't request new allocations or allocation change requests nor renew expiring allocations.  They can, however, add/remove users, publications, grants, and research output.   Click on the `renew now` link for the allocation to test this out.  

- Click the `Review Project` link.  Provide a reason for not providing grant or publication information, check the box to acknowledge the update and click the Submit button.  Now try to renew the expiring allocation.  

- Click on the allocation `RENEWAL REQUESTED` button or navigate to the Allocation Detail page through the project.  Click on the `Request Change` button, select a date extension, enter a new slurm account and provide a justification.  Then click the `SUBMIT` button.  Logout.  

- Login as `hpcadmin` password `ilovelinux`  
- Go to the `Admin` menu and click on `Allocation Change Requests`  
- As the admin you have the ability to approve the date extension, change it to another setting or select `no extension`  You can remove the `slurm_account_name` request or change it.  You can add notes for the PI and users on the allocation to see.  Then you can take action such as `Approve` or `Deny` the request.  For this demo, let's click the `Approve` button.  
- Next review the pending allocation requests.  Navigate to the `Admin` menu and click on `Allocation Requests`  Note that the project review status is pending.  
- Logout as the `hpcadmin` user   
 **See more info on allocation change requests at the end**   

### Center Director Role and Permissions  
At the start of the tutorial we configured the user `sfoster` with the 'Staff Status' role and gave permissions to act as the Center Director.  This allows `sfoster` to view all projects, allocations, publications, and grants.  We've also given permission to view the pending project review list.  

- Login as `sfoster` password `ilovelinux` to see what additional menus and functionality this account has access to.

- Navigate to the `Staff` menu and click on `Project Reviews`  
Click the `Email` button to see this functionality.  Go back to the `Project Reviews` and click `Mark Complete`.  

For more options on allowing permissions for various types of staff access, see the ColdFront manual:  https://coldfront.readthedocs.io/en/latest/manual/users/  

### More info on Allocation Change Requests  
Allocation change requests are turned on by default.  This will allow PIs to request date extensions for their allocations.  The date ranges default to 30, 60, & 90 days but can be set changed or disabled completely in `hpc-toolset-tutorial/coldfront/coldfront.env`  
See https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings for more information.

If you want PIs to be able to request changes to allocation attributes (i.e. storage quotas, unix group) this needs to be set on the allocation attribute.  For this demo, we allowed the PI to request changes on the `slurm_account` attribute.  

### More info on the OnDemand Plugin  
This is a very simple example of modifying the ColdFront configuration to use a plugin.  This  plugin allows us to provide a link to our OnDemand instance for any allocations for resources that have "OnDemand enabled"  

We have already added the OnDemand instance URL to the ColdFront config.  You can see this outside the containers in your git directory:  See `hpc-toolset-tutorial/coldfront/coldfront.env`  

When creating the resource at the start of the tutorial, we added the `OnDemand` attribute to the `hpc` resource which tells it to display the OnDemand logo and link to the OnDemand URL for any allocations for this resource.  Notice on the ColdFront home page next to the allocation for the HPC cluster resource you see the OnDemand logo.  Click on the Project name and see this logo also shows up next to the allocation.  When we click on that logo, it directs us to the OnDemand instance.


## Tutorial Navigation
[Next - Open XDMoD](../xdmod/README.md)  
[Previous Step - Accessing the Applications](../docs/applications.md)  
[Docker Tips](../docs/docker_tips.md)  
[Back to Start](../README.md)
