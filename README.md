# llm-bootstrap-windows

A Windows-specific bootstrap repository for a local LLM and Web-search workspace:

- Ollama runs natively on Windows.
- Open WebUI runs in Docker Desktop.
- SearXNG runs in Docker Desktop.
- PowerShell is the single operator interface.

Image generation is deliberately out of scope.

## Quick start

Open PowerShell in this repository:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\bootstrap.ps1
```

The bootstrap is restart-safe. When Docker Desktop asks for a restart or first-run acceptance, complete it and rerun the same command.

To also pull the configured default model:

```powershell
.\bootstrap.ps1 -PullDefaultModel
```

Open WebUI: `http://localhost:3000`

SearXNG: `http://localhost:8080`

## Daily operation

```powershell
.\start.ps1
.\status.ps1
.\test.ps1
.\stop.ps1
```

Pull a model:

```powershell
.\scripts\pull-model.ps1 -Model qwen3:8b
```

## Repository layout

```text
llm-bootstrap-windows/
├── README.md
├── bootstrap.ps1
├── start.ps1
├── stop.ps1
├── status.ps1
├── test.ps1
├── compose.yaml
├── .env.example
├── config/
│   ├── bootstrap.psd1
│   └── searxng/
│       ├── settings.yml.template
│       └── settings.yml          # generated, ignored only by secrets policy if desired
├── scripts/
│   ├── common.ps1
│   ├── check-system.ps1
│   ├── install-ollama.ps1
│   ├── install-docker-desktop.ps1
│   ├── configure-environment.ps1
│   ├── start-services.ps1
│   ├── stop-services.ps1
│   ├── test-ollama.ps1
│   ├── test-open-webui.ps1
│   ├── test-searxng.ps1
│   └── pull-model.ps1
├── prompts/
├── data/
└── docs/
```

## Design notes

- `.env` is generated from `.env.example`, with random local secrets.
- Open WebUI reaches native Ollama through `host.docker.internal:11434`.
- Open WebUI reaches SearXNG by Docker service name at `http://searxng:8080`.
- Both web interfaces bind to `127.0.0.1` only; this is a local workstation bootstrap, not an Internet-facing deployment.
- Persistent Docker volumes preserve Open WebUI state across container recreation.
- Container image tags are configurable in `.env`. Pin versions there when reproducibility matters more than automatic updates.

## Validation status

The files were generated and statically checked in a Linux container. They have not been executed on the target Windows machine. The intended first validation loop is: run `bootstrap.ps1`, report any failing command and output, then adjust the repository against the actual machine.
