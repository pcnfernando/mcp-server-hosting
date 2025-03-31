# MCP Server Docker Image for Choreo

This Dockerfile creates a lightweight, secure, and production-ready Node.js-based server container that runs the Model Context Protocol (MCP) server using `supergateway`. The container is designed to be deployed as a service on Choreo.

## Running the Container Locally
You can run the container using the following command:

```sh
docker run -p 8000:8000 \
  -e PORT=8000 \
  -e BASE_URL=http://localhost:8000 \
  -e SSE_PATH=/sse \
  -e MESSAGE_PATH=/message \
  -e DATA_FOLDER=/app/data \
  -e SERVER_TYPE=mcp-server-git \
  mcp-server
```

## Environment Variables
The container supports the following environment variables:

| Variable      | Default Value              | Description |
|--------------|--------------------------|-------------|
| `PORT`       | `8000`                   | The port on which the server listens. |
| `BASE_URL`   | `http://localhost:8000`  | The base URL for the server. |
| `SSE_PATH`   | `/sse`                    | Path for Server-Sent Events. |
| `MESSAGE_PATH` | `/message`              | Path for messaging. |
| `DATA_FOLDER` | `./data`                 | Directory for storing server data. |
| `SERVER_TYPE` | `@modelcontextprotocol/server-github`         | Defines the type of MCP server to run. |


## Exposed Ports
- **8000**: The main port where the MCP server runs.

## License
This project is licensed under [MIT License](LICENSE).

