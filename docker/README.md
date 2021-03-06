# Docker Instructions

Note: This is a WIP! So it probably will break. You've been warned! :D

How to build your own Docker container running Foundry VTT. This assumes you have some prior knowledge of docker.

This will build out a Foundry VTT container based on the `node:14` official image. It's about 1.33 GB in size total.

### Pre-requisites:

* PATREON_KEY
* FOUNDRY_VERSION

### Build commands:

* CD to the directory where the `dockerfile` is located at.
* Run this command: 

  `docker build --build-arg PATREON_KEY="<VERSION>-<INSERT YOUR KEY>" --build-arg FOUNDRY_VERSION="<INSERT CURRENT VERSION>" -t foundry .`

  Note: the `<VERSION>` in this case is `055`, so update as needed when new versions come out.
* Or if you are using Podman (highly recommended) then run this command:

  `podman build --build-arg PATREON_KEY="<VERSION-<INSERT YOUR KEY>" --build-arg FOUNDRY_VERSION="<INSERT CURRENT VERSION>" -t foundry .`

  (Podman is for running but is uses Buildah underneath to build the image. You can also just us Buildah instead of Podman if you want)

* After a few minutes a docker image will be on your local system. Proceed to the next section to run your new image!

### Run commands:

* Now that your image is built locally, you can then run it with the following command: 

   `docker run --rm -d --name foundryvtt -v $PWD/foundrydata:/foundrydata:rw -p 80:30000 foundry:latest`

   Few notes:

     * `--rm` - removes the container when it stops. Helps keep your system clean. **Optional.**
     * `--name foundryvtt` is the name if your running container. Feel free to change it to something else. **Optional.**
     * `-d` - runs the process as a daemon. If removed it will run in the foreground (could be good for debugging). **Optional.**
     * `-v <PATH TO YOUR FOUNDRY DATA>:rw` - path outside of Docker where your data is stored. By default containers are read-only so any data written to a container while it is running is destroyed when the container is stopped. This allows you to store your worlds, data, config, etc on your local drive and mounting it to the container while it is running. **Required.**
     * `-p 80:30000` - maps the internal port of Foundry to your external port of 80. Feel free to change as necessary. Port 80 is a default web port. **Required**
     * `foundry:latest` - If you built the container on the Build commands first then this is the name:tag of your built image. **Required.**
* You can do a `docker ps` and should see a running container now!

* To stop your running container run this command:

   `docker stop <CONTAINER ID>`
* Browse to your local IP or localhost and boom! Enter your license key and voila! Play Foundry! Aw yeah.

### Vagrant

There is a `Vagrantfile` here that will install Fedora32 as well as Docker and Docker Compose. It's a WIP so could break. Steps to run it are as follows:

1. Download and install Vagrant
2. From the directory you have the Vagrantfile in run `vagrant plugin install vagrant-docker-compose` to install the Docker-compose plugin.
3. Run `vagrant up` and wait a few minutes.
4. Once VM is up you can `vagrant ssh` to ssh into the VM and run docker or podman or whatever.