### WORK IN PROGRESS ###

The four subdirectories each contain a docker container and the
Dockerfile used to create it. The container has a Linux distribution,
the NCEPLIBS, and a compiled ufs-weather-model.  The Dockerfile can be
used to recreate the container. The Dockerfile has a sequence of
installation commands on top of an initial Linux image. If you need to
install in another environment, such as a physical Linux installation
or cloud computing, you can manually run the commands on the target
machine or convert the Dockerfile to another format.

The four containers will work on any operating system with the Docker
Engine installed. Their names are based on the Linux distribution
found within. Due to the design of Docker, you can mix and match
operating systems: run the centos7 container on XUbuntu 18 or the
ubuntu20 container on Windows 10.

- ubuntu20 -- Based on the `ubuntu:20.04` image from DockerHub
- ubuntu18 -- Based on the `ubuntu:18.04` image from DockerHub
- centos7 -- Based on the `centos:centos7` image from DockerHub
- centos8 -- Based on the `centos:centos8` image from DockerHub



### Get Docker

Before you can follow any of these instructions, you need to install
the Docker Engine. The method depends on your platform. To get the
official Docker releases, go to their Release Channels. Otherwise,
your operating system's package repository may have Docker. It's
likely called "docker" or "docker.io"

If you want the most recent version of Docker, full instructions for
all platforms Docker supports are here:

* https://docs.docker.com/engine/install/

Relevant pages for Ubuntu and RedHat/CentOS:

* UBUNTU: https://docs.docker.com/engine/install/ubuntu/
* REDHAT/CENTOS: https://docs.docker.com/engine/install/centos/
* Optional post-install steps: https://docs.docker.com/engine/install/linux-postinstall/


### Security Risks

Containerization technologies such as Docker are security risks unless
they are used correctly. Before using Docker on a production
environment, or any other situation where the security of your machine
is critical, make sure you plan accordingly:

https://docs.docker.com/engine/security/security/

These containers were built and tested in a virtual machine, to fully
isolate Docker from the host. If your machine has hardware
virtualization support, that is an excellent option. Cloud computing
providers also use virtualization. Running inside a cloud provider's
container service is another option.



Importing and Running
---------------------

These instructions tell you how to run the docker container on a
typical Linux machine via the command line. The process is different
for Windows and MacOS. We assume you already have Docker installed


### STEP 1 (Plan A): Import the Compressed File

With recent software, you should be able to import the `*.tar.xz` file
directly to Docker:

    docker import docker-container.tar.xz

If it works, it'll print a long hexadecimal string; this is the hash
of your docker image:

    sha256:dc49f3340437448df52a27655ae8437961b39eaf2ceb7304a21591eeff6a5e48

If that worked, great! Jump to step 4, but don't lose that hash;
you'll need it soon.


### STEP 2 (Plan B): Decompress Manually

If Docker complains that it cannot understand the file format, you may
need to decompress the file using `xz`. To install `xz`:

    UBUNTU: sudo apt-get install xz-utils
    REDHAT/CENTOS: sudo yum install xz

Then decompress:

    xz -dk docker-container.tar.xz

There should now be a "docker-container.tar" file.


### STEP 3 (Plan B): Import the Decompressed File

Import the file you manually decompressed:

    docker import docker-container.tar

If it works, it'll print a long hexadecimal string; this is the hash
of your docker image. 

    sha256:dc49f3340437448df52a27655ae8437961b39eaf2ceb7304a21591eeff6a5e48

Remember the hash; you'll need it in step 4.


### STEP 4: Tag

Docker tags let you rename the hashes to something easily
remembered. In this example, let's call the image `ufs-srweather-v2`:

    docker tag dc49f3340437448df52a27655ae8437961b39eaf2ceb7304a21591eeff6a5e48 ufs-srweather-v2


### STEP 5: Get a login shell in the image

The "docker run" command creates a container from your image and runs
a command inside. We'll get a bash login shell:

    docker run -it ufs-srweather-v2 bash --login

You should now have a root login within your container.

    cd /usr/local/ufs-develop/src/ufs-weather-model/
    ls

You should see the familiar contents of the ufs-weather-model checkout:

    CMakeLists.txt  LICENSE.md  WW3        build.sh  fms_files.cmake  stochastic_physics
    FMS             NEMS        build      cmake     modulefiles      tests
    FV3             README.md   build.log  conf      parm             ufs_weather_model

The bottom-right file is the executable.



Rebuilding
----------

This section tells you how to recreate the docker container from the
Dockerfile. 

If you want to do this, we suggest you do NOT use the CentOS 7
Dockerfile because it compiles GCC, which can take a long time even on
large machines.



### STEP 2: Download NCEPLIBS-external OR Edit Dockerfile

It takes a long time to download the HDF5 repository within the
NCEPLIBS-external. If you're going to tweak the Dockerfile many times,
you'll want to download that software only once. That's the default
behavior as seen in these lines of the Dockerfile:

    COPY DATA/NCEPLIBS-external /usr/local/ufs-develop/src/NCEPLIBS-external
    # It takes an eternity to clone the HDF5 repo, so I kept a local disk copy of this:
    #RUN git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external /usr/local/ufs-develop/src/NCEPLIBS-external
    # If you prefer, comment out the COPY line and uncomment the "RUN git..." line

#### Option 1: Download NCEPLIBS-external

If you don't have the "git" command, you'll need to install it:

    UBUNTU: apt-get install git
    REDHAT/CENTOS: yum install git

Then download the NCEPLIBS-external where the Dockerfile expects it:

    mkdir DATA
    git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external DATA/NCEPLIBS-external

#### Option 2: Have the Docker Container Download it For You

As the comments say, if you only intend to build once, then comment
out the COPY line and uncomment the RUN line in the Dockerfile.

Change these two lines:

    COPY DATA/NCEPLIBS-external /usr/local/ufs-develop/src/NCEPLIBS-external
    #RUN git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external /usr/local/ufs-develop/src/NCEPLIBS-external

to this:

    #COPY DATA/NCEPLIBS-external /usr/local/ufs-develop/src/NCEPLIBS-external
    RUN git clone -b develop --recursive https://github.com/NOAA-EMC/NCEPLIBS-external /usr/local/ufs-develop/src/NCEPLIBS-external

Now the COPY command is commented out, and the RUN command is uncommented.


### STEP 3: Build

Change your working directory (`cd`) to the directory with the `Dockerfile` and run:

    docker build .

You should see a long sequence of installation and build commands for
several hours. On an especially slow machine, it may take a
day. Eventually, if all goes according to plan, you should see a
message like this, but with a different hash:

    Successfully built a379fe2388c2

Now tag the hash, giving it a nickname you'll remember:

    docker tag a379fe2388c2 my-ufs-srweather-v2


### STEP 4 (Optional) Export

To get the tar file we distribute, do this:

    docker export my-ufs-srweather-v2 > my-ufs-srweather-v2.tar

### STEP 5 (Optional) Compress the Exported File

We used `xz -9` to compress the files, which may take several hours on a slow machine.

To get xz:

    UBUNTU: sudo apt-get install xz-utils
    REDHAT/CENTOS: sudo yum install xz

To compress:

    xz -9 --compress --stdout my-ufs-srweather-v2.tar > my-ufs-srweather-v2.tar.xz

### STEP 6: Run

The process is the same as running from our distributed docker container.
The "docker run" command creates a container from your image and runs
a command inside. We'll get a bash login shell:

    docker run -it my-ufs-srweather-v2 bash --login

You should now have a root login within your container.

    cd /usr/local/ufs-develop/src/ufs-weather-model/
    ls

You should see the familiar contents of the ufs-weather-model checkout:

    CMakeLists.txt  LICENSE.md  WW3        build.sh  fms_files.cmake  stochastic_physics
    FMS             NEMS        build      cmake     modulefiles      tests
    FV3             README.md   build.log  conf      parm             ufs_weather_model

The bottom-right file is the executable.
