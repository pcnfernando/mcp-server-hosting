FROM node:20-slim

# Set working directory
WORKDIR /app

# Install necessary tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create directory for MCP data
RUN mkdir -p /app/data

# Set environment variables with defaults that can be overridden
ENV PORT=8000
ENV BASE_URL=http://localhost:8000
ENV SSE_PATH=/sse
ENV MESSAGE_PATH=/message
ENV DATA_FOLDER=./data
ENV SERVER_TYPE=@modelcontextprotocol/server-filesystem

# Copy startup script
COPY start-mcp.sh /app/
RUN chmod +x /app/start-mcp.sh

# Install global npm packages
RUN npm install -g npm@latest

# Expose the default port
EXPOSE 8000

# Start the MCP server using the script
CMD ["/app/start-mcp.sh"]
