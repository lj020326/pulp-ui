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
# Create the nested directory structure expected by the bundle references
RUN mkdir -p /usr/share/nginx/html/static/pulp_ui
COPY --from=builder /app/dist /usr/share/nginx/html/static/pulp_ui

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
