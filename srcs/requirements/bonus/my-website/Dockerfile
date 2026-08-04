FROM node:20.11.1-bookworm AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone --depth 1 --branch uv1.0.0 https://github.com/ybutkov/startbootstrap-resume.git .

RUN npm install && npm run build

FROM debian:bookworm-slim

ARG NGINX_VERSION=1.22.1-9+deb12u9

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nginx=${NGINX_VERSION} \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]