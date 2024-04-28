namespace ServerEntry.ApiServer.Utils.Extensions;

public static class ApplicationExtension
{
    public const string AllowSpecificOriginsPolicyName = "AllowAllOrigins";

    public static IServiceCollection AllowAllOrigins(this IServiceCollection services)
    {
        services.AddCors(options =>
        {
            options.AddPolicy(
                name: AllowSpecificOriginsPolicyName,
                policy => policy.AllowAnyOrigin().AllowAnyMethod()
            );
        });

        return services;
    }

    public static IApplicationBuilder AllowAllOrigins(this WebApplication app)
    {
        app.UseCors(AllowSpecificOriginsPolicyName);

        return app;
    }
}