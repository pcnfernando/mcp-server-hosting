FROM node:20-alpine

# Set working directory
WORKDIR /app

# Create non-root user for better security and set up npm cache directory
RUN addgroup -g 10014 nodeuser && \
    adduser -u 10014 -G nodeuser -s /bin/sh -D nodeuser && \
    mkdir -p /app/data && \
    mkdir -p /home/nodeuser/.npm && \
    chown -R nodeuser:nodeuser /app && \
    chown -R nodeuser:nodeuser /home/nodeuser

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
# COPY --chown=10014:10014 StartupScript.sh /app/
# RUN chmod +x /app/StartupScript.sh

# Fix permissions on the script
RUN chmod +x ./StartupScript.sh && \
    chown nodeuser:nodeuser ./StartupScript.sh

# Expose the default port
EXPOSE 8000
COPY ./StartupScript.sh /usr/local/bin/

# Start the MCP server using the script
CMD ["sh", "/usr/local/bin/StartupScript.sh"]
