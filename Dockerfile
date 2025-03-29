FROM node:20-alpine

# Create non-root user with ID in required range (10000-20000)
RUN addgroup -g 10014 nodeuser && \
    adduser -u 10014 -G nodeuser -s /bin/sh -D nodeuser

# Create app directories
RUN mkdir -p /app/data && \
    chmod -R 777 /app && \
    chown -R 10014:10014 /app

# Install required packages globally
RUN npm install -g supergateway @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-github

# Create startup script using /tmp for npm cache
COPY <<-"EOT" /app/start.sh
#!/bin/sh
set -e
echo "Starting MCP Server with the following configuration:"
echo "Port: $PORT"
echo "Base URL: $BASE_URL"
echo "SSE Path: $SSE_PATH"
echo "Message Path: $MESSAGE_PATH"
echo "Data Folder: $DATA_FOLDER"
echo "Server Type: $SERVER_TYPE"

# Set npm cache to /tmp which is guaranteed to be writable
export NPM_CONFIG_CACHE=/tmp/.npm
mkdir -p /tmp/.npm

mkdir -p $DATA_FOLDER

# Run with explicit npm settings
NODE_ENV=production npm_config_cache=/tmp/.npm supergateway --stdio "NODE_ENV=production npm_config_cache=/tmp/.npm $SERVER_TYPE $DATA_FOLDER" --port $PORT --baseUrl $BASE_URL --ssePath $SSE_PATH --messagePath $MESSAGE_PATH
EOT

RUN chmod +x /app/start.sh && \
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
CMD ["/app/start.sh"]

# Create startup script with explicit npm cache settings
COPY <<-"EOT" /app/start.sh
#!/bin/sh
set -e
echo "Starting MCP Server with the following configuration:"
echo "Port: $PORT"
echo "Base URL: $BASE_URL"
echo "SSE Path: $SSE_PATH"
echo "Message Path: $MESSAGE_PATH"
echo "Data Folder: $DATA_FOLDER"
echo "Server Type: $SERVER_TYPE"

# Set explicit npm cache location and create directories if needed
export NPM_CONFIG_CACHE=/.npm
mkdir -p /.npm/_cacache /.npm/_logs
chmod -R 777 /.npm

mkdir -p $DATA_FOLDER

# Run with explicit npm settings
NODE_ENV=production npm_config_cache=/.npm supergateway --stdio "NODE_ENV=production npm_config_cache=/.npm $SERVER_TYPE $DATA_FOLDER" --port $PORT --baseUrl $BASE_URL --ssePath $SSE_PATH --messagePath $MESSAGE_PATH
EOT

RUN chmod +x /app/start.sh && \
    chown nodeuser:nodeuser /app/start.sh

# Set environment variables
ENV PORT=8000 \
    BASE_URL=http://localhost:8000 \
    SSE_PATH=/sse \
    MESSAGE_PATH=/message \
    DATA_FOLDER=./data \
    SERVER_TYPE=mcp-server-git \
    NODE_PATH=/usr/local/lib/node_modules \
    NPM_CONFIG_CACHE=/.npm \
    HOME=/home/nodeuser

WORKDIR /app

# Switch to non-root user for better security (ID 10014)
USER 10014

EXPOSE 8000

# Start the server
CMD ["/app/start.sh"]
