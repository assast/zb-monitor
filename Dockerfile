# Stage 1: Install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production runner
FROM node:20-alpine AS runner
WORKDIR /app

# Install su-exec for dropping privileges
RUN apk add --no-cache su-exec

# Create data directory for persistent storage
RUN mkdir -p /app/data

# Copy dependencies and source code
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY server.js ./
COPY crypto-utils.js ./
COPY generate-secret.js ./
COPY public ./public

# Create entrypoint script to fix volume permissions at runtime
RUN printf '#!/bin/sh\nchown -R node:node /app/data\nexec su-exec node "$@"\n' > /app/entrypoint.sh \
    && chmod +x /app/entrypoint.sh

# Set default environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV DATA_DIR=/app/data

EXPOSE 3000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["node", "server.js"]
