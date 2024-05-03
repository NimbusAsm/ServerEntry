
<p align="center">
    <img width="128" src=".github/assets/icon@1024.png" alt="Server Entry Logo">
</p>

<h1 align="center">Server Entry</h1>

<p align="center">A set of utils to help you with managing your server</p>

<p align="center">
    <img src="https://profile-counter.glitch.me/NimbusAsm-ServerEntry/count.svg"></img>
</p>

# Status

<a href="./LICENSE"><img src="https://img.shields.io/github/license/NimbusAsm/ServerEntry" alt="License"></a>
<a href="#"><img src="https://img.shields.io/github/repo-size/NimbusAsm/ServerEntry?color=%234682B4" alt="GitHub Repo Size"></a>
<a href="#"><img src="https://img.shields.io/github/languages/code-size/NimbusAsm/ServerEntry" alt="Code Size"></a>
<a href="https://github.com/NimbusAsm/ServerEntry/commits/"><img src="https://img.shields.io/github/commit-activity/m/NimbusAsm/ServerEntry" alt="Commit Activity"></a>

![Docker Pulls](https://img.shields.io/docker/pulls/nimbusasm/server-entry)
![Docker Image Size](https://img.shields.io/docker/image-size/nimbusasm/server-entry)
![Docker Image Version](https://img.shields.io/docker/v/nimbusasm/server-entry)

<a href="https://github.com/NimbusAsm/ServerEntry/network/members"><img src="https://img.shields.io/github/forks/NimbusAsm/ServerEntry?style=social" alt="Forks"></a>
<a href="https://github.com/NimbusAsm/ServerEntry/stargazers"><img src="https://img.shields.io/github/stars/NimbusAsm/ServerEntry?style=social" alt="Stars"></a>
<a href="https://github.com/NimbusAsm/ServerEntry/watchers"><img src="https://img.shields.io/github/watchers/NimbusAsm/ServerEntry?style=social" alt="Watches"></a>
<a href="https://github.com/NimbusAsm/ServerEntry/discussions"><img src="https://img.shields.io/github/discussions/NimbusAsm/ServerEntry?style=social" alt="Discussions"></a>

# Features

- [x] Display CPU/RAM usage
- [ ] Manage your nginx/pingora configuration
- [ ] Manage your websites
- [ ] Manage your docker containers

# Usage

## Docker

```shell
## Pull docker image
sudo docker pull nimbusasm/server-entry:latest

## Run docker container
sudo docker run -d --name server-entry \
    -p 5111:5111 \
    nimbusasm/server-entry:latest
```

## Manually

// ToDo

# Development

## Requirements

- dotnet sdk 8.0
- flutter sdk
- [cheese](https://github.com/Crequency/Cheese) (recommend to use latest)

    ```shell
    # If you have no cheese tool, you can install it by:
    dotnet tool install cheese --global
    # To upgrade cheese
    dotnet tool update cheese --global
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

Visit [localhost:5111/Api](http://localhost:5111/Api) to view api docs

> In fact, `/Api` route will redirect to `/swagger/index.html`

### Dashboard

```shell
cd ServerEntry.Dashboard/server_entry_dashboard

flutter run # If you need to run with headless browser, append '-d web-server'
```

Visit the url printed to console by flutter sdk to open frontend website

# Publish

```shell
# This script build both backend and frontend and make a docker image
pwsh -c ./build.ps1 -Tag <tag> # example: <tag> -> 0.0.2.1
```

> In the docker image, root folder is `/app/server-entry` ,
> front-end site will located in `$root/wwwroot` ,
> api server will listen `/` route and return files in `wwwroot`, the api server will located in root folder

# Contributors

[![Contributors](https://contrib.rocks/image?repo=NimbusAsm/ServerEntry)](https://github.com/NimbusAsm/ServerEntry/graphs/contributors)

# Star History

[![Star History Chart](https://starchart.cc/NimbusAsm/ServerEntry.svg?variant=adaptive)](https://starchart.cc/NimbusAsm/ServerEntry)
