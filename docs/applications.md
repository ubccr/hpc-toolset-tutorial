## Accessing the Applications

Now that your containers have been created and applications launched, you can login to them using your browser and via SSH.

### User Accounts

By default, all containers have local user accounts created. You can login with
to the containers via ssh, login to Coldfront and OnDemand with the same user
credentials. Default password for all accounts: ilovelinux

- hpcadmin
- cgray (password: test123)
- sfoster
- csimmons
- astewart

### Coldfront

Login to Coldfront and setup allocations.

Point your browser at the Coldfront container https://localhost:2443

You can login with user: admin password: admin

You can also login with any of the local system accounts that were created.

### OnDemand

Login to OnDemand

Point your browser at the OnDemand container https://localhost:3443

You can login with any of the local system accounts that were created. Click on
"Clusters" and then "HPC Cluster Shell Access" and you should have a login
shell on the frontend container.

### XDMoD

Login to XDMoD

Point your browser at the XDMoD container https://localhost:4443

You can login with user: admin password: admin

### Cluster Frontend

Login to frontend with SSH:
```
ssh -p 6222 hpcadmin@localhost
```

### Slurm

ssh into the frontend and run a job:

```
$ ssh -p 6222 cgray@127.0.0.1

[cgray@frontend ~]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
compute*      up 5-00:00:00      2   idle cpn[01-02]

[cgray@frontend ~]$ srun -N1 hostname
cpn01

[cgray@frontend ~]$ sbatch --wrap="uptime"
Submitted batch job 3

[cgray@frontend ~]$ ls
slurm-3.out

[cgray@frontend ~]$ cat slurm-3.out
 04:11:15 up 12:15,  0 users,  load average: 0.03, 0.29, 0.37

# Test you can ssh into the first compute node from the frontend.
[cgray@frontend ~]$ ssh cpn01

[cgray@cpn01 ~]$ ls
slurm-3.out
```

## Tutorial Navigation
[Next - ColdFront](../coldfront/README.md)  
[Previous Step - Getting Started](getting_started.md)  
[Back to Start](../README.md)  
