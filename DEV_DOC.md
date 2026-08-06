# Developer Documentation

This document describes how to set up, build, manage, and inspect the **Inception** project infrastructure.

---

## 1. Environment Setup

### Prerequisites
Ensure the following tools are installed on your host system:
* `docker` (v20.10+)
* `docker-compose` (v2.0+)
* `make`
* `openssl`
* `git`

### Configuration & Secrets Setup

1. **Environment File (`srcs/.env`):**  
   Create the `srcs/.env` from template `srcs/.env.template` file containing domain definitions, usernames, and relative paths to secrets files.

2. **Secrets Directory (`secrets/`):**  
   Place plain text password files in the `secrets/` directory on the host:
   * `db_root_password.txt`
   * `db_admin_password.txt`
   * `db_wp_user_password.txt`
   * `wp_admin_password.txt`
   * `wp_user_password.txt`
   * `ftp_password.txt`
   * `portainer_admin_password.txt`

   These files are mounted into containers at runtime using **Docker Secrets** at `/run/secrets/`.

3. **Automatic Preparation (`make prepare`):**  
   Running `make prepare` (executed automatically during `make`) will:
   * Create host volume storage directories under `/home/<USER_LOG>/data/`(`mariadb`, `wordpress`, `redis`, `portainer`).
   * Generate self-signed TLS/SSL certificates (`.crt` and `.key`) under `srcs/secrets/certs/` using OpenSSL if they do not exist.

4. **Remote Sync Option (`make cpenv`):**  
   If developing locally, you can automatically sync your local `srcs/.env` and `secrets/` directory to your target Virtual Machine using(edit path into Makefile):
   ```
   make cpenv
   ```

---

## 2. Build & Launch

To build and start the entire stack:

```text
make
```

This runs the default rule (`all`), which executes `prepare` first to create required host directories and SSL certificates, and then launches all services in detached mode:

```text
USER_LOG=$(whoami) docker compose -f srcs/docker-compose.yml up -d --build
```

## 3. Container & Volume Management

All container lifecycle operations, log inspection, and system cleanups are managed via the `Makefile`:

### Container Management

* **`make up`** — Start existing containers without rebuilding images.
* **`make stop`** — Stop running containers without removing them.
* **`make start`** — Start stopped containers.
* **`make down`** — Stop and remove running containers and networks.
* **`make logs`** — Tail real-time console output from all running services (`docker compose logs -f`).

### Inspection & Debugging

* **`make info`** — Display a comprehensive status overview of the stack, including:
  * Container names, status, images, and mapped ports (`docker ps -a`)
  * Local Docker images (`docker images`)
  * Active Docker volumes (`docker volume ls`)
  * Docker networks (`docker network ls`)
  * Disk usage details (`docker system df`)
  * Persistent volume data size on the host (`du -sh /home/<USER_LOG>/data`)

### Cleanup & Maintenance

* **`make clean`** — Stop containers, remove them along with networks, built images, and Docker internal volumes.
* **`make fclean`** / **`make f`** — Perform a full system reset: runs `make clean` and recursively deletes all host storage directory contents in `/home/<USER_LOG>/data/*`.
* **`make re`** — Completely rebuild and restart the project from scratch (`fclean` followed by `all`).

## 4. Data Storage & Persistence

Project data is permanently stored on the host filesystem and mounted into containers via **bind mounts** to ensure data survives container restarts and rebuilds.

### Host Storage Location

All application data resides under the host directory `/home/$(USER_LOG)/data`:

* **MariaDB Database:** `/home/$(USER_LOG)/data/mariadb` (stores database tables and raw data)
* **WordPress Files:** `/home/$(USER_LOG)/data/wordpress` (stores site files, media, and plugins)
* **Redis Cache:** `/home/$(USER_LOG)/data/redis` (stores in-memory cache snapshots)
* **Portainer Data:** `/home/$(USER_LOG)/data/portainer` (stores management state and settings)

### Persistence Lifecycle

* **Container Restarts (`make stop` / `make start`):** Persistent data remains fully intact in host directories.
* **Stack Tear-down (`make down`):** Stopping and removing containers/networks leaves all files under `/home/$(USER_LOG)/data` untouched.
* **Docker Cleanup (`make clean`):** Removes container instances and images, but host storage directories remain intact.
* **Full Data Reset (`make fclean`):** Spawns an ephemeral Alpine container to execute `rm -rf /data/*` on the host path, permanently wiping all stored application data.
