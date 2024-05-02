param(
    [string] $Tag
)

## Info
echo "## You are going to build with tag: $Tag"

## Clear Build Cache
echo "## Clearing Build Cache"
rm -rf ServerEntry.Build

## Build ApiServer
echo "## Building ApiServer ..."
Set-Location ServerEntry.ApiServer
dotnet publish -p:PublishProfile=Properties/PublishProfiles/linux-x64-single.pubxml
Set-Location ..

### Change mode
Set-Location ServerEntry.Build/server-entry-linux-x64-single
chmod +x ServerEntry.ApiServer
Set-Location ../..

## Build Frontend
echo "## Building Frontend ..."
Set-Location ServerEntry.Dashboard/server_entry_dashboard
flutter build web --release --web-renderer canvaskit --tree-shake-icons --no-web-resources-cdn
Copy-Item -r build/web ../../ServerEntry.Build/frontend/
Set-Location ../..

## Build Docker
sudo docker build . -t nimbusasm/server-entry:$Tag
