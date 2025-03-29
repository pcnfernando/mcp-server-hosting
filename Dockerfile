FROM node:20-alpine

# Create app directories and npm cache directories with proper permissions
RUN mkdir -p /app/data && \
    mkdir -p /.npm/_cacache && \
    mkdir -p /.npm/_logs && \
    chmod -R 777 /app && \
    chmod -R 777 /.npm

# Install required packages globally
RUN npm install -g supergateway @modelcontextprotocol/server-filesystem @modelcontextprotocol/mcp-server-git

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

RUN chmod +x /app/start.sh

# Set environment variables
ENV PORT=8000 \
    BASE_URL=http://localhost:8000 \
    SSE_PATH=/sse \
    MESSAGE_PATH=/message \
    DATA_FOLDER=./data \
    SERVER_TYPE=mcp-server-git \
    NODE_PATH=/usr/local/lib/node_modules \
    NPM_CONFIG_CACHE=/.npm

WORKDIR /app
EXPOSE 8000

# Start the server
CMD ["/app/start.sh"]
