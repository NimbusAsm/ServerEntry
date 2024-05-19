using Microsoft.AspNetCore.Mvc;

namespace ServerEntry.ApiServer.Controllers.V1;

[ApiController]
[Route("")]
public class DashboardNavigation(ILogger<DashboardNavigation> logger) : ControllerBase
{
    private readonly ILogger<DashboardNavigation> _logger = logger;

    [HttpGet("", Name = nameof(RedirectToDashboard))]
    public IActionResult RedirectToDashboard()
    {
        return Redirect("index.html");
    }
}

[ApiController]
[Route("Api")]
public class ApiDocNavigation(ILogger<ApiDocNavigation> logger) : ControllerBase
{
    private readonly ILogger<ApiDocNavigation> _logger = logger;

    [HttpGet("", Name = nameof(RedirectToSwaggerApiDoc))]
    public IActionResult RedirectToSwaggerApiDoc()
    {
        return Redirect("swagger/index.html");
    }
}
