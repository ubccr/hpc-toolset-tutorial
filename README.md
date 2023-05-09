# HPC Toolset Tutorial

Tutorial for installing and configuring [ColdFront](http://coldfront.io), [Open OnDemand](https://openondemand.org/), and [Open XDMoD](https://open.xdmod.org): an HPC center management toolset.  

### Presented by:

[![OSC Logo https://osc.edu](docs/osc_logo.png)](https://osc.edu)  
[![CCR logo](docs/ccr_logo.jpg)](https://buffalo.edu/ccr)  


This tutorial aims to demonstrate how three open source applications work in concert to provide a toolset for high performance computing (HPC) centers. ColdFront is an allocations management portal that provides users an easy way to request access to allocations for a Center's resources.  HPC systems staff configure the data center’s resources with attributes that tie ColdFront’s plug-ins to systems such as job schedulers, authentication/account management systems, system monitoring, and Open XDMoD.  Once the user's allocation is activated in ColdFront, they are able to access the resource using Open OnDemand, a web-based portal for accessing HPC services that removes the complexities of HPC system environments from the end-user.  Through Open OnDemand, users can upload and download files, create, edit, submit and monitor jobs, create and share apps, run GUI applications and connect to a terminal, all via a web browser, with no client software to install and configure.  The Open XDMoD portal provides a rich set of features, which are tailored to the role of the user.  Sample metrics provided by Open XDMoD include: number of jobs, CPUs consumed, wait time, and wall time, with minimum, maximum and the average of these metrics. Performance and quality of service metrics of the HPC infrastructure are also provided, along with application specific performance metrics (flop/s, IO rates, network metrics, etc) for all user applications running on a given resource.  


## Tutorial Steps

[Requirements](docs/requirements.md)  
[Getting Started](docs/getting_started.md)  
[Accessing the Applications](docs/applications.md)  
[ColdFront](/coldfront/README.md)  
[Open OnDemand](/ondemand/README.md)  
[Open XDMoD](/xdmod/README.md)  

[Acknowledgments](docs/acknowledgments.md)


## Workshops
This tutorial will be presented at the following conferences:

[PEARC23](https://pearc.acm.org/pearc23/)  
[ISC23](https://www.isc-hpc.com/)  
[PEARC22](https://pearc.acm.org/pearc22)  
[PEARC21](https://pearc.acm.org/pearc21)  
[PEARC20](https://pearc.acm.org/pearc20/)  
[Gateways 2020](https://sciencegateways.org/web/gateways2020)

This [overview of HPC Toolset Tutorial](https://www.youtube.com/watch?v=9Nf1GucaVc0) is provided as context to those finding this repo and wanting to go through the hands-on tutorial without attending the full day workshop at a conference.

## Disclaimer

**DO NOT run this project on production systems.** This project is for educational
purposes only. The container images we publish for the tutorial are configured
with hard coded insecure passwords and should be run locally in development for
testing and learning only. 

## License

This tutorial is released under the GPLv3 license. See the LICENSE file.
