FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.0-buster AS build
WORKDIR /src
COPY ./genericinternet.company.csproj .
RUN dotnet restore "genericinternet.company.csproj"

# Setup NodeJs
RUN apt-get update && \
    apt-get install -y wget && \
    apt-get install -y gnupg2 && \
    wget -qO- https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y build-essential nodejs

# Copy everything else and build
COPY . .
WORKDIR "/src/"
RUN dotnet build "genericinternet.company.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "genericinternet.company.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "genericinternet.company.dll"]
