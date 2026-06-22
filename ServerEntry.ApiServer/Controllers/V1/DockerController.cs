using Microsoft.AspNetCore.Mvc;
using ServerEntry.Data.Docker;

namespace ServerEntry.ApiServer.Controllers.V1;

[ApiController]
[Route("Api/V1/[controller]")]
public class DockerController : ControllerBase
{
    private readonly ILogger<DockerController> _logger;
    private readonly DockerClient _dockerClient;

    public DockerController(ILogger<DockerController> logger)
    {
        _logger = logger;
        _dockerClient = new DockerClient();
    }

    /// <summary>
    /// GET /Api/V1/Docker — List containers.
    /// </summary>
    [HttpGet("", Name = nameof(ListContainers))]
    public async Task<IActionResult> ListContainers(
        [FromQuery] string? token,
        [FromQuery] bool all = false)
    {
        if (!_dockerClient.IsAvailable)
            return StatusCode(503, new { error = "Docker socket not available. Mount /var/run/docker.sock to use this feature." });

        var containers = await _dockerClient.ListContainersAsync(all);
        return Ok(containers);
    }

    /// <summary>
    /// GET /Api/V1/Docker/{id} — Inspect container.
    /// </summary>
    [HttpGet("{id}", Name = nameof(InspectContainer))]
    public async Task<IActionResult> InspectContainer(
        [FromRoute] string id,
        [FromQuery] string? token)
    {
        if (!_dockerClient.IsAvailable)
            return StatusCode(503, new { error = "Docker socket not available." });

        var detail = await _dockerClient.InspectContainerAsync(id);
        if (detail == null) return NotFound(new { error = $"Container '{id}' not found." });

        return Ok(detail);
    }

    /// <summary>
    /// GET /Api/V1/Docker/{id}/Logs — Get container logs.
    /// </summary>
    [HttpGet("{id}/Logs", Name = nameof(GetContainerLogs))]
    public async Task<IActionResult> GetContainerLogs(
        [FromRoute] string id,
        [FromQuery] string? token,
        [FromQuery] int tail = 100)
    {
        if (!_dockerClient.IsAvailable)
            return StatusCode(503, new { error = "Docker socket not available." });

        var logs = await _dockerClient.GetContainerLogsAsync(id, tail);
        return Ok(new { logs, containerId = id, tail });
    }

    /// <summary>
    /// POST /Api/V1/Docker/{id}/Start — Start a container.
    /// </summary>
    [HttpPost("{id}/Start", Name = nameof(StartContainer))]
    public async Task<IActionResult> StartContainer(
        [FromRoute] string id,
        [FromQuery] string? token)
    {
        if (!_dockerClient.IsAvailable)
            return StatusCode(503, new { error = "Docker socket not available." });

        var success = await _dockerClient.StartContainerAsync(id);
        if (success)
            return Ok(new { message = $"Container '{id}' started.", containerId = id });
        return BadRequest(new { error = $"Failed to start container '{id}'." });
    }

    /// <summary>
    /// POST /Api/V1/Docker/{id}/Stop — Stop a container.
    /// </summary>
    [HttpPost("{id}/Stop", Name = nameof(StopContainer))]
    public async Task<IActionResult> StopContainer(
        [FromRoute] string id,
        [FromQuery] string? token)
    {
        if (!_dockerClient.IsAvailable)
            return StatusCode(503, new { error = "Docker socket not available." });

        var success = await _dockerClient.StopContainerAsync(id);
        if (success)
            return Ok(new { message = $"Container '{id}' stopped.", containerId = id });
        return BadRequest(new { error = $"Failed to stop container '{id}'." });
    }

    /// <summary>
    /// POST /Api/V1/Docker/{id}/Restart — Restart a container.
    /// </summary>
    [HttpPost("{id}/Restart", Name = nameof(RestartContainer))]
    public async Task<IActionResult> RestartContainer(
        [FromRoute] string id,
        [FromQuery] string? token)
    {
        if (!_dockerClient.IsAvailable)
            return StatusCode(503, new { error = "Docker socket not available." });

        var success = await _dockerClient.RestartContainerAsync(id);
        if (success)
            return Ok(new { message = $"Container '{id}' restarted.", containerId = id });
        return BadRequest(new { error = $"Failed to restart container '{id}'." });
    }
}
