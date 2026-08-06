*This project has been created as part of the 42 curriculum by ybutkov.*

## Description

This project is a complete web infrastructure set up using **Docker** and **Docker Compose** for the **42 Inception** subject. The entire stack runs in isolated containers without using pre-built images from Docker Hub (except for base OS images like Alpine or Debian) to provide a secure web stack with HTTPS access, persistent storage, private networking, and secret handling.

## Included Services

* **NGINX:** Serves as the single HTTPS entry point (TLS v1.2/v1.3) and reverse proxy.
* **WordPress + PHP-FPM:** The main website application running via PHP FastCGI.
* **MariaDB:** The relational database for storing WordPress content.
* **Redis:** In-memory caching service to speed up WordPress performance.
* **Adminer:** Web-based database management tool.
* **Portainer:** Web UI for managing Docker containers and environments.
* **FTP Server:** Allows direct file transfers to the WordPress data directory.
* **Bonus Website:** A static personal site hosted alongside the main infrastructure.

## Main Design Choices

This project follows the requirements of the 42 Inception subject while applying common Docker best practices.

- **Container Isolation** – Each service runs in its own dedicated container. This keeps services independent, improves security, and makes maintenance and debugging easier.
- **Single Entry Point** – NGINX is the only service exposed to the outside world through HTTPS (port 443). It acts as a reverse proxy and forwards requests to the appropriate internal services.
- **Private Internal Network** – All backend services (WordPress, MariaDB, Redis, FTP, Adminer, Portainer, and the static website) communicate through an isolated Docker bridge network and are not directly accessible from outside the stack unless explicitly required.
- **Persistent Storage** – WordPress files and MariaDB data are stored in Docker named volumes located under `/home/<login>/data` on the host machine, ensuring data survives container recreation.
- **Custom Images** – Every service is built from its own custom Dockerfile using Debian as the base image, in accordance with the project requirements. No pre-built service images are used.
- **Configuration Management** – General configuration is stored in `srcs/.env`, while confidential information such as passwords and TLS certificates is managed using Docker Secrets.
- **Service Independence** – Each container has a single responsibility (NGINX, MariaDB, WordPress, Redis, FTP, Adminer, Portainer, etc.), following Docker's recommended design principles.

## Technology Comparisons

### Virtual Machines vs Docker

**Virtual Machines** run a complete guest operating system on top of a hypervisor. They provide strong isolation but require significantly more CPU, memory, and storage resources.

**Docker Containers** share the host operating system kernel while isolating applications and their dependencies. They are lightweight, start quickly, and consume considerably fewer resources.

**Project Choice:** Docker was selected because it allows multiple independent services to run efficiently inside a single virtual machine while satisfying the requirements of the Inception subject.

### Secrets vs Environment Variables

**Environment Variables** are suitable for non-sensitive configuration such as domain names, usernames, and service settings.

**Docker Secrets** are designed for confidential information such as passwords, TLS certificates, and private keys. Secrets are mounted as temporary read-only files inside containers instead of being exposed as environment variables.

**Project Choice:** This project stores sensitive credentials using Docker Secrets, while keeping general configuration in `srcs/.env`.

## Instructions

### Prerequisites

- Docker Engine with Compose V2 support
- GNU Make
- OpenSSL
- A local domain mapping for `login`.42.fr and the bonus domain me.`login`.42.fr
- Access to the host directories used for persistent project data

### On a new machine

1. Clone the repository and enter the project directory.

```bash
git clone <repository-url>
cd inception
```

2. Create or copy the environment file at [srcs/.env](./srcs/.env). It must contain the host paths used by Docker Compose, including the secret file locations.

3. Create or copy the required secret files under [secrets/](./secrets). At minimum, this includes the database, WordPress, FTP, and Portainer password files.

4. Create or copy the TLS certificate files under [secrets/certs/](./secrets/certs). If they are missing, the `make` target will generate them automatically.

5. Make sure the host names resolve to the machine IP address in your local hosts file.

6. You can also use the `cpenv` Makefile rule to sync `.env` and `secrets/` to another machine after adjusting the paths in the rule.

### Build and run

From the repository root, run:

```bash
make
```

This command prepares the required host directories, generates the TLS certificate if needed, builds the custom Docker images, and starts the full stack.

### Main Makefile targets

- `make` — build and start the project
- `make down` — stop and remove the containers
- `make stop` — stop the containers
- `make start` — restart the containers
- `make logs` — follow service logs
- `make clean` — remove containers, networks, and volumes
- `make fclean` — remove all generated data from the host directories
- `make info` — display Docker resources and project state

You can find the full operational documentation in [USER_DOC.md](./USER_DOC.md) and [DEV_DOC.md](./DEV_DOC.md).

## Usage

Once the stack is running, the following endpoints are available:

- https://ybutkov.42.fr — main WordPress website
- https://ybutkov.42.fr/adminer/ — Adminer interface
- https://ybutkov.42.fr/portainer/ — Portainer interface
- https://me.ybutkov.42.fr — bonus personal website

If the domain does not resolve locally, it should be added to the hosts file and pointed to the VM IP address.

## Project structure

- Makefile — orchestration layer for the project
- srcs/docker-compose.yml — service definitions, networks, volumes, and secrets
- srcs/.env — environment configuration values
- secrets/ — secret files used by Docker secrets
- srcs/requirements/ — custom Dockerfiles and per-service configuration files

## Resources

* Docker documentation: https://docs.docker.com/
* Docker Compose documentation: https://docs.docker.com/compose/
* NGINX documentation: https://nginx.org/en/docs/
* WordPress documentation: https://wordpress.org/documentation/
* WordPress & PHP-FPM Setup Guides: https://wiki.alpinelinux.org/wiki/WordPress
* MariaDB documentation: https://mariadb.com/kb/en/documentation/
* Redis documentation: https://redis.io/docs/
* OpenSSL documentation: https://www.openssl.org/docs/
* Start Bootstrap https://startbootstrap.com/
* 42 Inception Subject Rules

AI tools were used to help draft and refine the Docker configuration, container scripts, and documentation. The final implementation was reviewed and validated manually to ensure that it matched the project requirements.
