# Stage 1: Install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Stage 2: Production runner
FROM node:20-alpine AS runner
WORKDIR /app

# Create data directory for persistent storage
RUN mkdir -p /app/data && chown -R node:node /app/data

# Copy dependencies and source code
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY server.js ./
COPY crypto-utils.js ./
COPY generate-secret.js ./
COPY public ./public

# Set default environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV DATA_DIR=/app/data

# Use non-root user
USER node

EXPOSE 3000

CMD ["node", "server.js"]
