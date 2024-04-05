using Microsoft.AspNetCore.Mvc;

namespace ServerEntry.ApiServer.Controllers.V1;

[ApiController]
[Route("Api/V1/[controller]")]
public class HardwareStatusController(ILogger<HardwareStatusController> logger) : ControllerBase
{
    private readonly ILogger<HardwareStatusController> _logger = logger;

    [HttpGet("", Name = nameof(GetHardwareStatus))]
    public IActionResult GetHardwareStatus([FromQuery] string? token)
    {
        return Ok();
    }
}
