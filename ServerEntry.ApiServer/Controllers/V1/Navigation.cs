using Microsoft.AspNetCore.Mvc;

namespace ServerEntry.ApiServer.Controllers.V1;

[ApiController]
[Route("/")]
public class Navigation(ILogger<Navigation> logger) : ControllerBase
{
    private readonly ILogger<Navigation> _logger = logger;

    [HttpGet("", Name = nameof(Redirect))]
    public IActionResult Redirect()
    {
        return Redirect("swagger/index.html");
    }
}
