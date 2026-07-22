# Troubleshooting

## Docker is installed but unavailable

Start Docker Desktop, confirm Linux containers are selected, then run:

```powershell
docker info
docker compose version
```

## Open WebUI cannot see Ollama

Confirm the host API first:

```powershell
Invoke-RestMethod http://127.0.0.1:11434/api/tags
```

Then test from the container:

```powershell
docker exec llm-bootstrap-open-webui curl -fsS http://host.docker.internal:11434/api/tags
```

## SearXNG returns HTTP 403

JSON output must be enabled. This repository's generated `config/searxng/settings.yml` includes both `html` and `json` formats. Regenerate it with:

```powershell
.\scripts\configure-environment.ps1
docker compose up -d --force-recreate searxng
```

## Ports are already used

Edit `.env` and change `OPEN_WEBUI_PORT` or `SEARXNG_PORT`, then restart.

## Reset containers but retain configuration

```powershell
.\stop.ps1
docker compose pull
.\start.ps1
```

## Destructive reset

This deletes Open WebUI data and SearXNG cache:

```powershell
docker compose down -v
```
