Interested in running Foundry VTT on GCP? Well, you're in the right place. The goal of this project is to enable you to run a Terraform script that will stand up your Foundry instance on GCP.

Directories:

* **ansible** - future Ansible scripts to configure application once Terraform stands it up
* **terraform** - Terraform plan to build GCP infrastructure
* **docker** - Docker container to run Foundry self-contained. Just mount your data directory!

__Requirements__

* Terraform installed locally
* A GCP Service account
* Ansible installed locally

notes:

Docker command to run container locally with shell access (for testing) - `docker run -it --rm --entrypoint /bin/sh foundry`

Docker build/run instructions:

* Build the container: `docker build --build-arg PATREON_KEY="<INSERT YOUR PATREON KEY>" -t foundry .`
* Then run the container: `docker run --rm --name foundryvtt -p 80:30000 foundry:latest`
  Note: this will be an interactive session. More to come on pushing this to a process so you can free your terminal. If you're running this on a dedicated server. More to come...
  
Foundry Docs:
* https://foundryvtt.com/article/installation/
* https://foundryvtt.com/article/hosting/

### Terraform

* Currently setup with a remote backend at Terraform.io. Free to use for single users/projects
* Create a `*.auto.tfvars` file with the following variables:

  * `localip = <YOUR IP>`
  * `project = <YOUR GCP PROJECT>`

  Alternatively, you can put these variables in the Terraform UI and just update them as they change. This is a bit easier if you do not want to manage multiple logins, etc.
