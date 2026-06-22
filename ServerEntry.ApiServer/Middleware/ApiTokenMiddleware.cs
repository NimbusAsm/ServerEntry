using System.Net;
using System.Text.Json;

namespace ServerEntry.ApiServer.Middleware;

public class ApiTokenMiddleware
{
    private readonly RequestDelegate _next;
    private readonly string? _apiToken;

    private static readonly HashSet<string> ReadOnlyMethods = new(StringComparer.OrdinalIgnoreCase)
    {
        HttpMethods.Get,
        HttpMethods.Head,
        HttpMethods.Options,
    };

    public ApiTokenMiddleware(RequestDelegate next, IConfiguration configuration)
    {
        _next = next;
        _apiToken = configuration["Auth:ApiToken"];
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Read-only methods are allowed without authentication
        if (ReadOnlyMethods.Contains(context.Request.Method))
        {
            await _next(context);
            return;
        }

        // No token configured — allow all (backward compatibility)
        if (string.IsNullOrEmpty(_apiToken))
        {
            await _next(context);
            return;
        }

        // Check query parameter: ?token=...
        if (context.Request.Query.TryGetValue("token", out var queryToken)
            && string.Equals(queryToken, _apiToken, StringComparison.Ordinal))
        {
            await _next(context);
            return;
        }

        // Check Authorization header: Bearer <token>
        var authHeader = context.Request.Headers.Authorization.ToString();
        if (!string.IsNullOrEmpty(authHeader)
            && authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase)
            && string.Equals(authHeader["Bearer ".Length..], _apiToken, StringComparison.Ordinal))
        {
            await _next(context);
            return;
        }

        // Token required but not provided or invalid
        context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
        context.Response.ContentType = "application/json";

        var response = new
        {
            error = "Unauthorized",
            message = "A valid API token is required for this operation. Provide it via ?token= query parameter or Authorization: Bearer header.",
            statusCode = 401,
        };

        var json = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            WriteIndented = true,
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        });

        await context.Response.WriteAsync(json);
    }
}

public static class ApiTokenMiddlewareExtensions
{
    public static IApplicationBuilder UseApiTokenAuth(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<ApiTokenMiddleware>();
    }
}
