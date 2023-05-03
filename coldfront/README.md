

## Pre-seeding ColdFront with data for tutorial  

Due to time constraints for the half day tutorial we will skip the manual setup steps and have provided a database populated with this information.  These manual steps involve setting up ColdFront with user permissions, resources, an example project and allocations.  If you'd like to walk through these steps yourself, you can delete the ColdFront database and start from scratch.  [Follow the detailed instructions below](#seeding-the-database).    


## Tutorial:  Using ColdFront  

### PI View:  Annual Project Review, Allocation Renewal & Allocation Change Requests

- Login as `cgray` password `test123`
- Click on the project and review the information we've added as part of the database pre-seeding.  There is project information populated and several allocations listed.  One allocation is coming up for renewal and will expire in less than a month.  Notice the `Needs Review` label next to the project.
- Click on the `Add Users` button and in the search box enter `csimmons` then click the `Search` button.  
- You'll be presented the user information for the `csimmons` account as well as a list of allocations on the project.  You can choose to add the account to either of the allocations or all of them. You may also change the role of the account from `User` to `Manager`
- Then click the `Add Selected Users to Project` button and you'll be returned to the Project Detail page.  
- Click on the yellow `Expires in X days Click to renew` banner next to the allocation coming up on expiration and try to renew it.  You should see a warning banner telling you it can't be done because the project review is due.  

NOTE:  When a project review is required, a PI can't request new allocations or allocation change requests nor renew expiring allocations.  They can, however, add/remove users, publications, grants, and research output.     

- Click the `Review Project` link to start the project review process.  Provide a reason for not providing grant or publication information, check the box to acknowledge the update and click the `Submit` button.  

- Now try to renew the expiring allocation. Your request should be accepted and the allocation should now be in the `Renewal Requested` status.  It's now possible to request new allocations or allocation changes as well.  

- Navigate back to the project detail page and click on the actions icon next to the `Project Storage` resource which takes you to the Allocation Detail page.  Click on the `Request Change` button, select a date extension, enter a new amount of storage, and provide a justification.  Then click the `SUBMIT` button.  You should now see a pending allocation change request on the allocation detail page.  Logout.  

### Center Director View: Project Review Approval
At part of the database seeding we did at the start of the tutorial, we configured the user `sfoster` with the `Staff Status` role and gave the account permissions to act as the Center Director.  This allows `sfoster` to view all projects, allocations, publications, and grants.  We've also given permission to view the pending project review list.  

- Login as `sfoster` password `ilovelinux` to see what additional menus and functionality this account has access to.
- Navigate to the `Staff` menu and click on `Project Reviews`  
Click the `Email` button to see this functionality.  Go back to the `Project Reviews` and click `Mark Complete`.  
- Logout  

For more options on allowing permissions for various types of staff access, see the ColdFront manual:  https://coldfront.readthedocs.io/en/latest/manual/users/  


### Activate the allocation request  

- Navigate to the `Admin` menu and click on `Allocation Requests`  
Note: the project review status is a green check mark, indicating our Center Director has already approved the submitted project review.  

At part of the database seeding we did at the start of the tutorial, we activated and set attributes on the allocations requested on the `cgray` project.  Let's look at that allocation and how it was setup. 

- Click the `Details` button to review the Allocation Detail page.  
- Notice that allocation status is `Renewal Requested` and there is a start and end date associated with it.  
- Scroll down to look at the allocation attributes set. There is a slurm_account attribute as well as slurm_specs and slurm_user_specs attributes.  This is what is used by the Slurm plugin to sync with the Slurm database.  
- Click the `Approve` button to re-activate the allocation.  This updates the status to `Active` and changes the expiration date to one year from today.  

Now let's go look at and activate the allocation change request submitted by `cgray` for the storage resource.  As the HPC admin user, activate and setup the new allocation:  
- Navigate to the `Admin` menu and click on `Allocation Change Requests`  
- Click on the `Details` button to review and approve the allocation changes requested.  As the admin you have the ability to approve the date extension, change it to another setting or select `no extension`  You can remove the `storage_quota` request or change it.  You can add notes for the PI and users on the allocation to see.  Then you can take action such as `Approve` or `Deny` the request.  For this demo, let's click the `Approve` button.  

For more information about configuring Allocation Change Requests [see here](#more-info-on-allocation-change-requests) 

- Logout as the `hpcadmin` user   


### Try to run a job as the PI user  
Now let's go outside of ColdFront to the command line and try to submit a batch job as the `cgray` user.  
- Login to the frontend container:  
`ssh -p 6222 hpcadmin@localhost`  
password: `ilovelinux`  
Switch to the PI user account:  
`su - cgray`  
password: `test123`  
`sbatch --wrap "sleep 600"`  
You will get an error message that you do not have permission to run on the cluster  
`sbatch: error: Batch job submission failed: Invalid account or account/partition combination specified`  
_**This is because we have not synced the allocation information in ColdFront with Slurm yet.**_  
- Type `exit` to log out of the cgray account and you should be on the frontend logged in as the hpcadmin account.  


### Run Slurm plugin to sync active allocations from ColdFront to Slurm
- Login to the coldfront container & setup ColdFront environment  
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

Switch over to the PI user account and try to run a job again:    
`su - cgray`  
password: `test123`  
`sbatch --wrap "sleep 600"`  
`squeue`  (the job should be running on a node)  
`exit` (logout from cgray account)  

Tip:  You can also view information about this job in OnDemand, even though you launched the job from the command line.  [Login](https://localhost:3443) as the PI user and navigate to the `Jobs` menu, selecting `Active Jobs` from the drop down menu.  


# Reference Section  
The information following can be used for reference or to go back through the tutorial and see how all the setup was done to get the database in the state we needed it for the half day tutorial.  

## Seeding the Database  

These steps were done in advance to allow for the presentation of a condensed version of the tutorial.  If you would like to go through them yourself, destroy the containers, delete the ColdFront database, start the containers and then follow the steps here:

```
./hpcts destroy
rm database/coldfront.dump
./hpcts start
```

### Login to ColdFront, setup account permissions & create resource  
URL https://localhost:2443/  
You'll need to login as some of the users for this tutorial to get things started.  Do NOT use the OpenID Connect login option at this point.
- Login locally as username `hpcadmin` password: `ilovelinux`
- Logout
- Login locally as username `cgray` password: `test123`
- Logout  
- Login locally as username `csimmons`  password: `ilovelinux`  
- Logout  
- Login locally as username `sfoster` password: `ilovelinux`  
- Logout  
- Login locally as username `admin` password: `admin`
- Go to Admin menu and click on `ColdFront Administration`  Once there, scroll halfway down to the `Authentication and Authorization` section.  Then click on the `Users` link.  
- Click on the `hpcadmin` user and scroll down to the `Permissions` section  
- Make this user a `superuser` by checking the boxes next to `Staff Status` and `Superuser Status` - scroll to the bottom and click `SAVE`  
- Click on the `sfoster` account and check the box next to `Staff Status`  Also under the `User Permissions` section add permissions to make this user the Center Director  
 `allocation | allocation | Can manage invoice`   
 `allocation | allocation | Can view all allocations`  
 `grant | grant | Can view all grants`  
 `project | project | Can view all projects`  
 `project | project | Can review pending project reviews`  
 `publication | publication | Can view publication`   
- Scroll to the bottom and click `SAVE` 
- Click on the Home link to go to back to the Admin interface, scroll to the bottom of the page under the `User` section and click `User Profiles`  
- Click on `cgray` check ``"Is pi"`` - click `SAVE`  

Create a new cluster resource:  
- Click on the Home link to go to back to the Admin interface, scroll down near the bottom to the `Resource` section and Click on `Resources` then click the `Add Resource` button  
- Add a resource with the following settings:  
Resource type: select `cluster`  
Name: type `hpc`  
Description: enter anything you want  
Ensure that the following are checked:  `Is available`, `Is public`, `Is allocatable`  
Under the resource attributes section, click `Add another Resource attribute` and select `slurm_cluster` from the drop down menu.  In the `value` field, enter `hpc`  
Click `Add another Resource attribute` and select `OnDemand` from the drop down menu.  In the `value` field, enter `Yes`  
- Then click `SAVE`  
 **See more info on the OnDemand plugin below**

Create a new storage resource:  
- Click the `Add Resource` button  
- Add a resource with the following settings:  
Resource type: select `storage`  
Name: type `project storage`  
Description: enter anything you want  
Ensure that the following are checked:  `Is available`, `Is public`, `Is allocatable`  
Under the resource attributes section, click `Add another Resource attribute` and select `quantity_label` from the drop down menu.  In the `value` field, enter `Enter storage in 1TB increments`  
Click `Add another Resource attribute` and select `quantity_default_value` from the drop down menu.  In the `1`  
Click `Add another Resource attribute` and select `OnDemand` from the drop down menu.  In the `value` field, enter `Yes`  
- Then click `SAVE`  

Create a new cloud resource:  
- Click the `Add Resource` button  
- Add a resource with the following settings:  
Resource type: select `cloud`  
Name: type `on-prem cloud`  
Description: enter anything you want  
Ensure that the following are checked:  `Is available`, `Is public`, `Is allocatable`  
- We will not set any resource attributes on this resource.  Scroll to the bottom and click `SAVE`.   

Add an allocation attribute type:  
- Click on the Home link to go to back to the Admin interface.  Under the `Allocation` section click on `Allocation attribute types`
- Click `Add Allocation Attribute Type` button, select `Text` from the `Attribute Type` drop down menu and name it `Storage Directory`  Make sure all checkboxes are unchecked and click the `SAVE` button.    

Make an allocation attribute changeable:  
- Under the `Allocation` section, click on `Allocation Attribute Types`  
- Click on `Storage Quota` check the box next to `Is changeable` and then click the `SAVE` button.   
- Logout  

### Create a project & request an allocation  
As the PI user: Create a project and request an allocation for the new resource:  
- Login as the PI using local account username: `cgray` password: `test123`
- Click the `Add a project` button to create a new project, filling in the name, description, and selecting any field of science  
- Once redirected to the project detail page, request an allocation by clicking on the `Request Resource Allocation` button.  Select the `hpc` resource from the drop down menu, provide any justification, and click the `Submit` button    
- Request another allocation by clicking on the `Request Resource Allocation` button.  Select the `Project Storage` resource from the drop down menu, enter a quantity in TB or leave the default 1, provide any justification, and click the `Submit` button    
- Logout  

### Activate the allocation requests  
As the HPC admin user, activate and setup the new allocation:  
- Login using local account username: `hpcadmin` password: `ilovelinux`  
- Navigate to the `Admin` menu and click on `Allocation Requests`  
- Click on the `Details` button next to the `HPC Cluster` allocation request to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu:  
`slurm_account_name` Enter: `cgray`  
`slurm_specs` Enter: `Fairshare=100:DefaultQOS=normal`  
`slurm_user_specs` Enter: `Fairshare=parent:DefaultQOS=normal`  
- Set the status to `Active`, set the start date to today, and set the expiration date to the end of this month.  If you click the `Approve` button, this will set the status to `Active` and set the expiration date out to one year from today.  For the purposes of this demo, we wanted to shorten the allocation length.  [See here](https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings) for more on changing the allocation length default.
- Click the `Update` button  
- Return back to the `Admin` menu and click on the `Allocation Requests`  
- Click on the `Details` button next to the `Project Storage` allocation request to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu and set their values:   
`freeipa_group` Enter: `grp-cgray`  
`Storage Quota (GB)` Enter: `1000`  
`Storage Directory`  Enter: `/projects/cgray`  
- Click the `Approve` button  


### Annual Project Review  
When the project review functionality is enabled (it is by default) a PI will be forced to review their project once every 365 days.  We can force a project to be under review in less than a year which is what we'll do for the cgray project. [See here](https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings) for more on disabling the annual project review process.  

- If necessary, login as `hpcadmin` password `ilovelinux`  
- Navigate to the `Admin` menu and click on the `ColdFront Administration` link.  Scroll to the `Project` section and click on `Projects` then click on the project that we created earlier.  Check the box next to `Force Review`  
- Scroll to the bottom and click the `Save` button.  
NOTE: If there is a project you never want project reviews on, uncheck 'Requires review' 

This wraps up the setup done to the ColdFront database to prepare for the condensed half-day tutorial format.  


## More info on Allocation Change Requests  
Allocation change requests are turned on by default.  This will allow PIs to request date extensions for their allocations.  The date ranges default to 30, 60, & 90 days but can be set changed or disabled completely in `hpc-toolset-tutorial/coldfront/coldfront.env`  
See https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings for more information.

If you want PIs to be able to request changes to allocation attributes (i.e. storage quotas, unix group) this needs to be set on the allocation attribute.  For this demo, we allowed the PI to request changes Qon the `Storage Quota` attribute.  


## More info on the OnDemand Plugin  
This is a very simple example of modifying the ColdFront configuration to use a plugin.  This  plugin allows us to provide a link to our OnDemand instance for any allocations for resources that have "OnDemand enabled"  

We have already added the OnDemand instance URL to the ColdFront config.  You can see this outside the containers in your git directory:  See `hpc-toolset-tutorial/coldfront/coldfront.env`  

When creating the resource at the start of the tutorial, we added the `OnDemand` attribute to the `hpc` resource which tells it to display the OnDemand logo and link to the OnDemand URL for any allocations for this resource.  Notice on the ColdFront home page next to the allocation for the HPC cluster resource you see the OnDemand logo.  Click on the Project name and see this logo also shows up next to the allocation.  When we click on that logo, it directs us to the OnDemand instance.


## ColdFront installation & Configuration
- View `hpc-toolset-tutorial/coldfront/install.sh` to see how ColdFront is installed
- View `hpc-toolset-tutorial/coldfront/coldfront.env` to see how ColdFront is configured  
- This is where you'd enable or disable any plugins and set variables for your local installation.  Check out the [full configuration options available in the ColdFront documentation](https://coldfront.readthedocs.io/en/latest/config/)  
- View `hpc-toolset-tutorial/coldfront/coldfront-nginx.conf` for an example of ColdFront web configuration  

## Tutorial Navigation
[Next - Open OnDemand](../ondemand/README.md)  
[Previous Step - Accessing the Applications](../docs/applications.md)  
[Docker Tips](../docs/docker_tips.md)  
[Back to Start](../README.md)
