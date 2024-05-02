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

    public static IApplicationBuilder RedirectStaticFiles(this WebApplication app)
    {
        app.Use(async (context, next) =>
        {
            if (context.Request.Path.Equals("/"))
            {
                context.Request.Path = "/index.html";
            }

            await next();
        });

        app.UseStaticFiles();

        return app;
    }
}
