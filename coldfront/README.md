

# Options for ColdFront Tutorial  

There are several ways to run through the ColdFront portion of the HPC Toolset Tutorial.  We have provided different pre-seeded databases for the half day and the full day tutorial.  These databases include some basic setup to save time and get right to the good stuff!  Some of you may be coming here to test out ColdFront from stratch so we've also provided the detailed instructions to allow you to do it all yourself.  Click on the link below for the experience you're interested in:  

[Full Day Tutorial](#full-day-tutorial-using-coldfront)  
[Half Day Tutorial](#half-day-tutorial-using-coldfront)  
[Start from Scratch](#starting-from-scratch-half-day-tutorial)    
<br>

NOTE: The databases created for this were made for specific dates these tutorials were presented at conferences in 2023.  Any examples related to allocation expiration dates will not match up if you're running these outside of the conference dates.  You can review the pre-seeding steps to see what was done to replicate this in your testing.  
<br> 

## Full Day Tutorial: Using ColdFront  
<details>  

If interested, you can [view the steps taken](#seeding-the-database-for-the-full-day-tutorial) to pre-seed the database for the extended version of the tutorial.

**By default, the containers start with the database being pre-seeded for the full day tutorial.**  If you are starting from a different spot in these instructions, you may want to ensure you have the right database in place.  To do so, stop (destroy) the containers, copy in the full day tutorial database, and then restart the containers, following these steps:  

```
./hpcts destroy
cp coldfront/db_options/coldfront-full.dump database/coldfront.dump
./hpcts start
```

Once the containers are started, navigate to the [ColdFront site - https://localhost:2443](https://localhost:2443).
<br>

<hr>

## ColdFront Overview  

This section should give you an idea of how ColdFront can be used in your center by PIs (principal investigators - also faculty, professors, project managers). PIs can manage access to resources for their research groups or classes, by your system administrators to manage the resources & grant the access, and your center director or other staff to review who has access and what type of research they're doing.  It's just one short example but it provides the full product lifecycle so you can see how the different roles might utilize the software.  The next section provides more details specifically for system administrators managing resources at an HPC center.  

### PI View:  Annual Project Review, Allocation Renewal & Allocation Change Requests

- Log in as `cgray` password `test123`
- Click on the project and review the information we've added as part of the database pre-seeding.  There is project information populated and several allocations listed.  One allocation is coming up for renewal and will expire in less than a month.  Notice the `Needs Review` label next to the project
- Click on the `Add Users` button and in the search box enter `csimmons` then click the `Search` button  
- You'll be presented the user information for the `csimmons` account as well as a list of allocations on the project.  You can choose to add the account to either of the allocations or all of them. You may also change the role of the account from `User` to `Manager`
- Then click the `Add Selected Users to Project` button and you'll be returned to the Project Detail page
- Click on the yellow `Expires in X days Click to renew` banner next to the allocation coming up on expiration and try to renew it.  You should see a warning banner telling you it can't be done because the project review is due

NOTE:  When a project review is required, a PI can't request new allocations or allocation change requests nor renew expiring allocations.  They can, however, add/remove users, publications, grants, and research output.     

- Click the `Review Project` link to start the project review process.  Provide a reason for not providing grant or publication information, check the box to acknowledge the update and click the `Submit` button  
- Now try to renew the expiring allocation. Your request should be accepted and the allocation should now be in the `Renewal Requested` status.  It's now possible to request new allocations or allocation changes as well 
- Add a publication: Click the `Add Publication` button and in the search box enter the DOI: `10.1145/3437359.3465585`  Click the `Search` button and it should display information about a ColdFront publication.  Click on the checkbox next to the search result and then click the `Add Selected Publications to Project` button  
- Take a look at the other project sections such as Project Attributes, Grants, and Research Outputs  
- Log out 

### Center Director View: Project Review Approval
At part of the database seeding we did prior to the start of the tutorial, we configured the user `sfoster` with the proper account permissions to act as the Center Director.  This allows `sfoster` to view all projects, allocations, publications, and grants.  We've also given permission to view the pending project review list.  

- Log in as `sfoster` password `ilovelinux` to see what additional menus and functionality this account has access to
- Navigate to the `Director` menu and click on `Project Reviews`
- Click the `Email` button to see this functionality.  Go back to the `Project Reviews` and click `Mark Complete`
- Click through the different options in the `Director` menu if desired  
- Log out  


### Activate the allocation request  

- Log in as `hpcadmin` password `ilovelinux`
- Navigate to the `Admin` menu and click on `Allocation Requests`  
Note: the project review status is a green check mark, indicating our Center Director has already approved the submitted project review.  

At part of the database seeding we did at the start of the tutorial, we activated and set attributes on the allocations requested on the `cgray` project.  Let's look at that allocation and how it was set up. 

- Click the `Details` button to review the Allocation Detail page  
- Notice that allocation status is `Renewal Requested` and there is a start and end date associated with it  
- Scroll down to look at the allocation attributes set. There is a `slurm_account` attribute as well as `slurm_specs` and `slurm_user_specs` attributes.  This is what is used by the Slurm plugin to sync with the Slurm database  
- Click the `Approve` button to re-activate the allocation.  This updates the status to `Active` and changes the expiration date to one year from today  
- Log out as the `hpcadmin` user   

### Try to run a job as the PI user  
Now let's go outside of ColdFront to the command line and try to submit a batch job as the `cgray` user.  
- Log in to the frontend container:  
```
ssh -p 6222 hpcadmin@localhost  
password: ilovelinux
```
Switch to the PI user account:  
```
su - cgray  
password: test123
sbatch --wrap "sleep 600"
```
You will get an error message that you do not have permission to run on the cluster  
`sbatch: error: Batch job submission failed: Invalid account or account/partition combination specified`  
- Let's see what slurm access cgray currently has: 
```
sacctmgr show user cgray -s list
```
You should not see any Slurm account information for the `cgray` user.  
_**This is because we have not synced the allocation information in ColdFront with Slurm yet.**_  
- Type `exit` to log out of the cgray account and you should be on the frontend logged in as the hpcadmin account  

### Run Slurm plugin to sync active allocations from ColdFront to Slurm
- Log in to the coldfront container & set up ColdFront environment  
```
ssh coldfront    
source /srv/www/venv/bin/activate  
```

- Now dump the slurm account/association info from ColdFront's active allocations: 
``` 
coldfront slurm_dump -c hpc -o ~/slurm_dump
```
- Let's see what was created:  
```
ls -al ~/slurm_dump  
cat ~/slurm_dump/hpc.cfg
```  

- Load the slurm dump into slurm database:  
```
sacctmgr load file=~/slurm_dump/hpc.cfg  
Type 'Y'  to add the new account & associations for cgray
```

- Let's look at cgray's slurm account again:  
```
sacctmgr show user cgray -s list
```
- Let's look at csimmons's slurm account again:  
```
sacctmgr show user csimmons -s list
```  
NOTE: The csimmons user is under the cgray slurm account  
- Log out of ColdFront container
```
exit
```  

### Log in (or go back) to frontend container
NOTE: you should already be on the frontend but just in case you're not:  
```
ssh -p 6222 hpcadmin@localhost  
password: ilovelinux  
```
Switch over to the PI user account and try to run a job again:    
```
su - cgray  
password: test123
sbatch --wrap "sleep 600"  
squeue  (the job should be running on a node)  
exit (log out from cgray account)  
```
<br>

**Tip:** 
  You can also view information about this job in OnDemand, even though you launched the job from the command line.  [Log in](https://localhost:3443) as the PI user and navigate to the `Jobs` menu, selecting `Active Jobs` from the drop down menu.  
<Br>

<hr>

## ColdFront Admin Tasks  

Building on what you learned in the previous section, this part of the tutorial provides information on an array of administrative tasks and setup steps you'll need to know in order to set up ColdFront at your center.  We'll step through a few of these tasks from the ColdFront administration page and then go back into the ColdFront front end to test these.  


### Elevating User to PI Status:  

In order for a user to create a new project, they need to have `PI` status.  Let's give the `sfoster` account PI access:  
- If necessary, log in as `hpcadmin` password `ilovelinux`  
- Go to Admin menu and click on `ColdFront Administration` 
- Scroll to the bottom under the `User` section and click on `User Profiles`  
- Click on `sfoster` check ``"Is pi"`` - click `SAVE`  


### Adding a Resource  

The tutorial database comes with two resources already created.  However, when running this at your center, you'll need to manually create a resource for each system or service you want your users to access.  Let's add a cloud resource:  

Still on the `ColdFront Administration` page:
- Scroll to the `Resource` section and click on `Resources`  
- Click on the `Add Resource` button  
- Select `Cloud` for `Resource Type`, enter a name and a description  
- Make sure the checkboxes for `Is available`, `Is public`, and `Is allocatable` are checked  
- Under the `Resource Attributes` section, click `Add another resource attribute` 
- Select the option `quantity_default_value` and enter a number here  
- Select the option `quantity_label` and enter `Enter number of CPU hours to purchase`  
- Select the `eula` (End User License Agreement) option and enter the text you'd like your project managers to see when they're requesting allocations for this resource  
- Click the `SAVE` button  

### Allocation Change Requests

Allocation change requests allow a project manager to request a change on an active allocation without having to request a whole new allocation for that resource.  They can request a date extension and/or a change on an allocation attribute.  We don't necessarily want to let users request changes on all allocation attributes so we need to set the ability to make change requests on individual allocation attributes.  

Still on the `ColdFront Administration` page:
- Under the `Allocation` section click on `Allocation Attribute Types`  
- Let's allow project managers to request an increase in their storage quotas.  Click on the number next to `Storage Quota (GB)`  
- Check the box `Is Changeable` and then click the `Save` button  
- Now we'll switch over to our PI user.  Under the `Authentication and Authorization` section, click on `Users` then click on `cgray`  
- At the top right, click on `Login As` which redirects us to the ColdFront home page for the user `cgray`.  Click on the project name to get to the project detail page  
- Click on the actions icon next to the `Project Storage` resource which takes you to the Allocation Detail page.  Click on the `Request Change` button, select a date extension, enter a new amount of storage, and provide a justification.  Then click the `SUBMIT` button.  You should now see a pending allocation change request on the allocation detail page  
- Click on the `release cgray` button at the top in the yellow banner  

We'll go back to activating that request in a bit....

For more information about configuring Allocation Change Requests [see here](#more-info-on-allocation-change-requests) 


### Create a New Project & Request Allocations for Cloud Resource  

Now that you've set up the new cloud resource, let's create a new project and request an allocation it:  

- Using the `ColdFront Administration` page, use the "Login As" option: Under the `Authentication and Authorization` section, click on `Users` then click on `sfoster`  
- At the top right, click on `Login As` which redirects us to the ColdFront home page for the user     
- Click the `Add a project` button and fill out the `Title` and `Description` fields and select a field of science. Click the `Save` button  
- Once redirected to the project detail page, click `Request Resource Allocation` under the Allocations section  
- Select the cloud resource from the drop down, provide a justification, enter the number of CPU hours, and click the `Submit` button.  
Click on the `release sfoster` button at the top in the yellow banner

As the admin, let's configure and activate that allocation:  

- From the `ColdFront Administration` page, click on the `View Site` link at the top right
- Navigate to the `Admin` menu and click on `Allocation Requests`  
- Click on the `Details` button next to the `Research Cloud` allocation request to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu:  
`Core Usage (Hours)` Enter: `10000`  
`Cloud Storage Quota (TB)` Enter: `10`  
`Cloud Account Name` Enter: `cgray`  
Notice as you add the core usage and cloud storage quota attributes you see usage graphs displayed.  These can tie into a plugin such as XDMoD or the OpenStack community developed plugins for usage information 
- Click the `Approve` button to change the allocation status to `Active` and set the expiration date out one year from now

Now let's go look at and activate the allocation change request submitted by `cgray` for the storage resource.  
- Navigate to the `Admin` menu and click on `Allocation Change Requests`  
- Click on the `Details` button to review and approve the allocation changes requested.  As the admin you have the ability to approve the date extension, change it to another setting or select `no extension`  You can remove the `storage_quota` request or change it.  You can add notes for the PI and users on the allocation to see.  Then you can take action such as `Approve` or `Deny` the request.  For this demo, let's click the `Approve` button
- At the bottom of the page, click the `View Allocation` button and notice the `Storage Quota` attribute value has changed from the origianl 10000 to whatever you set it as


### Removing Access  

When an allocation expires or is revoked, the users on that allocation should lose access to the resource.  If the allocation has the `freeipa_group` attribute set, all allocation users are removed from the group when the FreeIPA plugin is run.  If the allocation is for a Slurm resource, all Slurm user associations and the Slurm account are removed when the Slurm plugin is run.  Let's expire a Slurm allocation and then run the `slurm_check` tool.  

- Navigate to the `Admin` menu, click on `All allocations` and click on the allocation for the HPC cluster resource 
- Change the status to `Expired` and the End Date to today.  Click the `Update` button

- If you're not still logged into the coldfront container, log back in via the terminal & activate the ColdFront virtual environment:  

```
ssh -p 6222 hpcadmin@localhost  
ssh coldfront  
source /srv/www/venv/bin/activate  
```
- Use the Coldfront slurm_check tool to remove access for the expired allocation.  This first command looks at everything in slurm and compares it to what's in ColdFront:  
```
coldfront slurm_check -c hpc
```

- For the tutorial we created slurm accounts for all the test accounts in the database.  This allows the other parts of the tutorial to work independently of the ColdFront piece.  However, when we run this command it's not finding allocations for all of these accounts so it wants to remove them.  We definitely don't want that!  We'll specify the cgray account so it only removes those:  
```
coldfront slurm_check -c hpc -s -x -a cgray
```
The `-s` flag tells it to actually sync to slurm so you'll see it removed the user associations for cgray and csimmons and removed the cgray slurm account.  You can use the `-n` flag to run in `noop` mode which will give a listing of what it will change without doing the sync.   

- Let's look at cgray's slurm account again:  
```
sacctmgr show user cgray -s list
```
There should be no account or association listed any longer  

### Staff Member View  

We have set up the `astewart` account as an example of what a center staff member might see in ColdFront.  
- Log in as `astewart` password `ilovelinux` to see what additional menus and functionality this account has access to 
- Navigate to the `Staff` menu and click through the menu options to get a sense of the access we recommend for staff members
- Click on the `User Search` menu option and enter one of the other account names and click the `Search` button.  Click on the username and then click on the `View User Projects and Managers` button.  You'll see a list of projects the user is a member of and if they are a PI or manager on any of them
- Log out  

You can see how these different permissions were set up for the tutorial in the [pre-seeding section](#seeding-the-database-for-the-full-day-tutorial) below.  

For more options on allowing permissions for various types of staff access, see the ColdFront manual:  https://coldfront.readthedocs.io/en/latest/manual/users/  


That wraps up the full day tutorial but there is a lot more you can do with ColdFront.  See the steps we did to [pre-seed the database](#seeding-the-database-for-the-full-day-tutorial) for this tutorial and the [documentation for more info](https://coldfront.io).

</details>  
<br>



## Half Day Tutorial: Using ColdFront  
<details>
If interested, you can [view the steps taken](#seeding-the-database-for-the-half-day-tutorial) to pre-seed the database for this condensed version of the tutorial.  

Before beginning the tutorial, you must stop the containers, copy in the correct database, and then restart the containers.  Follow these steps:  

```
./hpcts destroy
cp coldfront/db_options/coldfront-half.dump database/coldfront.dump
./hpcts start
```

Once the containers are started, navigate to the [ColdFront site - https://localhost:2443](https://localhost:2443).

### PI View:  Annual Project Review, Allocation Renewal & Allocation Change Requests

- Log in as `cgray` password `test123`
- Click on the project and review the information we've added as part of the database pre-seeding.  There is project information populated and several allocations listed.  One allocation is coming up for renewal and will expire in less than a month.  Notice the `Needs Review` label next to the project
- Click on the `Add Users` button and in the search box enter `csimmons` then click the `Search` button
- You'll be presented the user information for the `csimmons` account as well as a list of allocations on the project.  You can choose to add the account to either of the allocations or all of them. You may also change the role of the account from `User` to `Manager`
- Then click the `Add Selected Users to Project` button and you'll be returned to the Project Detail page
- Click on the yellow `Expires in X days Click to renew` banner next to the allocation coming up on expiration and try to renew it.  You should see a warning banner telling you it can't be done because the project review is due

NOTE:  When a project review is required, a PI can't request new allocations or allocation change requests nor renew expiring allocations.  They can, however, add/remove users, publications, grants, and research output  

- Click the `Review Project` link to start the project review process.  Provide a reason for not providing grant or publication information, check the box to acknowledge the update and click the `Submit` button

- Now try to renew the expiring allocation. Your request should be accepted and the allocation should now be in the `Renewal Requested` status.  It's now possible to request new allocations or allocation changes as well

- Navigate back to the project detail page and click on the actions icon next to the `Project Storage` resource which takes you to the Allocation Detail page.  Click on the `Request Change` button, select a date extension, enter a new amount of storage, and provide a justification.  Then click the `SUBMIT` button.  You should now see a pending allocation change request on the allocation detail page.
- Log out

### Center Director View: Project Review Approval
At part of the database seeding we did at the start of the tutorial, we configured the user `sfoster` with the `Staff Status` role and gave the account permissions to act as the Center Director.  This allows `sfoster` to view all projects, allocations, publications, and grants.  We've also given permission to view the pending project review list.  

- Log in as `sfoster` password `ilovelinux` to see what additional menus and functionality this account has access to
- Navigate to the `Staff` menu and click on `Project Reviews`  
Click the `Email` button to see this functionality.  Go back to the `Project Reviews` and click `Mark Complete`
- Log out  

For more options on allowing permissions for various types of staff access, see the ColdFront manual:  https://coldfront.readthedocs.io/en/latest/manual/users/.


### Activate the allocation request  

- Navigate to the `Admin` menu and click on `Allocation Requests`  
Note: the project review status is a green check mark, indicating our Center Director has already approved the submitted project review.  

At part of the database seeding we did at the start of the tutorial, we activated and set attributes on the allocations requested on the `cgray` project.  Let's look at that allocation and how it was set up. 

- Click the `Details` button to review the Allocation Detail page
- Notice that allocation status is `Renewal Requested` and there is a start and end date associated with it
- Scroll down to look at the allocation attributes set. There is a slurm_account attribute as well as slurm_specs and slurm_user_specs attributes.  This is what is used by the Slurm plugin to sync with the Slurm database
- Click the `Approve` button to re-activate the allocation.  This updates the status to `Active` and changes the expiration date to one year from today

Now let's go look at and activate the allocation change request submitted by `cgray` for the storage resource.  As the HPC admin user, activate and set up the new allocation:  
- Navigate to the `Admin` menu and click on `Allocation Change Requests`  
- Click on the `Details` button to review and approve the allocation changes requested.  As the admin you have the ability to approve the date extension, change it to another setting or select `no extension`  You can remove the `storage_quota` request or change it.  You can add notes for the PI and users on the allocation to see.  Then you can take action such as `Approve` or `Deny` the request.  For this demo, let's click the `Approve` button

For more information about configuring Allocation Change Requests [see here](#more-info-on-allocation-change-requests) 

- Log out as the `hpcadmin` user   

### Try to run a job as the PI user  
Now let's go outside of ColdFront to the command line and try to submit a batch job as the `cgray` user.  
- Log in to the frontend container:  
`ssh -p 6222 hpcadmin@localhost`  
password: `ilovelinux`  
Switch to the PI user account:  
`su - cgray`  
password: `test123`  
`sbatch --wrap "sleep 600"`  
You will get an error message that you do not have permission to run on the cluster  
`sbatch: error: Batch job submission failed: Invalid account or account/partition combination specified.`  
_**This is because we have not synced the allocation information in ColdFront with Slurm yet.**_  
- Type `exit` to log out of the cgray account and you should be on the frontend logged in as the hpcadmin account 

### Run Slurm plugin to sync active allocations from ColdFront to Slurm
- Log in to the coldfront container & set up ColdFront environment  
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
- Log out of ColdFront container
`exit`  

### Log in (or go back) to frontend container
NOTE: you should already be on the frontend but just in case you're not:  
`ssh -p 6222 hpcadmin@localhost`  
password: `ilovelinux`  

Switch over to the PI user account and try to run a job again:    
`su - cgray`  
password: `test123`  
`sbatch --wrap "sleep 600"`  
`squeue`  (the job should be running on a node)  
`exit` (log out from cgray account)  

Tip:  You can also view information about this job in OnDemand, even though you launched the job from the command line.  [Log in](https://localhost:3443) as the PI user and navigate to the `Jobs` menu, selecting `Active Jobs` from the drop down menu.  
</details>  
<br>

# Reference Section  
The information in this section can be used for reference or to go through the tutorial pre-seeding steps and see how all the set up was done to get the database in the state we needed it for the half day and full day tutorials or to start from scratch.    

## Seeding the Database for the Full Day Tutorial 
<details>
These steps were done in advance to allow for the presentation of a more hands-on tutorial which spends time on learning the features rather than the minutia of the set up.  If you would like to go through these steps yourself, destroy the containers, delete the ColdFront database, and start the containers.  This will create a new, empty ColdFront database.  Then you'll be able to log in to ColdFront and follow these steps to populate the database.  

```
./hpcts destroy
rm database/coldfront.dump
./hpcts start
```

### Log in to ColdFront, set up account permissions & create resource  
URL https://localhost:2443/  
You'll need to log in as some of the users for this tutorial to get things started.  Do NOT use the OpenID Connect log in option at this point.
- Log in locally as username `hpcadmin` password: `ilovelinux`
- Log out
- Log in locally as username `cgray` password: `test123`
- Log out  
- Log in locally as username `csimmons`  password: `ilovelinux`  
- Log out  
- Log in locally as username `sfoster` password: `ilovelinux`  
- Log out  
- Log in locally as username `astewart` password: `ilovelinux`  
- Log out  
- Log in locally as username `admin` password: `admin`
- Go to Admin menu and click on `ColdFront Administration`  Once there, scroll halfway down to the `Authentication and Authorization` section.  Then click on the `Users` link
- Click on the `hpcadmin` user and scroll down to the `Permissions` section  
- Make this user a `superuser` by checking the boxes next to `Staff Status` and `Superuser Status` - scroll to the bottom and click `SAVE`  
- Click on the `sfoster` account.  Under the `User Permissions` section add permissions to make this user the Center Director  
 `allocation | allocation | Can manage invoice`   
 `allocation | allocation | Can view all allocations`  
 `grant | grant | Can view all grants`  
 `project | project | Can view all projects`  
 `project | project | Can review pending project reviews`  
 `publication | publication | Can view publication`   
- Scroll to the bottom and click `SAVE` 
- Click on the `astewart` account and check the box next to `Staff Status`.  Under the `User Permissions` section add additional view permissions for projects and allocations to replicate what you might provide a center staff member    
 `allocation | allocation | Can view all allocations`  
 `project | project | Can view all projects`  
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
 See more info on the [OnDemand plugin](#more-info-on-the-ondemand-plugin) in the resources section below

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

### 

### Create a project & request an allocation  
As the PI user: Create a project and request an allocation for the new resource:  
- Log in as the PI using local account username: `cgray` password: `test123`
- Click the `Add a project` button to create a new project, filling in the name, description, and selecting any field of science  
- Once redirected to the project detail page, request an allocation by clicking on the `Request Resource Allocation` button.  Select the `hpc` resource from the drop down menu, provide any justification, and click the `Submit` button    
- Request another allocation by clicking on the `Request Resource Allocation` button.  Select the `Project Storage` resource from the drop down menu, enter a quantity in TB or leave the default 1, provide any justification, and click the `Submit` button    
- Log out  

### Activate the allocation requests  
As the HPC admin user, activate and set up the new allocation:  
- Log in using local account username: `hpcadmin` password: `ilovelinux`  
- Navigate to the `Admin` menu and click on `Allocation Requests`  
- Click on the `Details` button next to the `HPC Cluster` allocation request to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu:  
`slurm_account_name` Enter: `cgray`  
`slurm_specs` Enter: `Fairshare=100`  
`slurm_user_specs` Enter: `Fairshare=parent`  
- Set the status to `Active`, set the start date to today, and set the expiration date to the end of this month.  If you click the `Approve` button, this will set the status to `Active` and set the expiration date out to one year from today.  For the purposes of this demo, we wanted to shorten the allocation length.  [See here](https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings) for more on changing the allocation length default
- Click the `Update` button  
- Return back to the `Admin` menu and click on the `Allocation Requests`  
- Click on the `Details` button next to the `Project Storage` allocation request to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu and set their values:   
`freeipa_group` Enter: `grp-cgray`  
`Storage Quota (GB)` Enter: `1000`  
add a description to let the user know the directory name: `/projects/cgray`  
- Click the `Approve` button  


### Annual Project Review  
When the project review functionality is enabled (it is by default) a PI will be forced to review their project once every 365 days.  We can force a project to be under review in less than a year which is what we'll do for the cgray project. [See here](https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings) for more on disabling the annual project review process.  

- If necessary, log in as `hpcadmin` password `ilovelinux`  
- Navigate to the `Admin` menu and click on the `ColdFront Administration` link.  Scroll to the `Project` section and click on `Projects` then click on the project that we created earlier.  Check the box next to `Force Review`  
- Scroll to the bottom and click the `Save` button
NOTE: If there is a project you never want project reviews on, uncheck 'Requires review' 
</details>  
<br>

## Starting from Scratch (Half Day Tutorial)
<details>
These steps were done in advance to allow for the presentation of a condensed half day version of the tutorial.  If you would like to go through these steps yourself, destroy the containers, and delete the ColdFront database. Start the containers which will create a new, empty coldfront database.  Then log in to ColdFront and follow the steps below:

```
./hpcts destroy
rm database/coldfront.dump
./hpcts start
```

### Log in to ColdFront, set up account permissions & create resource  
URL https://localhost:2443/  
You'll need to log in as some of the users for this tutorial to get things started.  Do NOT use the OpenID Connect login option at this point.
- Log in locally as username `hpcadmin` password: `ilovelinux`
- Log out
- Log in locally as username `cgray` password: `test123`
- Log out  
- Log in locally as username `csimmons`  password: `ilovelinux`  
- Log out  
- Log in locally as username `sfoster` password: `ilovelinux`  
- Log out  
- Log in locally as username `astewart` password: `ilovelinux`  
- Log out  
- Log in locally as username `admin` password: `admin`
- Go to Admin menu and click on `ColdFront Administration`  Once there, scroll halfway down to the `Authentication and Authorization` section.  Then click on the `Users` link 
- Click on the `hpcadmin` user and scroll down to the `Permissions` section  
- Make this user a `superuser` by checking the boxes next to `Staff Status` and `Superuser Status` - scroll to the bottom and click `SAVE`  
- Click on the `sfoster` account.  Under the `User Permissions` section add permissions to make this user the Center Director  
 `allocation | allocation | Can manage invoice`   
 `allocation | allocation | Can view all allocations`  
 `grant | grant | Can view all grants`  
 `project | project | Can view all projects`  
 `project | project | Can review pending project reviews`  
 `publication | publication | Can view publication`   
- Scroll to the bottom and click `SAVE` 
- Click on the `astewart` account and check the box next to `Staff Status`.  Under the `User Permissions` section add additional view permissions for projects and allocations to replicate what you might provide a center staff member    
 `allocation | allocation | Can view all allocations`  
 `project | project | Can view all projects`  
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
 See more info on the [OnDemand plugin](#more-info-on-the-ondemand-plugin) in the resources section below

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
- We will not set any resource attributes on this resource.  Scroll to the bottom and click `SAVE`

Add an allocation attribute type:  
- Click on the Home link to go to back to the Admin interface.  Under the `Allocation` section click on `Allocation attribute types`
- Click `Add Allocation Attribute Type` button, select `Text` from the `Attribute Type` drop down menu and name it `Storage Directory`  Make sure all checkboxes are unchecked and click the `SAVE` button

Make an allocation attribute changeable:  
- Under the `Allocation` section, click on `Allocation Attribute Types`  
- Click on `Storage Quota` check the box next to `Is changeable` and then click the `SAVE` button
- Log out  

### Create a project & request an allocation  
As the PI user: Create a project and request an allocation for the new resource:  
- Log in as the PI using local account username: `cgray` password: `test123`
- Click the `Add a project` button to create a new project, filling in the name, description, and selecting any field of science  
- Once redirected to the project detail page, request an allocation by clicking on the `Request Resource Allocation` button.  Select the `hpc` resource from the drop down menu, provide any justification, and click the `Submit` button    
- Request another allocation by clicking on the `Request Resource Allocation` button.  Select the `Project Storage` resource from the drop down menu, enter a quantity in TB or leave the default 1, provide any justification, and click the `Submit` button    
- Log out  

### Activate the allocation requests  
As the HPC admin user, activate and set up the new allocation:  
- Log in using local account username: `hpcadmin` password: `ilovelinux`  
- Navigate to the `Admin` menu and click on `Allocation Requests`  
- Click on the `Details` button next to the `HPC Cluster` allocation request to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu:  
`slurm_account_name` Enter: `cgray`  
`slurm_specs` Enter: `Fairshare=100:DefaultQOS=normal`  
`slurm_user_specs` Enter: `Fairshare=parent:DefaultQOS=normal`  
- Set the status to `Active`, set the start date to today, and set the expiration date to the end of this month.  If you click the `Approve` button, this will set the status to `Active` and set the expiration date out to one year from today.  For the purposes of this demo, we wanted to shorten the allocation length.  [See here](https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings) for more on changing the allocation length default
- Click the `Update` button  
- Return back to the `Admin` menu and click on the `Allocation Requests`  
- Click on the `Details` button next to the `Project Storage` allocation request to configure and activate the allocation:  
click the `Add Allocation Attribute` button and select these allocation attributes from the drop down menu and set their values:   
`freeipa_group` Enter: `grp-cgray`  
`Storage Quota (GB)` Enter: `1000`  
- Click the `Approve` button  

### Annual Project Review  
When the project review functionality is enabled (it is by default) a PI will be forced to review their project once every 365 days.  We can force a project to be under review in less than a year which is what we'll do for the cgray project. [See here](https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings) for more on disabling the annual project review process.  

- If necessary, log in as `hpcadmin` password `ilovelinux`  
- Navigate to the `Admin` menu and click on the `ColdFront Administration` link.  Scroll to the `Project` section and click on `Projects` then click on the project that we created earlier.  Check the box next to `Force Review`  
- Scroll to the bottom and click the `Save` button
NOTE: If there is a project you never want project reviews on, uncheck 'Requires review' 

This wraps up the setup done to the ColdFront database to prepare for the condensed half-day tutorial format.  
</details>  
<br>

## More info on Allocation Change Requests  
Allocation change requests are turned on by default.  This will allow PIs to request date extensions for their allocations.  The date ranges default to 30, 60, & 90 days but can be set changed or disabled completely in `hpc-toolset-tutorial/coldfront/coldfront.env`  
See https://coldfront.readthedocs.io/en/latest/config/#coldfront-core-settings for more information.

If you want PIs to be able to request changes to allocation attributes (i.e. storage quotas, unix group) this needs to be set on the allocation attribute.  For this demo, we allowed the PI to request changes on the `Storage Quota` attribute.  


## More info on the OnDemand Plugin  
This is a very simple example of modifying the ColdFront configuration to use a plugin.  This  plugin allows us to provide a link to our OnDemand instance for any allocations for resources that have "OnDemand enabled".

We have already added the OnDemand instance URL to the ColdFront config.  You can see this outside the containers in your git directory:  See `hpc-toolset-tutorial/coldfront/coldfront.env`.

When creating the resource at the start of the tutorial, we added the `OnDemand` attribute to the `hpc` resource which tells it to display the OnDemand logo and link to the OnDemand URL for any allocations for this resource.  Notice on the ColdFront home page next to the allocation for the HPC cluster resource you see the OnDemand logo.  Click on the Project name and see this logo also shows up next to the allocation.  When we click on that logo, it directs us to the OnDemand instance.


## ColdFront Installation & Configuration
- View `hpc-toolset-tutorial/coldfront/install.sh` to see how ColdFront is installed
- View `hpc-toolset-tutorial/coldfront/coldfront.env` to see how ColdFront is configured  
- This is where you'd enable or disable any plugins and set variables for your local installation.  Check out the [full configuration options available in the ColdFront documentation](https://coldfront.readthedocs.io/en/latest/config/)  
- View `hpc-toolset-tutorial/coldfront/coldfront-nginx.conf` for an example of ColdFront web configuration  

## Tutorial Navigation
[Next - Open OnDemand](../ondemand/README.md)  
[Previous Step - Accessing the Applications](../docs/applications.md)  
[Docker Tips](../docs/docker_tips.md)  
[Back to Start](../README.md)
