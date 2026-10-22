# Stage 1: Build the static assets
FROM node:24-alpine AS builder
WORKDIR /app

# Install git so webpack can resolve the commit hash
RUN apk add --no-cache git

COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

# Stage 2: Serve the static files via Nginx
FROM nginx:alpine
# Remove default nginx welcome page and assets
RUN rm -rf /usr/share/nginx/html/*

# Create the nested directory structure matching WEBPACK_PUBLIC_PATH
RUN mkdir -p /usr/share/nginx/html/static/pulp_ui

# Copy compiled bundles into the static path prefix
COPY --from=builder /app/dist /usr/share/nginx/html/static/pulp_ui

# Copy index.html and config JSON to the root nginx web directory
COPY --from=builder /app/dist/index.html /usr/share/nginx/html/index.html
COPY --from=builder /app/pulp-ui-config.json /usr/share/nginx/html/pulp-ui-config.json

# Copy custom Nginx configuration template
COPY default.conf.template /etc/nginx/templates/default.conf.template

# Nginx entrypoint automatically processes templates in /usr/share/nginx/html/ to /usr/share/nginx/html/
COPY pulp-ui-config.json.template /usr/share/nginx/html/pulp-ui-config.json.template

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
