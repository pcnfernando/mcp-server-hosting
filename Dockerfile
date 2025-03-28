FROM node:20-alpine

# Set working directory
WORKDIR /app

# Create non-root user for better security
# Alpine uses adduser instead of useradd
RUN addgroup -g 10014 nodeuser && \
    adduser -u 10014 -G nodeuser -s /bin/sh -D nodeuser && \
    mkdir -p /app/data && \
    chown -R nodeuser:nodeuser /app

# Switch to non-root user
USER 10014

# Set environment variables with defaults that can be overridden
ENV PORT=8000
ENV BASE_URL=http://localhost:8000
ENV SSE_PATH=/sse
ENV MESSAGE_PATH=/message
ENV DATA_FOLDER=./data
ENV SERVER_TYPE=@modelcontextprotocol/server-filesystem

# Copy startup script
COPY --chown=10014:10014 StartupScript.sh /app/
RUN chmod +x /app/StartupScript.sh

# Expose the default port
EXPOSE 8000

# Start the MCP server using the script
CMD ["/app/StartupScript.sh"]
