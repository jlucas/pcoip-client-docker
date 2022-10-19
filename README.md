![pterribledici](/static/pterribledici.png)

## pcoip-client-docker
This is a fork of PaulGallon's pcoip-client-docker that brings it a bit more up to date.

This lets you run Teradici's PCoIP Client for Linux in a Docker container.  It includes support if your host is running an Nvidia card.

YMMV.

### Setup
* Update the `.env` file with the username/uid/gid of the user on your host you'll be running the container as.
* `make build` for non-nvidia systems / `make build-nvidia` for nvidia systems
* `make up` to start the container

### Thanks
* Teradici's setup instructions [here](https://www.teradici.com/web-help/pcoip_client/linux/20.07/reference/docker_containers/)
* @jlucas for the logo
