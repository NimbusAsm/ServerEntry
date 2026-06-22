param(
    [string] $Tag
)

## Info
Write-Output "## You are going to build with tag: $Tag"

## Clear Build Cache
Write-Output "## Clearing Build Cache"
Remove-Item -rf ServerEntry.Build

## Build ApiServer
Write-Output "## Building ApiServer ..."
Set-Location ServerEntry.ApiServer
dotnet publish -p:PublishProfile=Properties/PublishProfiles/linux-x64-single.pubxml
Set-Location ..

### Change mode
Set-Location ServerEntry.Build/server-entry-linux-x64-single
chmod +x ServerEntry.ApiServer
Set-Location ../..

## Build Frontend
Write-Output "## Building Frontend ..."
Set-Location ServerEntry.Dashboard/server_entry_dashboard
flutter build web --release --web-renderer canvaskit --tree-shake-icons --no-web-resources-cdn
Copy-Item -r build/web ../../ServerEntry.Build/frontend/
Set-Location ../..

## Build Docker
sudo docker build . -t nimbusasm/server-entry:$Tag
