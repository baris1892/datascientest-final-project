ARG DOCKER_HUB="docker.io"
ARG NGINX_VERSION="1.25-alpine"
ARG NODE_VERSION="18-alpine"

# -----------------------------
# Stage 1: Build
# -----------------------------
FROM $DOCKER_HUB/library/node:$NODE_VERSION AS build

WORKDIR /workspace
COPY . /workspace/

ARG NPM_REGISTRY="https://registry.npmjs.org"

# Setup npm and build
RUN echo "registry = \"$NPM_REGISTRY\"" > /workspace/.npmrc && \
    npm install && \
    npx ng build --configuration production


# -----------------------------
# Stage 2: Runtime
# -----------------------------
FROM $DOCKER_HUB/library/nginx:$NGINX_VERSION AS runtime

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

## Copying build artifacts to nginx webroot
COPY --from=build /workspace/dist /usr/share/nginx/html/

# Adjust permissions for non-root execution
RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

EXPOSE 8080

USER nginx

HEALTHCHECK     CMD     [ "service", "nginx", "status" ]
