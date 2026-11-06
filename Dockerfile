# ==========================================
# Stage 1: Build / Validation
# ==========================================
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./
COPY src ./src
COPY test ./test

# Validate application code
RUN npm run lint && npm test


# ==========================================
# Stage 2: Production Runtime
# ==========================================
FROM node:22-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production

# Copy package files and install production dependencies FIRST
COPY package*.json ./
RUN npm ci --omit=dev

# Copy application source code from build stage (or context)
COPY --from=build --chown=node:node /app/src ./src

# Remove global npm and npx for security hardening
RUN rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx

# Run as non-root user
USER node

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD node -e "fetch('http://127.0.0.1:8080/').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "src/server.js"]
