FROM node:20-alpine

# Set working directory
WORKDIR /app

# Create necessary directories with proper permissions
RUN mkdir -p /app/data && \
    mkdir -p /.npm && \
    chmod -R 777 /.npm && \
    chmod -R 777 /app

# Pre-install required packages globally as root to avoid permission issues later
RUN npm config set ignore-scripts false && \
    npm install -g supergateway @modelcontextprotocol/server-filesystem mcp-server-git

# Create the startup script
RUN echo '#!/bin/sh' > /app/StartupScript.sh && \
    echo 'set -e' >> /app/StartupScript.sh && \
    echo 'echo "Starting MCP Server with the following configuration:"' >> /app/StartupScript.sh && \
    echo 'echo "Port: $PORT"' >> /app/StartupScript.sh && \
    echo 'echo "Base URL: $BASE_URL"' >> /app/StartupScript.sh && \
    echo 'echo "SSE Path: $SSE_PATH"' >> /app/StartupScript.sh && \
    echo 'echo "Message Path: $MESSAGE_PATH"' >> /app/StartupScript.sh && \
    echo 'echo "Data Folder: $DATA_FOLDER"' >> /app/StartupScript.sh && \
    echo 'echo "Server Type: $SERVER_TYPE"' >> /app/StartupScript.sh && \
    echo '' >> /app/StartupScript.sh && \
    echo '# Make sure the data directory exists' >> /app/StartupScript.sh && \
    echo 'mkdir -p $DATA_FOLDER' >> /app/StartupScript.sh && \
    echo '' >> /app/StartupScript.sh && \
    echo '# Start the MCP server using globally installed packages' >> /app/StartupScript.sh && \
    echo 'supergateway --stdio "$SERVER_TYPE $DATA_FOLDER" --port $PORT --baseUrl $BASE_URL --ssePath $SSE_PATH --messagePath $MESSAGE_PATH' >> /app/StartupScript.sh && \
    chmod +x /app/StartupScript.sh

# Create non-root user for better security
RUN addgroup -g 10014 nodeuser && \
    adduser -u 10014 -G nodeuser -s /bin/sh -D nodeuser && \
    chown -R nodeuser:nodeuser /app

# Set environment variables with defaults that can be overridden
ENV PORT=8000
ENV BASE_URL=http://localhost:8000
ENV SSE_PATH=/sse
ENV MESSAGE_PATH=/message
ENV DATA_FOLDER=./data
ENV SERVER_TYPE=mcp-server-git
ENV HOME=/tmp
ENV NPM_CONFIG_CACHE=/.npm
ENV NODE_PATH=/usr/local/lib/node_modules

# Switch to non-root user
USER 10014

# Expose the default port
EXPOSE 8000

# Start the MCP server using the script
CMD ["sh", "/app/StartupScript.sh"]
