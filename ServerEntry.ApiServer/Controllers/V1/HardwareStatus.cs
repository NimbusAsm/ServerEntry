using Microsoft.AspNetCore.Mvc;
using ServerEntry.Data.Hardware;

namespace ServerEntry.ApiServer.Controllers.V1;

[ApiController]
[Route("Api/V1/[controller]")]
public class HardwareStatusController(ILogger<HardwareStatusController> logger) : ControllerBase
{
    private readonly ILogger<HardwareStatusController> _logger = logger;

    [HttpGet("", Name = nameof(GetHardwareStatus))]
    public IActionResult GetHardwareStatus([FromQuery] string? token)
    {
        return Ok(HardwareStatusProvider.Instance.GetStatus());
    }

    [HttpGet("Processors", Name = nameof(GetProcessorsInfo))]
    public IActionResult GetProcessorsInfo([FromQuery] string? token)
    {
        return Ok(HardwareStatusProvider.Instance.GetProcessorInfos());
    }

    [HttpGet("Memory", Name = nameof(GetMemoryInfo))]
    public IActionResult GetMemoryInfo([FromQuery] string? token)
    {
        return Ok(HardwareStatusProvider.Instance.GetMemoryInfos());
    }
}
