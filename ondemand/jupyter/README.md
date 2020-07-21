# Batch Connect - Example Jupyter Notebook Server

![GitHub Release](https://img.shields.io/github/release/osc/bc_example_jupyter.svg)
![GitHub License](https://img.shields.io/github/license/osc/bc_example_jupyter.svg)

An example Batch Connect app that launches a Jupyter Notebook server within a
batch job.

## Prerequisites

This Batch Connect app requires the following software be installed on the
**compute nodes** that the batch job is intended to run on (**NOT** the
OnDemand node):

- [Jupyter Notebook](http://jupyter.readthedocs.io/en/latest/) 4.2.3+ (earlier
  versions are untested but may work for you)
- [OpenSSL](https://www.openssl.org/) 1.0.1+ (used to hash the Jupyter Notebook
  server password)

**Optional** software:

- [Lmod](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod)
  6.0.1+ or any other `module purge` and `module load <modules>` based CLI
  used to load appropriate environments within the batch job before launching
  the Jupyter Notebook server.

## Install

These are command line only installation directions.

We start by downloading a zipped package of this code. This allows us to start
with a fresh directory that has no git history as we will be building off of
this.

```sh
# Download the zip from the GitHub page
wget https://github.com/OSC/bc_example_jupyter/archive/master.tar.gz

# Create a catchy directory
mkdir my_jupyter_app

# Unzip the downloaded file into this directory
tar xzvf master.tar.gz -C my_jupyter_app --strip-components=1

# Change the working directory to this new directory
cd my_jupyter_app
```

From here you will make any modifications to the code that you would like and
version your changes in your own repository:

```sh
# Version our app by making a new Git repository
git init

#
# Make all your code changes while testing them in the OnDemand Dashboard
#
# ...
#

# Add the files to the Git repository
git add --all

# Commit the staged files to the Git repository
git commit -m "my first commit"
```

## Contributing

1. Fork it ( https://github.com/OSC/bc_example_jupyter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
