# User documentation

## 1. Overview

This project is an infrastructure stack running in Docker. All services run inside isolated containers on a single internal network (`backend`).

### Provided Services

| Service | Container Name | Role |
|---|---|---|
| **NGINX** | `nginx` | Single HTTPS entry point and reverse proxy on host port `443` |
| **WordPress** | `wordpress` | PHP-FPM web server for WordPress |
| **MariaDB** | `mariadb` | Relational database backend |
| **Redis** | `redis` | In-memory cache for WordPress |
| **Adminer** | `adminer` | Web interface for database administration |
| **Portainer** | `portainer` | Container management UI |
| **FTP Server** | `ftp_server` | Passive FTP access to WordPress files |
| **My Website** | `my-website` | Static personal bonus website |

### Exposed Ports

| Service | Host Port | Container Port | Protocol |
|---|---|---|---|
| NGINX | `443` | `443` | HTTPS |
| FTP Server | `21` | `21` | FTP Command |
| FTP Server | `21210-21220` | `21210-21220` | FTP Passive Data |

## 2. Managing the Project

All operational commands must be executed using `make` from the repository root.

### Start the project

    make

This command will:
* create the required host directories for persistent data,
* generate the TLS certificate if it is absent,
* build the custom Docker images,
* start all services of the stack.

---

### Other Lifecycle Commands

* **Stop the stack:**

      make down

  *(Stops and removes running containers).*

* **Pause / Resume containers:**

      make stop
      make start

  *(Pauses or resumes containers without deleting them).*

* **Clean containers and images:**

      make clean

  *(Stops stack, removes images and volumes created by Compose).*

* **Full Reset (fclean):**

      make fclean

  *(Runs `make clean` and forcibly wipes all persistent host folders under `/home/<USER>/data/`).*

* **Rebuild everything from scratch:**

      make re

  *(Executes `make fclean` followed by `make`).*


## Available services

Once the project is running, the following services can be accessed:

- WordPress: https://ybutkov.42.fr
- Adminer: https://ybutkov.42.fr/adminer/
- Portainer: https://ybutkov.42.fr/portainer/

The main entry point is Nginx over HTTPS on port 443.

## 3. How to Access Services

Before accessing services via domain name, ensure that `<login>.42.fr` and `me.<login>.42.fr` are mapped to `127.0.0.1` in your host `/etc/hosts` file:

    127.0.0.1 <login>.42.fr me.<login>.42.fr
    127.0.0.1 ybutkov.42.fr me.ybutkov.42.fr  # Example for login 'ybutkov'

### Web Services

Note: Services can be accessed via domain or via `localhost`. Port `:443` is optional in HTTPS URLs.

* **Main WordPress Site:**

      https://<login>.42.fr
      https://ybutkov.42.fr   # Example for login 'ybutkov'
      https://localhost       # Access via localhost

* **WordPress Admin Panel:**

      https://<login>.42.fr/wp-admin
      https://ybutkov.42.fr/wp-admin   # Example for login 'ybutkov'
      https://localhost/wp-admin       # Access via localhost

* **Adminer (Database Administration):**

      https://<login>.42.fr/adminer/
      https://ybutkov.42.fr/adminer/   # Example for login 'ybutkov'
      https://localhost/adminer/       # Access via localhost

* **Portainer (Container Dashboard):**

      https://<login>.42.fr/portainer/
      https://ybutkov.42.fr/portainer/   # Example for login 'ybutkov'
      https://localhost/portainer/       # Access via localhost

* **Bonus Static Website:**

      https://me.<login>.42.fr
      https://me.ybutkov.42.fr  # Example for login 'ybutkov'

---

### FTP Service

To upload or manage WordPress files via FTP, connect using any FTP client (such as FileZilla or `ftp` CLI):

* **Host:**

      <login>.42.fr
      ybutkov.42.fr   # Example for login 'ybutkov'
      localhost       # Access via localhost

* **Command Port:** `21`
* **Passive Data Ports:** `21210-21220`
* **Username:** Defined in `srcs/.env` as `FTP_USER`
* **Password:** Stored in the file specified by `FTP_PASSWORD_HOST_FILE`

---

### Security Warning Notice

Because the TLS certificate is automatically generated during `make prepare` as a self-signed certificate, your browser will display a security warning upon your first visit. You must manually accept/bypass the warning to proceed to the site.

## 4. Environment Variables & Credentials

All project settings are managed via the `srcs/.env` file. Sensitive data (passwords, TLS certificates) are stored in local files under `srcs/secrets/` and mounted into containers via Docker Secrets.

### Service Credentials Summary

* **MariaDB (Database)**
  * **Root Superuser**

        Username:                root
        Password Host File:      MARIADB_ROOT_PASSWORD_HOST_FILE    = ../secrets/db_root_password.txt
        Password Container Path: MARIADB_ROOT_PASSWORD_FILE         = /run/secrets/mariadb_root_pass

  * **DB Admin User**

        Username:                MARIADB_ADMIN_USER                 = dbbigboss
        Password Host File:      MARIADB_ADMIN_PASSWORD_HOST_FILE   = ../secrets/db_admin_password.txt
        Password Container Path: MARIADB_ADMIN_PASSWORD_FILE        = /run/secrets/mariadb_admin_pass

  * **WP Application User**

        Username:                MARIADB_WP_USER                    = wp_db_user
        Password Host File:      MARIADB_WP_USER_PASSWORD_HOST_FILE = ../secrets/db_wp_user_password.txt
        Password Container Path: MARIADB_WP_USER_PASSWORD_FILE      = /run/secrets/mariadb_wp_user_pass

* **WordPress**
  * **Administrator**

        Username:                WP_ADMIN_USER                      = ybutkov
        Email:                   WP_ADMIN_EMAIL                     = ybutkov@student.42.fr
        Password Host File:      WP_ADMIN_PASSWORD_HOST_FILE        = ../secrets/wp_admin_password.txt
        Password Container Path: WP_ADMIN_PASSWORD_FILE             = /run/secrets/wp_admin_pass

  * **Regular User**

        Username:                WP_USER                            = justuser
        Email:                   WP_USER_EMAIL                      = justuser@student.42.fr
        Password Host File:      WP_USER_PASSWORD_HOST_FILE         = ../secrets/wp_user_password.txt
        Password Container Path: WP_USER_PASSWORD_FILE              = /run/secrets/wp_user_pass

* **FTP Server**
  * **FTP User**

        Username:                FTP_USER                           = ftp_user
        Password Host File:      FTP_PASSWORD_HOST_FILE             = ../secrets/ftp_password.txt
        Password Container Path: FTP_PASSWORD_FILE                  = /run/secrets/ftp_password

* **Portainer**
  * **Admin Dashboard**

        Admin login(default):                                       = admin
        Password Host File:      PORTAINER_PASSWORD_HOST_FILE       = ../secrets/portainer_admin_password.txt
        Password Container Path: PORTAINER_PASSWORD_FILE            = /run/secrets/portainer_admin_pass

---

### TLS Certificates Secrets

    NGINX Certificate Host:      NGINX_SSL_CERTIFICATE_HOST_FILE     = ../secrets/certs/inception_nginx.crt
    NGINX Certificate Container: NGINX_SSL_CERTIFICATE_FILE          = /run/secrets/nginx_cert
    NGINX Key Host:              NGINX_SSL_CERTIFICATE_KEY_HOST_FILE = ../secrets/certs/inception_nginx.key
    NGINX Key Container:         NGINX_SSL_CERTIFICATE_KEY_FILE      = /run/secrets/nginx_key

---

Credentials are not hard-coded in the Dockerfiles. They are loaded from the files stored in the secrets directory and referenced from srcs/.env.

If a password or credential needs to be changed, update the corresponding secret file and restart the stack.

## 5. Check services and health checks

Basic info:

```bash
make info
```

Check status (with health_checks):

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs

```bash
make logs
docker compose -f srcs/docker-compose.yml logs <service_name>
docker compose -f srcs/docker-compose.yml logs -f
```

## Troubleshooting

- Use make logs to inspect the output of the containers.
- Use make info to verify the state of containers, images and volumes.
- If a service fails, check its logs and confirm that its required secret file exists.
