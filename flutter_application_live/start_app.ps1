# Start Flutter App
$projectPath = "C:\Users\Andriy\Documents\Leblings\flutter_application_live"

Write-Host "Starting Flutter app..."
Write-Host "Make sure Ollama is running on port 11434"
Write-Host ""

cd $projectPath
flutter run -d web
