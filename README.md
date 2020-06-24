# HPC Toolset Tutorial

Tutorial for installing and configuring [OnDemand](https://openondemand.org/), [XDMoD](https://open.xdmod.org), and [ColdFront](http://coldfront.io): an HPC center management toolset.

This tutorial aims to demonstrate how three open source applications work in concert to provide a toolset for high performance computing (HPC) centers. ColdFront is an allocations management portal that provides users an easy way to request access to allocations for a Center's resources.  HPC systems staff configure the data center’s resources with attributes that tie ColdFront’s plug-ins to systems such as job schedulers, authentication/account management systems, system monitoring, and XDMoD.  Once the user's allocation is activated in ColdFront, they are able to access the resource using OnDemand, a web-based portal for accessing HPC services that removes the complexities of HPC system environments from the end-user.  Through OnDemand, users can upload and download files, create, edit, submit and monitor jobs, create and share apps, run GUI applications and connect to a terminal, all via a web browser, with no client software to install and configure.  The XDMoD portal provides a rich set of features, which are tailored to the role of the user.  Sample metrics provided by Open XDMoD include: number of jobs, CPUs consumed, wait time, and wall time, with minimum, maximum and the average of these metrics. Performance and quality of service metrics of the HPC infrastructure are also provided, along with application specific performance metrics (flop/s, IO rates, network metrics, etc) for all user applications running on a given resource.  With the new release of Open OnDemand, some user job metrics from XDMoD will be available right on the OnDemand dashboard!


## Requirements

For this tutorial you will need to have docker installed on your local machine.  This has been tested on Linux, MacOS, and Windows 10:

- docker version 19.03.8+
- docker-compose 1.25.2+

NOTE: For Windows, if you haven't already done so, you will need to configure git not to convert line endings into Windows format.  Run this command before cloning the tutorial repo:
```
git config --global core.autocrlf input
```


## Overview

In this tutorial we present three open source projects that form a core set of
utilities commonly installed at High Performance Computing (HPC) centers.

An overview of the containers in the cluster:

![Container Overview](docs/HPC-Toolset-sm.png)


## Tutorial Steps

[Getting Started](docs/getting_started.md)  
[Accessing the Applications](docs/applications.md)  
[ColdFront](../coldfront/README.md)  
[XDMoD](../xdmod/README.md)  
[OnDemand](../ondemand/README.md)  


## Docker Tips
Some useful info on navigating this tutorial and learning a bit about docker-compose

[Docker Tips](docker_tips.md)  
Docker-compose Tutorial (coming soon)

## Acknowledgments

The multi-container Slurm cluster using docker-compose is loosely based on the
following:

- https://github.com/giovtorres/slurm-docker-cluster
- https://github.com/OSC/ood-images/tree/master/docker-with-slurm

## License

This tutorial is released under the GPLv3 license. See the LICENSE file.
