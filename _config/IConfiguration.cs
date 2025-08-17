var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("_config/csharp.conf"); 

var corsAllowedOrigins = builder.Configuration.GetSection("CorsSettings:AllowedOrigins").Get<string[]>();
var dbConnectionString = ConfigurationManager.ConnectionStrings["DefaultDatabase"].ConnectionString;