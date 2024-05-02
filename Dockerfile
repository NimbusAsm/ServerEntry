FROM debian:12
WORKDIR /app/server-entry
COPY ServerEntry.Build/server-entry-linux-x64-single .
COPY ServerEntry.Build/frontend ./wwwroot
EXPOSE 5111
ENV ASPNETCORE_HTTP_PORTS 5111
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1
CMD ["/bin/bash", "-c", "./ServerEntry.ApiServer"]
