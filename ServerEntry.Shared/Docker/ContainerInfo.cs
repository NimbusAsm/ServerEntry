using System.Text.Json.Serialization;

namespace ServerEntry.Shared.Docker;

public class ContainerInfo
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("image")]
    public string Image { get; set; } = string.Empty;

    [JsonPropertyName("state")]
    public string State { get; set; } = string.Empty;

    [JsonPropertyName("status")]
    public string Status { get; set; } = string.Empty;

    [JsonPropertyName("created")]
    public DateTime Created { get; set; }

    [JsonPropertyName("ports")]
    public IEnumerable<PortMapping> Ports { get; set; } = [];

    public string DisplayName => Name.StartsWith('/') ? Name[1..] : Name;

    public bool IsRunning => string.Equals(State, "running", StringComparison.OrdinalIgnoreCase);
}

public class PortMapping
{
    [JsonPropertyName("ip")]
    public string Ip { get; set; } = string.Empty;

    [JsonPropertyName("privatePort")]
    public int PrivatePort { get; set; }

    [JsonPropertyName("publicPort")]
    public int? PublicPort { get; set; }

    [JsonPropertyName("type")]
    public string Type { get; set; } = string.Empty;
}

public class ContainerDetail
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("image")]
    public string Image { get; set; } = string.Empty;

    [JsonPropertyName("state")]
    public ContainerState? StateInfo { get; set; }

    [JsonPropertyName("config")]
    public ContainerConfig? Config { get; set; }

    [JsonPropertyName("hostConfig")]
    public HostConfig? HostConfig { get; set; }

    [JsonPropertyName("networkSettings")]
    public NetworkSettings? NetworkSettings { get; set; }

    [JsonPropertyName("mounts")]
    public IEnumerable<MountInfo> Mounts { get; set; } = [];

    [JsonPropertyName("created")]
    public DateTime Created { get; set; } = DateTime.UnixEpoch;
}

public class ContainerState
{
    [JsonPropertyName("status")]
    public string Status { get; set; } = string.Empty;

    [JsonPropertyName("running")]
    public bool Running { get; set; }

    [JsonPropertyName("startedAt")]
    public DateTime StartedAt { get; set; }

    [JsonPropertyName("finishedAt")]
    public DateTime FinishedAt { get; set; }

    [JsonPropertyName("exitCode")]
    public int ExitCode { get; set; }
}

public class ContainerConfig
{
    [JsonPropertyName("hostname")]
    public string Hostname { get; set; } = string.Empty;

    [JsonPropertyName("env")]
    public IEnumerable<string> Env { get; set; } = [];

    [JsonPropertyName("image")]
    public string Image { get; set; } = string.Empty;

    [JsonPropertyName("labels")]
    public Dictionary<string, string>? Labels { get; set; }
}

public class HostConfig
{
    [JsonPropertyName("restartPolicy")]
    public RestartPolicy? RestartPolicy { get; set; }

    [JsonPropertyName("memory")]
    public long Memory { get; set; }

    [JsonPropertyName("cpuShares")]
    public long CpuShares { get; set; }
}

public class RestartPolicy
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("maximumRetryCount")]
    public int MaximumRetryCount { get; set; }
}

public class NetworkSettings
{
    [JsonPropertyName("networks")]
    public Dictionary<string, NetworkInfo>? Networks { get; set; }

    [JsonPropertyName("ipAddress")]
    public string? IpAddress { get; set; }
}

public class NetworkInfo
{
    [JsonPropertyName("ipAddress")]
    public string? IpAddress { get; set; }

    [JsonPropertyName("gateway")]
    public string? Gateway { get; set; }
}

public class MountInfo
{
    [JsonPropertyName("source")]
    public string Source { get; set; } = string.Empty;

    [JsonPropertyName("destination")]
    public string Destination { get; set; } = string.Empty;

    [JsonPropertyName("type")]
    public string Type { get; set; } = string.Empty;

    [JsonPropertyName("mode")]
    public string Mode { get; set; } = string.Empty;
}
