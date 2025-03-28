#!/bin/bash
set -e

echo "Starting MCP Server with the following configuration:"
echo "Port: $PORT"
echo "Base URL: $BASE_URL"
echo "SSE Path: $SSE_PATH"
echo "Message Path: $MESSAGE_PATH"
echo "Data Folder: $DATA_FOLDER"
echo "Server Type: $SERVER_TYPE"

# Make sure the data directory exists
mkdir -p $DATA_FOLDER

# Start the MCP server with the configured parameters
npx -y supergateway \
    --stdio "npx -y $SERVER_TYPE $DATA_FOLDER" \
    --port $PORT --baseUrl $BASE_URL \
    --ssePath $SSE_PATH --messagePath $MESSAGE_PATH
