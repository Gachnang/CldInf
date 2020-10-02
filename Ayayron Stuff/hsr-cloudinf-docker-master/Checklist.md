# Checklist
KVM:
- [x] Setup environment
- [x] Document environment
- [x] Enable VM autostart
- [x] Save final setup
- [x] Document Remove Uplink interface again on VM2

Docker:
- [x] Use the network diagram as reference where to place the docker containers.
- [x] Create for each connection between the containers different docker bridges. If possible make them “internal”.
- [x] The whole setup on your first VM (ubuntu-postgres) needs to be able to be started via a single docker-compose.yml file.
- [x] Create a second docker-compose.yml file for the DB container.
- [x] Each nodejs tier should have its own Dockerfile. To build these images its possible to do this directly inside the docker-compose.yml file. Check the “build” Docker Compose reference and its child options for further information (https://docs.docker.com/compose/compose-file/#build).
- [x] Ensure no processes inside the web and API Docker image run as user root – use a service user called cldinf instead.
- [x] Read the best practices guideline for writing Dockerfiles and improve your own Dock- erfiles.
- [x] Apply ressource limits to your containers: Limit CPU and Memory usage


Proxy
- [x] Traefik 2.0 as Docker Container
- [x] Valid Let’s Encrypt Certificate for HTTPS - group3.playground.ins.hsr.ch
- [x] Port 80 and 443 should be accessible from the Host VM
- [x] Redirect Port 80 to 443

Web:
- [x] For this tier the official node 8.16.1 Docker image from the Docker Hub should be taken as base image.
- [x] The nodejs web application should be accessible from Træfik via port 8888. This port should not be exposed to the host system!
- [x] The web application uses two environment variables:   
  ∗ API HOST: Hostname and port of the api container (syntax:container hostname:port)
  ∗ PORT: Port on which the web server should be listening.

Api:
- [x] For this tier the official node 8.16.1 Docker image from the Docker Hub should be taken as base image.
- [x] The nodejs api application should be accessible from the web tier via port 5050. This port should not be exposed to the host system!
- [x] The api application uses two environment variables:  
  ∗ DB: DB connection string (example:postgres://username:password@localhost/database)
  ∗ PORT: Port on which the api should be accessible.

Db:
- [x] The official Docker Hub postgres Docker image should be taken for this tier (https://hub.docker.com/ /postgres/). Use Version 10.10.
- [x] The default password of the image needs to be changed to something else. Use cldinf as the database name and database user.
- A database for the api tier should be automatically created when the container is started the first time.
- [x] Postgres should use the default port 5432.
- [x] Ensure the DB data is persistent.
- [x] Place the DB container on your second VM

Troubleshoot and final steps
- [x] Traefik LetsEncrypt config
- [x] Traefik Web Port not working
- [x] API connection to database not tested
- [x] Proxy binding to 10.0.1.10 seems not working
- [x] Docker swarm resources limiting still not working
- [x] Remove Uplink interface again on VM2

Deliverables:
- [x] README with documentation
- [x] 2 XML of the new linux bridges (natnetwork, hostonly)
- [x] 2 docker-compose files (for VM1, VM2)
- [x] 2 Dockerfiles (web, api)
- [x] Cloud-Init files