# ForgeAI on a Linux VM

The server is one JavaScript file using Node.js built-ins. It needs no npm packages. Node.js 24 LTS is recommended; use a supported Node version that provides `fetch`, `AbortSignal.timeout`, and `--env-file`. Obtain Node from [the official downloads](https://nodejs.org/en/download).

The Linux VM handles HTTPS requests and quota records; OpenAI runs the model. The VM must remain online for public AI requests to work.

## 1. Put the files on the VM

Create a directory owned by the account that will run ForgeAI. Copy `server.mjs` and `server.env.example` there. Keep it outside the web server's static document directory.

```sh
mkdir -p "$HOME/forgeai"
cd "$HOME/forgeai"
cp server.env.example .env
chmod 600 .env
nano .env
```

Enter the OpenAI project key in `.env`. Never add that file to GitHub or send it to the client. A new project key is preferable to a key previously shared in messages. Use an account with GPT-5.5 API access and billing enabled.

The important settings are:

```dotenv
OPENAI_API_KEY=PASTE_YOUR_SERVER_KEY_HERE
HOST=127.0.0.1
PORT=3000
FORGE_STATE_FILE=./forgeai-quota.json
FORGE_DAILY_REQUEST_LIMIT=100
FORGE_TRUST_LOCAL_PROXY=1
FORGE_TRUST_CLOUDFLARE_TUNNEL=0
```

`100` is an operator-wide maximum accepted requests per UTC day, not a monetary budget. Each individual allowance is 10 accepted requests in a 48-hour window starting with its first accepted request. Use a lower daily ceiling during testing if desired.

## 2. Start and check the service

```sh
node --env-file=.env server.mjs
```

In a second terminal:

```sh
curl --fail http://127.0.0.1:3000/health
```

A healthy response includes `"ok":true`. This checks that the service runs; it does not spend a prompt or prove that the OpenAI key has model access.

Keep exactly one service process using each quota file. Preserve `forgeai-quota.json` across restarts so allowances remain intact. A malformed state file stops startup rather than silently resetting everybody's usage. Back it up with the rest of the service data.

## 3. Connect the existing HTTPS address

Ask the VM administrator to forward the chosen HTTPS address to `http://127.0.0.1:3000`. Keep port 3000 bound to loopback. The proxy must overwrite `X-Real-IP` with the real visitor IP, never accept a caller's copy of that header.

For an existing Nginx HTTPS virtual host, this example publishes ForgeAI at `/forgeai/`. Put the location block inside that host's existing `server { ... }` block:

```nginx
location /forgeai/ {
    proxy_pass http://127.0.0.1:3000/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_http_version 1.1;
    proxy_read_timeout 150s;
    proxy_send_timeout 150s;
    client_max_body_size 256k;
    proxy_buffering off;
}
```

Validate and reload Nginx using the administrator's existing deployment process. If Nginx itself sits behind another proxy, configure the real-IP trust chain there; otherwise every visitor could appear to share one address. Do not expose `.env`, quota state, or the rest of the server directory through static hosting.

The public health URL would be `https://YOUR-HOST/forgeai/health`. That is only an example; use the actual address your administrator provides. A dedicated hostname can instead forward `/` to Node, with a base address such as `https://YOUR-API-HOST`.

## 4. Connect the loader

Update the public `forgeai/config.json`:

```json
{
  "apiBase": "https://YOUR-HOST/forgeai",
  "status": "online"
}
```

Use the actual HTTPS address without a trailing slash. Do not put any key or server token in this file. Commit just that configuration change. Users keep the same one-line loader.

Before general sharing, run one small live build on an empty area, verify the GUI in Roblox, test saved chats and a saved blueprint after re-execution, and check the server's recorded allowance. A successful health check alone is not a full acceptance test.

## 5. Optional: start automatically with systemd

`forgeai.service.example` shows a service for `/opt/forgeai` and a dedicated `forgeai` Linux account. Have the VM administrator adapt the user, working directory, and the absolute Node path returned by `command -v node`. The account needs write access to the quota directory and read access to its private `.env` file.

## Optional home server or outbound tunnel

If this service later moves to a home network, [Cloudflare Tunnel](https://developers.cloudflare.com/tunnel/) can publish a local HTTP service using outbound connections, without router port forwarding. For `cloudflared` on the same machine forwarding directly to Node, set:

```dotenv
FORGE_TRUST_LOCAL_PROXY=0
FORGE_TRUST_CLOUDFLARE_TUNNEL=1
```

This mode requires a valid Cloudflare visitor-IP header from a loopback peer on API requests. Use it only for the local trusted tunnel. Keep `HOST=127.0.0.1`. Configure a [stable public hostname](https://developers.cloudflare.com/tunnel/get-started/) for a release.

For a temporary test, after installing `cloudflared` and starting Node:

```sh
cloudflared tunnel --url http://127.0.0.1:3000
```

The printed HTTPS URL is reachable externally while that process runs. [Quick Tunnels](https://developers.cloudflare.com/tunnel/get-started/quick-tunnels/) change hostname on restart and are intended for development, not a permanent public service.

## Request limits and identity

The service persists per-ID and per-network counters, checks an operator-wide daily ceiling, and allows two concurrent upstream requests. Accepted requests have persisted identifiers to prevent accidental double charging and automatic duplicate submission. An upstream timeout still counts as an accepted request; it is not replayed automatically.

Roblox IDs supplied by an executor are not authenticated identities. The shared network guard limits simple ID switching but cannot stop someone changing both their ID and network. True per-account enforcement requires a verified sign-in system. Users behind the same public IP share the network guard's allowance.
