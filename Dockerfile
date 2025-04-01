FROM node:20-alpine

# Create non-root user with ID in required range (10000-20000)
RUN addgroup -g 10014 nodeuser && \
    adduser -u 10014 -G nodeuser -s /bin/sh -D nodeuser

# Create app directories
RUN mkdir -p /app/data && \
    chmod -R 777 /app && \
    chown -R 10014:10014 /app

# Install required packages globally
RUN npm install -g @pcnfernando/supergateway supergateway @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-github

# Create startup script with appropriate permissions from the beginning
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
    chown 10014:10014 /app/start.sh

# Set environment variables
ENV PORT=8000 \
    BASE_URL=http://localhost:8000 \
    SSE_PATH=/sse \
    MESSAGE_PATH=/message \
    DATA_FOLDER=./data \
    SERVER_TYPE=mcp-server-git \
    NODE_PATH=/usr/local/lib/node_modules \
    NPM_CONFIG_CACHE=/tmp/.npm \
    HOME=/home/nodeuser

WORKDIR /app

# Switch to non-root user for better security (ID 10014)
USER 10014

EXPOSE 8000

# Start the server
CMD ["/bin/sh", "/app/start.sh"]
