# Get the path of the folder where this script is located (vscode/)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$extensionsFile = Join-Path -Path $scriptPath -ChildPath "extensions.txt"

Write-Host "Verifying VS Code extensions..." -ForegroundColor Cyan

# 1. Read the list of desired extensions
$myExtensions = Get-Content -Path $extensionsFile -ErrorAction SilentlyContinue

if ($null -eq $myExtensions) {
    Write-Host "The extensions.txt file was not found." -ForegroundColor Red
    return
}

# 2. Get currently installed extensions (to save network and time)
Write-Host "Querying currently installed extensions..."
$installed = code --list-extensions

foreach ($ext in $myExtensions) {
    # Ignore empty lines
    if ([string]::IsNullOrWhiteSpace($ext)) { continue }

    if ($installed -match $ext) {
        Write-Host "✅ Already installed: $ext" -ForegroundColor DarkGray
    } else {
        Write-Host "⏳ Installing: $ext..." -ForegroundColor Yellow
        
        # 3. Force the process to wait until one finishes before continuing with the next
        $process = Start-Process -FilePath "code" -ArgumentList "--install-extension $ext" -Wait -NoNewWindow -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "✨ Success: $ext" -ForegroundColor Green
        } else {
            Write-Host "❌ Error installing $ext. Check your connection." -ForegroundColor Red
        }
    }
}

Write-Host "Done!" -ForegroundColor Cyan