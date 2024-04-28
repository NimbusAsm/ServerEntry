using ServerEntry.ApiServer.Utils.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AllowAllOrigins();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.AllowAllOrigins();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
