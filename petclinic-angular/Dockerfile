ARG DOCKER_HUB="docker.io"
ARG NGINX_VERSION="1.25-alpine"
ARG NODE_VERSION="18-alpine"

# -----------------------------
# Stage 1: Build
# -----------------------------
FROM $DOCKER_HUB/library/node:$NODE_VERSION as build

WORKDIR /workspace
COPY . /workspace/

ARG NPM_REGISTRY="https://registry.npmjs.org"

# Setup npm and build
RUN echo "registry = \"$NPM_REGISTRY\"" > /workspace/.npmrc && \
    npm install && \
    npm run build

# -----------------------------
# Stage 2: Runtime
# -----------------------------
FROM $DOCKER_HUB/library/nginx:$NGINX_VERSION AS runtime

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

## Copying build artifacts to nginx webroot
COPY --from=build /workspace/dist /usr/share/nginx/html/

# Adjust permissions for non-root execution (DevOps best practice)
RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

EXPOSE 8080

USER nginx

HEALTHCHECK     CMD     [ "service", "nginx", "status" ]


#ARG DOCKER_HUB="docker.io"
## Updated to a more recent stable Nginx version
#ARG NGINX_VERSION="1.25-alpine"
## Updated to Node 18 to satisfy Angular CLI requirements (min 16.14)
#ARG NODE_VERSION="18-alpine"
#
#FROM $DOCKER_HUB/library/node:$NODE_VERSION as build
#
#WORKDIR /workspace
#COPY . /workspace/
#
#ARG NPM_REGISTRY="https://registry.npmjs.org"
#
## Setting up npmrc and building the app
#RUN echo "registry = \"$NPM_REGISTRY\"" > /workspace/.npmrc && \
#    npm install && \
#    npm run build
#
#FROM $DOCKER_HUB/library/nginx:$NGINX_VERSION AS runtime
#
## Copying build artifacts to nginx webroot
## Note: Ensure that the dist folder structure matches your project
#COPY --from=build /workspace/dist/ /usr/share/nginx/html/
#
##RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx && \
##    sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
##    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
#
#RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx && \
#    sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
#    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf && \
#    sed -i 's|try_files $uri $uri/ =404;|try_files $uri $uri/ /index.html;|' /etc/nginx/conf.d/default.conf
#
#
#EXPOSE 8080
#
#USER nginx
#
#HEALTHCHECK     CMD     [ "service", "nginx", "status" ]
