var AllowSpecificOriginsPolicyName = "AllowAllOrigins";

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy(
        AllowSpecificOriginsPolicyName,
        policy => policy.AllowAnyOrigin().AllowAnyMethod()
    );
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Even in production environment, provides swagger api document unless user turn it off
app.UseSwagger();
app.UseSwaggerUI();

app.UseCors(AllowSpecificOriginsPolicyName);

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
