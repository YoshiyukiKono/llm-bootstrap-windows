# Architecture

```text
Windows browser
    |
    v
Open WebUI (Docker, localhost:3000)
    |-- Ollama API -> host.docker.internal:11434 (Windows native)
    `-- Web search -> http://searxng:8080 (Docker network)

SearXNG (Docker, localhost:8080)
    `-- external search providers on the Web
```

PowerShell is the operator interface. Linux implementation details remain inside Docker Desktop's Linux-container backend.

## Boundaries

Included: Ollama, Docker Desktop prerequisite handling, Open WebUI, SearXNG, lifecycle scripts, smoke tests.

Excluded: ComfyUI/image generation, vLLM, Kubernetes, vector databases, bespoke agents, and production-grade remote exposure.
