# Phase 2: Infrastructure Completion & Docker Container Management

> **Status:** Planning  
> **Created:** 2026-06-22  
> **Target:** v0.0.3.x  
> **Depends On:** Phase 1 (v0.0.2.x — basic CPU/RAM monitoring)

---

## Overview

Phase 1 delivered a working hardware monitoring dashboard (CPU, RAM) with a clean architecture: C# backend fetching from `/proc` pseudo-filesystem, Flutter Web frontend with real-time charts, all packaged as a single Docker image.

Phase 2 advances the project in three parallel tracks:

| Track | Goal | Value |
|-------|------|-------|
| **A. Disk Monitoring** | Complete the hardware status triad — display disk info on the dashboard | Low effort, high visible impact |
| **B. Persistence Layer** | Implement the DB abstraction → MongoDB adapter, migrate in-memory state to durable storage | Foundation for all "management" features |
| **C. Docker Container Management** | List/logs/inspect local Docker containers via API + dashboard UI | Core planned feature, high user value |

Additionally, **authentication** is introduced as a cross-cutting concern before management endpoints ship.

---

## Track A — Disk Monitoring (Complete Hardware Status)

### Context

`DiskInfoFetcher` already exists in [ServerEntry.Data.Hardware/Memories/DiskInfoFetcher.cs](ServerEntry.Data/ServerEntry.Data.Hardware/Memories/DiskInfoFetcher.cs) and parses `/proc/partitions`. `DiskInfo` model exists in [Shared/Hardware/Memory/Memories/DiskInfo.cs](ServerEntry.Shared/Hardware/Memory/Memories/DiskInfo.cs). They are just not wired to the API or Dashboard.

### Tasks

#### A1. Add Disk Usage Monitor (`ServerEntry.Data.Hardware`)
- Create `DiskUsageMonitor : MonitorBase` that periodically reads `/proc/diskstats` (or calls `statfs`) to compute per-disk read/write speeds and usage percentage
- Register in `ServicesManager`
- File: `ServerEntry.Data/ServerEntry.Data.Hardware/Services/HardwareMonitors/DiskUsageMonitor.cs`

#### A2. Expose Disk Info in API (`ServerEntry.ApiServer`)
- Add `[HttpGet("Memory/Disks")]` endpoint to `HardwareStatusController` (or add a dedicated action with `range=disks`)
- The existing `GetMemoryInfo(range)` with `range=disks` already calls `DiskInfoFetcher.Instance.Fetch(range)` — verify it returns correctly and add any missing fields

#### A3. Add Disk Widget to Dashboard (`ServerEntry.Dashboard`)
- New file: `lib/widgets/home/disk_info.dart` — `DiskInfoWidget`
- Display each disk as a card with: name, capacity (total/used progress bar), read/write speeds (if monitor implemented), partitions table
- Wire into `home_page.dart` widget list
- Polling interval: 5 seconds (disk stats change slowly)

### Deliverables — Track A
- [ ] Disk usage displayed on the dashboard
- [ ] Disk read/write speed monitor running
- [ ] API returns complete disk info with usage

---

## Track B — Persistence Layer

### Context

Two class libraries exist as empty shells:
- `ServerEntry.Data.DbAdapter` — abstract interfaces
- `ServerEntry.Data.MongoDbAdapter` — MongoDB implementation (references DbAdapter)

Neither has any code beyond the `.csproj`. The current system holds all state in memory (e.g., `CpuUsageMonitor.cpuUsageHistory` is a `SortedDictionary`, `ServicesManager.monitorServices` is a `List`).

### Architecture Decision

```
ServerEntry.Data.DbAdapter        ← Interfaces: IRepository<T>, IDbConnection, IUnitOfWork
ServerEntry.Data.MongoDbAdapter   ← Implements interfaces for MongoDB
ServerEntry.ApiServer             ← DI registration, reads connection string from config
ServerEntry.Data.Hardware         ← Uses IRepository to persist historical data
```

### Tasks

#### B1. Define Core Interfaces (`ServerEntry.Data.DbAdapter`)
- `IDbConnection` — `Task ConnectAsync()`, `Task DisconnectAsync()`, `bool IsConnected`
- `IRepository<T>` — `Task<T?> GetById(string id)`, `Task Insert(T entity)`, `Task Update(T entity)`, `Task Delete(string id)`, `Task<IEnumerable<T>> Query(Expression<Func<T, bool>> predicate)`
- `IDatabaseSettings` — record with `ConnectionString`, `DatabaseName`

#### B2. Implement MongoDB Adapter (`ServerEntry.Data.MongoDbAdapter`)
- `MongoDbConnection : IDbConnection` wrapping `MongoClient`
- `MongoRepository<T> : IRepository<T>` wrapping `IMongoCollection<T>`
- `ServiceCollectionExtensions` — `AddMongoDb(this IServiceCollection, IConfiguration)` extension method

#### B3. Define Data Models for Persistence
- `HardwareSnapshot` — timestamp + CPU/RAM/Disk snapshot (JSON-serializable)
- `MonitorRecord` — for time-series storage of monitor values

#### B4. Wire Persistence into Hardware Monitoring
- `CpuUsageMonitor` optionally writes to `IRepository<MonitorRecord>` when available (decorator pattern or optional DI)
- `HardwareStatusProvider` optionally reads historical snapshots
- Keep in-memory fallback when no DB is configured (preserve the "just run it" experience)

#### B5. Configuration & Docker
- Add `MongoDb__ConnectionString` and `MongoDb__DatabaseName` to `appsettings.json`
- Add MongoDB service to `docker-compose.yml` (new file) for local dev
- Docker image remains self-contained (MongoDB is optional, off by default)

### Deliverables — Track B
- [ ] DB abstraction interfaces defined
- [ ] MongoDB adapter implemented and registered via DI
- [ ] Historical hardware data persisted to MongoDB (when configured)
- [ ] Graceful fallback when no DB is available

---

## Track C — Docker Container Management

### Context

This is the highest-value planned feature from the README. The server running this tool likely hosts Docker containers; users want to see and manage them from the dashboard.

### Approach

The backend will interact with the Docker Unix socket (`/var/run/docker.sock`) via `System.Net.Http` to the Docker Engine API — no external .NET Docker library needed for Phase 2 (avoids dependency bloat; the Docker HTTP API is stable and well-documented).

### Tasks

#### C1. Docker API Client (`ServerEntry.Data.Docker` — new project)
- New class library: `ServerEntry.Data.Docker`
- `DockerClient` class:
  - `HttpClient` connected to `unix:///var/run/docker.sock`
  - `Task<List<ContainerInfo>> ListContainers(bool all = false)` → `GET /containers/json`
  - `Task<ContainerDetail> InspectContainer(string id)` → `GET /containers/{id}/json`
  - `Task<Stream> GetContainerLogs(string id, int tail = 100)` → `GET /containers/{id}/logs`
  - `Task StartContainer(string id)` → `POST /containers/{id}/start`
  - `Task StopContainer(string id)` → `POST /containers/{id}/stop`
  - `Task RestartContainer(string id)` → `POST /containers/{id}/restart`
- Shared models in `ServerEntry.Shared.Docker`:
  - `ContainerInfo` — id, name, image, status, state, ports, created
  - `ContainerDetail` — full inspect response (selected fields)

#### C2. Docker API Controller (`ServerEntry.ApiServer`)
- `DockerController : ControllerBase` at `Api/V1/Docker`
- Endpoints:
  - `GET /` — list containers (query: `?all=true`)
  - `GET /{id}` — inspect container
  - `GET /{id}/logs` — get container logs (query: `?tail=100&stdout=true&stderr=true`)
  - `POST /{id}/start` — start container
  - `POST /{id}/stop` — stop container
  - `POST /{id}/restart` — restart container
- All endpoints check authentication token (see Cross-Cutting section)

#### C3. Docker Dashboard Page (`ServerEntry.Dashboard`)
- New page: `lib/pages/docker_page.dart` — `DockerPage`
- New widgets:
  - `lib/widgets/docker/container_list.dart` — scrollable list of container cards
  - `lib/widgets/docker/container_card.dart` — single container: name, image, status badge (green=run, red=stop, yellow=pause), quick action buttons (start/stop/restart)
  - `lib/widgets/docker/container_logs.dart` — log viewer (terminal-style, monospace, scrollable)
- Route: `/docker` in `getPages()`
- Navigation entry in sidebar/bottom nav
- Polling interval: 10 seconds for container list

#### C4. Docker Socket Access in Docker
- The container must mount `/var/run/docker.sock` to interact with the host's Docker daemon
- Update `Dockerfile` — no change needed (socket is mounted at runtime)
- Update README with `docker run -v /var/run/docker.sock:/var/run/docker.sock` instructions
- Graceful handling when socket is not available: API returns 503 with `"Docker socket not available"`

### Deliverables — Track C
- [ ] Docker Engine API client implemented
- [ ] REST API for container list/inspect/logs/start/stop/restart
- [ ] Dashboard page with container list and basic actions
- [ ] Container log viewer
- [ ] Graceful degradation when Docker socket is unavailable

---

## Cross-Cutting: Authentication

### Context

The API has a `token` query parameter in every controller action that is **never validated**. Before adding management endpoints (Docker start/stop/restart are destructive actions), basic authentication is needed.

### Design

- **Phase 2 scope**: Simple shared-secret token authentication — a single API key configured in `appsettings.json`
- **Future scope** (Phase 3+): Multi-user with JWT, roles, etc.
- Configuration: `Auth__ApiToken` in `appsettings.json`
- Middleware approach:
  - For `GET` requests (hardware status): token is **optional** (read-only, no risk)
  - For `POST/PUT/DELETE` requests (Docker actions): token is **required**, return 401 if missing/invalid

### Tasks

#### S1. Create Auth Middleware
- `ServerEntry.ApiServer/Middleware/ApiTokenMiddleware.cs`
  - Skips `GET`/`HEAD`/`OPTIONS` requests
  - Validates `?token=` or `Authorization: Bearer <token>` header
  - Returns 401 JSON on failure

#### S2. Register Middleware
- Wire into `Program.cs` pipeline

#### S3. Dashboard Auth Config
- Add `apiToken` field to `ApiConfig`
- Dashboard reads token from local storage (or build-time config)
- Append token to all non-GET API requests

---

## Project Structure After Phase 2

```
ServerEntry.sln
├── ServerEntry.ApiServer/          # ASP.NET Core API
│   ├── Controllers/V1/
│   │   ├── HardwareStatus.cs       # CPU/RAM/Disk endpoints
│   │   └── DockerController.cs     # NEW: Docker management
│   ├── Middleware/
│   │   └── ApiTokenMiddleware.cs   # NEW: Auth middleware
│   └── Program.cs
├── ServerEntry.Shared/             # Shared models
│   ├── Docker/                     # NEW: Docker-related models
│   │   ├── ContainerInfo.cs
│   │   └── ContainerDetail.cs
│   ├── Hardware/                   # Existing hardware models
│   └── Service/                    # Monitor/status models
├── ServerEntry.Data/
│   ├── ServerEntry.Data.DbAdapter/ # NEW: Abstract interfaces
│   │   ├── IDbConnection.cs
│   │   ├── IRepository.cs
│   │   └── IDatabaseSettings.cs
│   ├── ServerEntry.Data.MongoDbAdapter/  # NEW: MongoDB implementation
│   │   ├── MongoDbConnection.cs
│   │   ├── MongoRepository.cs
│   │   └── ServiceCollectionExtensions.cs
│   ├── ServerEntry.Data.Hardware/  # Existing + disk monitor
│   │   ├── Processors/
│   │   ├── Memories/
│   │   └── Services/
│   │       └── HardwareMonitors/
│   │           ├── CpuUsageMonitor.cs    # Modified: optional DB persistence
│   │           └── DiskUsageMonitor.cs   # NEW
│   └── ServerEntry.Data.Docker/    # NEW: Docker API client
│       └── DockerClient.cs
├── ServerEntry.Dashboard/
│   └── server_entry_dashboard/
│       └── lib/
│           ├── pages/
│           │   ├── home_page.dart       # Modified: add disk widget
│           │   └── docker_page.dart     # NEW
│           └── widgets/
│               ├── home/
│               │   ├── cpu_info.dart
│               │   ├── ram_info.dart
│               │   └── disk_info.dart   # NEW
│               └── docker/             # NEW
│                   ├── container_list.dart
│                   ├── container_card.dart
│                   └── container_logs.dart
└── docker-compose.yml              # NEW: local dev environment
```

---

## Implementation Sequence

```
Week 1  ████████░░░░░░░░░░░░  Track A:  Disk Monitoring        (easiest, completes hardware story)
Week 1  ████████░░░░░░░░░░░░  Track B:  DB Interfaces           (unblocks MongoDB adapter)
Week 2  ████████████░░░░░░░░  Track B:  MongoDB Adapter         (persistence ready)
Week 2  ██████████████░░░░░░  Cross:   Auth Middleware          (blocks Docker POST endpoints)
Week 3  ██████████████████░░  Track C:  Docker API Client       (core logic)
Week 3  ████████████████████  Track C:  Docker Controller + UI  (end-to-end)
Week 4  ████████████████████  Polish:  i18n, error handling, testing, docs
```

### Why This Order?

1. **Disk monitoring first** — fully contained, no dependencies, immediate visible progress
2. **DB layer second** — needed for historical data; the MonitorBase → IRepository integration is designed here before Docker management adds more state
3. **Auth before destructive endpoints** — shipping Docker start/stop without auth would be irresponsible
4. **Docker management last** — depends on auth, benefits from DB layer for event logging

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Docker socket access from within container may have permission issues | Document `--group-add $(getent group docker | cut -d: -f3)` or `--user root`; provide clear error messages |
| MongoDB adds deployment complexity | Make it entirely optional; all features work without it (in-memory fallback) |
| Flutter web performance with many container cards | Lazy-load via `ListView.builder`, paginate logs |
| Security: Docker socket access means container escape risk | Auth middleware is mandatory for POST; document that Docker socket mount = trusted environment |

---

## Success Criteria

1. Dashboard shows CPU + RAM + **Disk** information with real-time updates
2. MongoDB can be optionally configured; when available, historical hardware data is persisted and queryable
3. API token auth protects all mutating endpoints
4. Docker container list, inspect, logs, start, stop, restart work end-to-end from dashboard
5. All existing Phase 1 functionality continues to work without regressions
6. Docker image builds and runs successfully with the new features
