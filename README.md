# About

`ServerEntry` is a set of utils to help you with managing your server.

# Development

## Requirements

- dotnet sdk 8.0
- flutter sdk
- [cheese](https://github.com/Crequency/Cheese) (recommend to use latest)

    ```shell
    # If you have no cheese tool, you can install it by:
    dotnet tool install cheese --global
    ```

## Fetch source codes

```shell
git clone git@github.com:NimbusAsm/ServerEntry.git

cd ServerEntry

# Use cheese to initialize reference
cheese ref --init
```

## Components

### Api Server

```shell
cd ServerEntry.ApiServer

dotnet watch
```

Visit [localhost:5111/swagger](http://localhost:5111/swagger/index.html) to view api docs

### Dashboard

```shell
cd ServerEntry.Dashboard/server_entry_dashboard

flutter run # If you need to run with headless browser, append '-d web-server'
```

Visit the url printed to console by flutter sdk to open frontend website

# Publish

```shell
# This script build both backend and frontend and make a docker image
pwsh -c ./build.ps1 -Tag <tag> # example: <tag> -> 0.0.2
```
