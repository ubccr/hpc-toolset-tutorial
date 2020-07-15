# Open OnDemand Tutorial

## External links

* [Online Documentation](https://osc.github.io/ood-documentation/master/)
* [Jupyter Install Tutorial](https://osc.github.io/ood-documentation/master/app-development/tutorials-interactive-apps/add-jupyter.html)

## Jupyter Installation Tutorial

This tutorial will be using the the `hpcadmin` credentials listed in
[the getting started documentation](../docs/getting_started.md).

### Getting Started

#### Login

Now you should login to Open OnDemand through `https://localhost:3443`.  Note that you'll have to
accept the self-signed certificates from both Open OnDemand and the identity provider.

Now you should login to Open OnDemand through `https://localhost:3443`.  Note that you'll have to
accept the self-signed certificates from both Open OnDemand and the identity provider.

#### Get a shell session

At some points during this tutorial you'll need to execute commands in a shell session.
You can [use the shell app](https://localhost:3443/pun/sys/shell/ssh/frontend)
to get an ssh session in the web browser for this purpose.

#### Create the jupyter application

Click on "My Sandbox Apps (Development)" from the dropdown menu "Develop" in the navigation bar
to navigate to the sandbox app workspace.

IMG NEEDED

Now create a new app from the button labeled "New App".

IMG NEEDED

This will bring you to a page where you'll click "Clone Existing App" which will bring you to
this form to fill out.  

Fill in `jupyter` as the directory name. `/var/git/bc_example_jupyter` as the Git Remote and
check "Create a new Git Project from this?".  Then click "Submit" to create a new development
application.

IMG NEEDED

This copied what was in `/var/git/bc_example_jupyter` to `/home/hpcadmin/ondemand/dev/jupyer`. 
You can navigate to these files [through the Files app with this link](https://localhost:3443/pun/sys/files/fs/home/hpcadmin/ondemand/dev/jupyter/)
or simply Press the "Files" button in Jupyter's row of the sandbox applications table.

IMG NEEDED

You'll also need to setup `git` for the hpcadmin user at this point.

Configure your user email and name so that you can commit changes to the jupyter app.

```shell
git config --global user.email hpcadmin@localhost
git config --global user.name "HPC Admin"
```

### Get Jupyter Working

#### Configure the correct cluster

The example application we've created does not use the correct cluster configuration, so we've got
to modify it.

We need to edit the `form.yml` in the appication's folder. We can navigate to the folder through the
files app.  The URL is `https://localhost:3443/pun/sys/files/fs/home/hpcadmin/ondemand/dev/jupyter/`.

Here you'll see the `form.yml` file. We can edit it by clicking on the file and pressing the "Edit"
button.  This will take us to the [file editor app, with this file open](https://localhost:3443/pun/sys/file-editor/edit/home/hpcadmin/ondemand/dev/jupyter/form.yml)

IMG NEEDED

In the file Editor, specify `hpc` as the cluster attribute on line 11 like so: `cluster: "hpc"`. Save this file by clicking
the "Save" button at the top left.

IMG NEEDED

#### Launch the Jupyter Application

Now when we navigate back to our [interactive sessions](https://localhost:3443/pun/sys/dashboard/batch_connect/sessions),
you'll see the "Interactive Apps \[Sandbox\]" menu with an item labeled "Jupyter Notebook".

IMG NEEDED

[Follow this link](https://localhost:3443/pun/sys/dashboard/batch_connect/dev/jupyter/session_contexts/new) and we'll be
presented with this form for specifying different attributes about the job we want to submit to the SLURM scheduler.

IMG NEEEDED

We don't need to change anything in this form, so simply press "Launch" at the bottom of the form. After pressing
launch the job should have successfully launched the job and redirected us back
the [interactive sessions](https://localhost:3443/pun/sys/dashboard/batch_connect/sessions) page where we'll
see a panel showing our job.  

Initially the panel will be grey because our job is being scheduled and jupyter is starting.  When it is
up and running and available to use the panel will show a "Connect to Jupyter" button.  Click this button
and OnDemand will redirect us to Jupyter.  

IMGs NEEDED

Congratulations! We've now started development on the Jupyter Notebook batch connect application and
successfully connected to it.

You may want to delete this job now by using the "Delete" button on the panel as we'll be iterating through
developing the application and starting new jobs.

#### Save your spot

Now it's probably a good idea to save the modifications. They're small, but it'll still help if you
ever get into trouble and need to revert. A simplified version of the `form.yml` is in the very next
section, and you may want to use and save _it_ instead so that any `git diff` you do will be much
smaller and easier to read.

You can use the
[shell app to login to this directory](https://localhost:3443/pun/sys/shell/ssh/default/home/hpcadmin/ondemand/dev/jupyter/)

In this shell you'll save in git with these commands:

```shell
git add .
git commit -m 'initial commit that correctly submits to the hpc cluster'
```

### A closer look at the form.yml

The items in the form.yml directly create what's shown to the users in the form they interact with.
Let's take a closer look at the `form.yml` that created the form you just submitted to get an
understanding of how they relate to what's shown in the UI.

This is the `form.yml` you at this point without all the comments.
```yaml
cluster: "hpc"
attributes:
  modules: "python"
  extra_jupyter_args: ""
form:
  - modules
  - extra_jupyter_args
  - bc_account
  - bc_queue
  - bc_num_hours
  - bc_num_slots
  - bc_email_on_started
```

All fields pre-pended with `bc_` are special fields OnDemand provides for convenience. They are commonly
used fields that create corresponding script attribute.  We'll talk more about script attributes later.

* `modules` Specifies the modules loaded. Since it's hard coded to "python" (in the attributes) 
    we didn't see it in the form.
* `extra_jupyter_args` Specifies the extra jupyter arguments but since it's hard coded to "" we didn't
    didn't see it in the form.
* `bc_account` Creates the "Account" text field and submits the job with the given account.
* `bc_queue` Creates the "Partition" text field and submits the job to the given partition.
* `bc_num_hours` Creates the "Number of hours" integer field and submits the job with the given
    walltime.
* `bc_num_slots` Creates the "Number of nodes" integer field and submits the job with the requested
    cores.
* `bc_email_on_started` Creates the "I would like to receive an email when the session starts" checkbox
    and submits the job with a request to email when the job starts.

### Updating the Jupyter App

#### Change bc_queue to a select field

We have 2 partitions enabled in the SLURM containers (SLURM calls queues partitions, so we'll be switching
back and forth between the two terms in this tutorial). We've started with a field `bc_queue` that
is a text field, but it's likely much easier for users to simply choose the partition out of a
select dropdown menu instead.

So let's remove the `bc_queue` field in the form and replace it with a new field we'll call `custom_queue`.
Add `custom_queue` in the form section and remove bc_queue.  

We'll also add `custom_queue` to the attributes section.  Adding a field to the form section adds it to the form
in the UI.  By default, this field will be a text field. If you want this field to be a different type of widget
(as we do) you'll configure the field in the attributes section.  Also by default the label in the UI is the
same just the name of the field. In our case `custom_queue` would turn into "Custom Queue".  This is only
slightly correct, so we want to specify the label as "Partition" because that's what it is in SLURM parlance.

Here you can see that we specify the `custom_queue` in the attributes as a select widget with two options.
and a new label. The first element in options arrays is what will be shown to the user (the capitalized version)
where the second element is the value what's actually used in the sbatch command.

```yaml
# other things in form.yml removed for brevity, but should still exist in yours
attributes:
  custom_queue:
    widget: "select"
    label: "Partition"
    options:
      - ["Compute", "compute"]
      - ["Debug", "debug"]
form:
  - custom_queue
#   - bc_queue
```

Refresh the [new session form](https://localhost:3443/pun/sys/dashboard/batch_connect/dev/jupyter/session_contexts/new)
and you should now see your updates.

But before we submit to test them out, we'll need to reconfigure the `submit.yml.erb` to use this
new field.  You can edit it in the
[file editor app](https://localhost:3443/pun/sys/file-editor/edit/home/hpcadmin/ondemand/dev/jupyter/submit.yml.erb).

You'll need to specify the script's queue_name as the partition like so. The `script` is the logical
"script" we're submitting to the scheduler.  And the `queue_name` is the field of the script that will
specify the queue. (in SLURM parlance it's called partition, so that's why we're calling it partition, but
OnDemand does this translation at lower layer).

```yaml
script:
  queue_name: "<%= custom_queue %>"
```

Here you'll notice that the file extension is `.erb` and the `<%= custom_queue %>` is a little strange.
That's because this file is a embedded ruby template file and `<%= custom_queue %>` is ERB template syntax for
turning the `custom_queue` variable (defined in the `form.yml` and specified by the user when they press "Launch")
into a string for the yml file.

If you're not super comfortable with the terminology just remember this: `custom_queue` is defined in the `form.yml`
(the file that defines what the UI form looks like) so it can be used in the `submit.yml.erb` (the file
that is used to configure the job that is being submitted) as `<%= custom_queue =>`.

At this point, this should be the entirety of the `script.yml.erb` and `form.yml` (without comments).
They're given here in full if you want to copy/paste them. And remember to [save your spot](#save-your-spot)!

```yaml
# script.erb.yml
script:
  queue_name: "<%= custom_queue %>"
```

```yaml
# form.yml
cluster: "hpc"
attributes:
  modules: "python"
  extra_jupyter_args: ""
  custom_queue:
    widget: "select"
    label: "Partition"
    options:
      - ["Compute", "compute"]
      - ["Debug", "debug"]
form:
  - modules
  - extra_jupyter_args
  - bc_account
  - custom_queue
  - bc_num_hours
  - bc_num_slots
  - bc_email_on_started
```

#### Limit bc_num_cores

SLURM is configured with only 2 cores total.  If you were now to submit this app
with say 3 or more `bc_num_slots` it would sit in the queue forever because SLURM
cannot find a suitable host to run it on.

So, let's limit this field to a max of 2.

```yaml
# form.yml
attributes:
  bc_num_slots:
    max: 2
```

That's it! Again, because `bc_num_slots` is convenience field, it already has a minimum of 1
that you can't override, because it doesn't make sense to specify 0 or less cores.

#### Using script native attributes

`script.native` attributes are way for us to specify any arguments to the schedulers that
we can't pre-define or have a good generic way of doing it.

In this section we're going to put make OnDemand request memory through the sbatch's 
`--mem` argument.

First, let's add it to the form like so.

Here are descriptions of all the fields we applied to it.  Note if the label was not
not defined the default 'Memory' would have been OK.  Also we don't really need the
the help message here, it was really just for illustration.

* `widget` specifies the type of widget to be a number
* `max` the maximum value, 2 GB in this case
* `min` the minimum value, 256 MB
* `step` the step size when users increase or decrease the value
* `value` the default value of 512 MB
* `label` the for UIs label
* `help` a help message

```yaml
# form.yml, with only this addition for brevity
attributes:
  memory:
    widget: "number_field"
    max: 1024
    min: 256
    step: 256
    value: 512
    label: "Memory (MB)"
    help: "RSS Memory"
form:
  - memory
```

Again, now to actually use the value we populate in the form, we need to use
it in the `submit.yml.erb`.  This is where `script.native` attributes come in.

```yaml
# script.erb.yml
script:
  native:
    - "--mem"
    - "<%= memory %>M"
```

Native attributes are an array and they're passed to the schedule just as they're
defined here.

This would translate into a command much like: `sbatch --mem 768M`.  As you can see
native allows us to pass _anything_ we wish into the scheduler command.

To confirm your job is running with the correct memory parameters, simply
[login to a shell](#get-a-shell-session) and run the command below. You should see output like this.

```shell
[hpcadmin@frontend ~]$ squeue -o "%j %m"
NAME MIN_MEMORY
sys/dashboard/dev/jupyter 768M
```

At this point, this should be the entirety of the `script.yml.erb` and `form.yml` (without comments).
They're given here in full if you want to copy/paste them. And remember to [save your spot](#save-your-spot)!

```yaml
# script.erb.yml
---
script:
  queue_name: "<%= custom_queue %>"
  native:
    - "--mem"
    - "<%= memory %>M"
```

```yaml
# form.yml
cluster: "hpc"
attributes:
  modules: "python"
  extra_jupyter_args: ""
  custom_queue:
    widget: "select"
    label: "Partition"
    options:
      - ["Compute", "compute"]
      - ["Debug", "debug"]
  bc_num_slots:
    max: 2
  memory:
    widget: "number_field"
    max: 2048
    min: 256
    step: 256
    value: 512
    label: "Memory (MB)"
    help: "RSS Memory"
form:
  - modules
  - extra_jupyter_args
  - bc_account
  - custom_queue
  - bc_num_hours
  - bc_num_slots
  - bc_email_on_started
  - memory
```

## Tutorial Navigation
[Next - Acknowledgments](../docs/acknowledgments.md)
[Previous Step - Open XDMoD](../xdmod/README.md)
[Back to Start](../README.md)
