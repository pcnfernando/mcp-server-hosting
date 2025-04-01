FROM node:20-alpine

# Build arguments with defaults (can be overridden during build)
ARG USER_ID=10014
ARG GROUP_ID=10014
ARG NODE_VERSION=20
ARG PORT=8000
ARG BASE_URL=http://localhost:8000
ARG SSE_PATH=/sse
ARG MESSAGE_PATH=/message
ARG DATA_FOLDER=./data
ARG SERVER_TYPE=@modelcontextprotocol/server-filesystem
ARG ADDITIONAL_PACKAGES=""

# Create non-root user with configurable ID
RUN addgroup -g $GROUP_ID nodeuser && \
    adduser -u $USER_ID -G nodeuser -s /bin/sh -D nodeuser

# Create app directories
RUN mkdir -p /app/data && \
    chmod -R 777 /app && \
    chown -R $USER_ID:$GROUP_ID /app

# Install core MCP packages and any additional packages specified
RUN npm install -g @pcnfernando/supergateway \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-github \
    $ADDITIONAL_PACKAGES

# Create dynamic startup script
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'set -e' >> /app/start.sh && \
    echo 'echo "Starting MCP Server with the following configuration:"' >> /app/start.sh && \
    echo 'echo "Port: $PORT"' >> /app/start.sh && \
    echo 'echo "Base URL: $BASE_URL"' >> /app/start.sh && \
    echo 'echo "SSE Path: $SSE_PATH"' >> /app/start.sh && \
    echo 'echo "Message Path: $MESSAGE_PATH"' >> /app/start.sh && \
    echo 'echo "Data Folder: $DATA_FOLDER"' >> /app/start.sh && \
    echo 'echo "Server Type: $SERVER_TYPE"' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo '# Set npm cache to /tmp which is guaranteed to be writable' >> /app/start.sh && \
    echo 'export NPM_CONFIG_CACHE=/tmp/.npm' >> /app/start.sh && \
    echo 'mkdir -p /tmp/.npm' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo 'mkdir -p $DATA_FOLDER' >> /app/start.sh && \
    echo '' >> /app/start.sh && \
    echo '# Run with explicit npm settings' >> /app/start.sh && \
    echo 'NODE_ENV=production npm_config_cache=/tmp/.npm npx -y @pcnfernando/supergateway --header X-Accel-Buffering:no --stdio "NODE_ENV=production npm_config_cache=/tmp/.npm npx -y $SERVER_TYPE $DATA_FOLDER" --baseUrl $BASE_URL --port $PORT --ssePath $SSE_PATH --messagePath $MESSAGE_PATH' >> /app/start.sh && \
    chmod 755 /app/start.sh && \
    chown $USER_ID:$GROUP_ID /app/start.sh

# Set environment variables (can be overridden at runtime)
ENV PORT=$PORT \
    BASE_URL=$BASE_URL \
    SSE_PATH=$SSE_PATH \
    MESSAGE_PATH=$MESSAGE_PATH \
    DATA_FOLDER=$DATA_FOLDER \
    SERVER_TYPE=$SERVER_TYPE \
    NODE_PATH=/usr/local/lib/node_modules \
    NPM_CONFIG_CACHE=/tmp/.npm \
    HOME=/home/nodeuser

WORKDIR /app

# Switch to non-root user
USER 10014

EXPOSE $PORT

# Start the server
CMD ["/bin/sh", "/app/start.sh"]
