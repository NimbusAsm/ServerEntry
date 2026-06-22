using System.Net.Sockets;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.Json;
using ServerEntry.Shared.Docker;

[assembly: InternalsVisibleTo("ServerEntry.ApiServer")]

namespace ServerEntry.Data.Docker;

public class DockerClient : IDisposable
{
    private readonly HttpClient _httpClient;

    private const string DefaultSocketPath = "/var/run/docker.sock";

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
    };

    public bool IsAvailable { get; }

    public DockerClient(string socketPath = DefaultSocketPath)
    {
        if (!File.Exists(socketPath))
        {
            IsAvailable = false;
            _httpClient = new HttpClient(); // dummy — won't be used
            return;
        }

        IsAvailable = true;

        var handler = new SocketsHttpHandler
        {
            ConnectCallback = async (context, cancellationToken) =>
            {
                var socket = new Socket(AddressFamily.Unix, SocketType.Stream, ProtocolType.Unspecified);
                var endpoint = new UnixDomainSocketEndPoint(socketPath);
                await socket.ConnectAsync(endpoint, cancellationToken);
                return new NetworkStream(socket, ownsSocket: true);
            },
            PooledConnectionLifetime = TimeSpan.FromMinutes(2),
        };

        _httpClient = new HttpClient(handler)
        {
            BaseAddress = new Uri("http://localhost"),
            Timeout = TimeSpan.FromSeconds(30),
        };
    }

    /// <summary>
    /// GET /containers/json — List all containers.
    /// </summary>
    public async Task<IEnumerable<ContainerInfo>> ListContainersAsync(bool all = false, CancellationToken ct = default)
    {
        if (!IsAvailable) return [];

        var url = $"/containers/json?all={all.ToString().ToLowerInvariant()}&size=true";
        var response = await _httpClient.GetAsync(url, ct);
        response.EnsureSuccessStatusCode();

        var body = await response.Content.ReadAsStringAsync(ct);
        return JsonSerializer.Deserialize<IEnumerable<ContainerInfo>>(body, JsonOptions) ?? [];
    }

    /// <summary>
    /// GET /containers/{id}/json — Inspect a container.
    /// </summary>
    public async Task<ContainerDetail?> InspectContainerAsync(string id, CancellationToken ct = default)
    {
        if (!IsAvailable) return null;

        var url = $"/containers/{Uri.EscapeDataString(id)}/json";
        var response = await _httpClient.GetAsync(url, ct);
        response.EnsureSuccessStatusCode();

        var body = await response.Content.ReadAsStringAsync(ct);
        return JsonSerializer.Deserialize<ContainerDetail>(body, JsonOptions);
    }

    /// <summary>
    /// GET /containers/{id}/logs — Get container logs.
    /// </summary>
    public async Task<string> GetContainerLogsAsync(string id, int tail = 100, CancellationToken ct = default)
    {
        if (!IsAvailable) return string.Empty;

        var url = $"/containers/{Uri.EscapeDataString(id)}/logs?stdout=true&stderr=true&tail={tail}";
        var response = await _httpClient.GetAsync(url, ct);
        response.EnsureSuccessStatusCode();

        var rawBytes = await response.Content.ReadAsByteArrayAsync(ct);

        // Docker log stream format: [8 bytes header][frame data]
        // Header: [stream-type (1=stdout, 2=stderr)][3 zeros][4-byte big-endian length]
        return DecodeDockerLogStream(rawBytes);
    }

    /// <summary>
    /// POST /containers/{id}/start — Start a container.
    /// </summary>
    public async Task<bool> StartContainerAsync(string id, CancellationToken ct = default)
    {
        if (!IsAvailable) return false;

        var url = $"/containers/{Uri.EscapeDataString(id)}/start";
        var response = await _httpClient.PostAsync(url, null, ct);
        return response.IsSuccessStatusCode || response.StatusCode == System.Net.HttpStatusCode.NotModified;
    }

    /// <summary>
    /// POST /containers/{id}/stop — Stop a container.
    /// </summary>
    public async Task<bool> StopContainerAsync(string id, CancellationToken ct = default)
    {
        if (!IsAvailable) return false;

        var url = $"/containers/{Uri.EscapeDataString(id)}/stop";
        var response = await _httpClient.PostAsync(url, null, ct);
        return response.IsSuccessStatusCode || response.StatusCode == System.Net.HttpStatusCode.NotModified;
    }

    /// <summary>
    /// POST /containers/{id}/restart — Restart a container.
    /// </summary>
    public async Task<bool> RestartContainerAsync(string id, CancellationToken ct = default)
    {
        if (!IsAvailable) return false;

        var url = $"/containers/{Uri.EscapeDataString(id)}/restart";
        var response = await _httpClient.PostAsync(url, null, ct);
        return response.IsSuccessStatusCode;
    }

    /// <summary>
    /// Decodes the Docker multiplexed log stream format.
    /// Each frame: [1 byte stream type][3 bytes padding][4 bytes big-endian length][payload]
    /// </summary>
    private static string DecodeDockerLogStream(byte[] raw)
    {
        var sb = new StringBuilder();
        var offset = 0;

        while (offset + 8 <= raw.Length)
        {
            // Stream type: 1=stdout, 2=stderr
            var streamType = raw[offset];

            // Frame length is bytes 4-7 (big-endian uint32)
            var frameLength = (int)(
                (raw[offset + 4] << 24) |
                (raw[offset + 5] << 16) |
                (raw[offset + 6] << 8) |
                raw[offset + 7]);

            offset += 8;

            if (frameLength <= 0 || offset + frameLength > raw.Length) break;

            var frameData = raw.AsSpan(offset, frameLength);
            sb.Append(Encoding.UTF8.GetString(frameData));

            offset += frameLength;
        }

        return sb.ToString();
    }

    public void Dispose()
    {
        _httpClient.Dispose();
        GC.SuppressFinalize(this);
    }
}
