# Dynamic MCP Server Docker Setup

This repository contains a Docker setup for running an MCP (Model Context Protocol) server with configurable parameters.

## Files Included

- `Dockerfile`: A dynamic Docker image definition for the MCP server
- `start-mcp.sh`: A startup script that configures the MCP server at runtime
- `docker-compose.yml`: An easy way to run the MCP server with customizable parameters

## Quick Start

1. Clone this repository:
   ```bash
   git clone <your-repo-url>
   cd <your-repo-directory>
   ```

2. Create the `start-mcp.sh` script and make it executable:
   ```bash
   chmod +x start-mcp.sh
   ```

3. Build and run the Docker container:
   ```bash
   docker-compose up -d
   ```

4. Access your MCP server at http://localhost:8000 (or the configured BASE_URL)

## Configuration

You can customize the MCP server by setting environment variables in your `.env` file or in the `docker-compose.yml` file:

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | The port the MCP server listens on | 8000 |
| BASE_URL | The base URL for the MCP server | http://localhost:8000 |
| SSE_PATH | The path for Server-Sent Events | /sse |
| MESSAGE_PATH | The path for sending messages | /message |
| DATA_FOLDER | The folder where MCP data is stored | ./data |
| SERVER_TYPE | The MCP server implementation to use | @modelcontextprotocol/server-filesystem |

### Example .env file:

```
PORT=9000
BASE_URL=http://mcp.example.com
SSE_PATH=/events
MESSAGE_PATH=/api/message
DATA_FOLDER=./custom-data
SERVER_TYPE=@modelcontextprotocol/server-custom
```

## Building the Docker Image Manually

You can also build and run the Docker image manually:

```bash
# Build the image
docker build -t mcp-server .

# Run the container with custom environment variables
docker run -d \
  -p 8000:8000 \
  -e PORT=8000 \
  -e BASE_URL=http://localhost:8000 \
  -e SSE_PATH=/sse \
  -e MESSAGE_PATH=/message \
  -e DATA_FOLDER=./data \
  -e SERVER_TYPE=@modelcontextprotocol/server-filesystem \
  -v $(pwd)/data:/app/data \
  --name mcp-server \
  mcp-server
```

## Custom Server Types

You can use different MCP server implementations by changing the `SERVER_TYPE` environment variable:

- `@modelcontextprotocol/server-filesystem`: File system based server (default)
- Other MCP server implementations as needed

## Troubleshooting

If you encounter issues:

1. Check the logs: `docker-compose logs` or `docker logs mcp-server`
2. Verify your environment variables are set correctly
3. Ensure the data directory has proper permissions
