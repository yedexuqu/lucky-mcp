FROM node:20-slim

# lucky-mcp-server: stdio MCP server for Lucky (openToken auth)
# supergateway: wraps a stdio MCP server as streamable HTTP
RUN npm install -g @bearst/lucky-mcp-server supergateway \
    && npm cache clean --force

ENV NODE_ENV=production

EXPOSE 8080

# LUCKY_BASE_URL / LUCKY_OPEN_TOKEN are inherited by the stdio child process
CMD ["supergateway", \
     "--stdio", "lucky-mcp-server", \
     "--outputTransport", "streamableHttp", \
     "--port", "8080", \
     "--streamableHttpPath", "/mcp"]
