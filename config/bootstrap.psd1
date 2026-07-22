@{
    ProjectName = 'llm-bootstrap-windows'
    Ollama = @{
        WingetId = 'Ollama.Ollama'
        ApiUrl = 'http://127.0.0.1:11434'
        DefaultModel = 'qwen3:8b'
        AutoPullModel = $false
    }
    DockerDesktop = @{
        WingetId = 'Docker.DockerDesktop'
        StartupTimeoutSeconds = 180
    }
    OpenWebUI = @{ Port = 3000 }
    SearXNG = @{ Port = 8080 }
}
