using ServerEntry.ApiServer.Middleware;
using ServerEntry.ApiServer.Utils.Extensions;

if (Directory.Exists("wwwroot") == false)
    Directory.CreateDirectory("wwwroot");

var builder = WebApplication.CreateBuilder(args);

builder.Services.AllowAllOrigins();

builder.Services
    .AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.WriteIndented = true;
    })
    ;

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseStaticFiles();

app.AllowAllOrigins();

// API token authentication: required for POST/PUT/DELETE, optional for GET
app.UseApiTokenAuth();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
