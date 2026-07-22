# Manual steps

Some Windows operations cannot be made safely unattended:

1. Docker Desktop may require enabling WSL 2 and restarting Windows.
2. Docker Desktop must be started once and its subscription terms accepted.
3. Ollama may need to be started from the Windows Start menu after installation.
4. On first Open WebUI access, create the local administrator account.
5. In a chat, Web Search may need to be enabled with the integrations toggle.

Rerun `bootstrap.ps1` after any restart or manual setup. The scripts are designed to be idempotent.
