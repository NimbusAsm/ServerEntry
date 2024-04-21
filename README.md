# About

`ServerEntry` is a set of utils to help you with managing your server.

# Development

```shell
git clone git@github.com:ServerEntry/ServerEntry.git

cd ServerEntry

# Use cheese to initialize reference
cheese ref --init

# If you have no cheese tool, you can install it by:
dotnet tool install cheese --global
```

## Requirements

- dotnet sdk 8.0
- cheese (recommend to use latest)

## Components

### Api Server

```shell
cd ServerEntry.ApiServer

dotnet watch
```

### Dashboard

```shell
cd ServerEntry.Dashboard

dotnet watch
```

Then, visit [localhost:5111/swagger](http://localhost:5111/swagger/index.html) to view api docs

