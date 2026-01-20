# Start Ollama Server
$OllamaExe = "C:\Users\Andriy\AppData\Local\Programs\Ollama\ollama.exe"
$port = 11434

Write-Host "Starting Ollama server..."
if (Test-Path $OllamaExe) {
    & $OllamaExe serve
} else {
    Write-Host "ERROR: Ollama not found at $OllamaExe"
    Write-Host "Please install Ollama from https://ollama.ai"
}
