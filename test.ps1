if (Test-Path "build") {Remove-Item -Path "build" -Recurse -Force}
New-Item -ItemType Directory -Path "build"

if (-not (Test-Path "godot")) {
    New-Item -ItemType Directory -Path "godot"
    $client = new-object System.Net.WebClient
    $client.DownloadFile("https://github.com/GodotSteam/GodotSteam/releases/download/v4.7-mp/win64-g422-s159-gs47-mp.zip",".\godot\godot.zip")
    cd godot
    tar -xf godot.zip
    del godot.zip
    cd ..
}

.\godot\godotsteam.multiplayer.422.editor.windows.64.exe --path . --export-release "Windows Desktop" .\build\godotsteamtest.exe
Copy-Item -Path ".\godot\steam_api64.dll" -Destination ".\build\"
clear