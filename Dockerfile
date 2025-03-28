FROM node:20-alpine

# Set working directory
WORKDIR /app

# Run as root for initial setup
# Create non-root user and prepare directories
RUN addgroup -g 10014 nodeuser && \
    adduser -u 10014 -G nodeuser -s /bin/sh -D nodeuser && \
    mkdir -p /app/data && \
    mkdir -p /home/nodeuser/.npm && \
    chown -R nodeuser:nodeuser /app && \
    chown -R nodeuser:nodeuser /home/nodeuser

# Create the startup script in the app directory
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
    echo '# Start the MCP server with the configured parameters' >> /app/StartupScript.sh && \
    echo 'npx -y supergateway --stdio "npx -y $SERVER_TYPE $DATA_FOLDER" --port $PORT --baseUrl $BASE_URL --ssePath $SSE_PATH --messagePath $MESSAGE_PATH' >> /app/StartupScript.sh && \
    chmod +x /app/StartupScript.sh && \
    chown nodeuser:nodeuser /app/StartupScript.sh

# Set environment variables with defaults that can be overridden
ENV PORT=8000
ENV BASE_URL=http://localhost:8000
ENV SSE_PATH=/sse
ENV MESSAGE_PATH=/message
ENV DATA_FOLDER=./data
ENV SERVER_TYPE=mcp-server-git
ENV HOME=/home/nodeuser
ENV NPM_CONFIG_CACHE=/home/nodeuser/.npm

# Switch to non-root user after all setup operations
USER 10014

# Pre-download the npm packages to avoid permission issues
RUN npm install -g npm@latest && \
    npm cache verify

# Expose the default port
EXPOSE 8000

# Start the MCP server using the script
CMD ["sh", "/app/StartupScript.sh"]
