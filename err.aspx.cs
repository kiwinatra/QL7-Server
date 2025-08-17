using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Ошибка : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                await ProcessErrorAsync();
            }));
        }
    }

    private async Task ProcessErrorAsync()
    {
        try
        {
            
            Exception ex = Server.GetLastError();
            
            if (ex != null)
            {
                
                Server.ClearError();
                
                
                await LogErrorAsync(ex);
                
               
                string errorType = "unknown";
                string errorCode = "500";
                
                if (ex is HttpException httpEx)
                {
                    errorCode = httpEx.GetHttpCode().ToString();
                    
                    switch (httpEx.GetHttpCode())
                    {
                        case 401:
                        case 403:
                            errorType = "auth";
                            break;
                        case 404:
                            errorType = "notfound";
                            break;
                        case 500:
                            errorType = "server";
                            break;
                    }
                }
                else if (ex is ApplicationException)
                {
                    errorType = "application";
                }
                
              
                ClientScript.RegisterStartupScript(GetType(), "SetErrorData", 
                    $@"document.getElementById('errorStackTrace').textContent = {ToJson(ex.ToString())};
                       document.getElementById('errorDetails').textContent += '\nВремя: {DateTime.Now.ToString("HH:mm:ss")}';", 
                    true);
                
                
                Response.Redirect($"/err.aspx?type={errorType}&code={errorCode}", false);
            }
        }
        catch (Exception loggingEx)
        {
            
            System.Diagnostics.Trace.TraceError($"Error in error handler: {loggingEx}");
        }
    }
    
    private async Task LogErrorAsync(Exception ex)
    {
        try
        {
            using (var db = new QL7DbContext())
            {
                db.ErrorLogs.Add(new ErrorLog {
                    Message = ex.Message,
                    StackTrace = ex.StackTrace,
                    OccurredAt = DateTime.Now,
                    UserId = User.Identity.IsAuthenticated ? GetUserId() : null
                });
                await db.SaveChangesAsync();
            }
            
        }
        catch
        {
            
        }
    }
    
    private string ToJson(string value)
    {
        return Newtonsoft.Json.JsonConvert.SerializeObject(value);
    }
    
    protected string GetErrorMessage()
    {
        Exception ex = Server.GetLastError();
        if (ex == null) return "Неизвестная ошибка";
        
        if (ex is HttpException httpEx)
        {
            return httpEx.GetHttpCode() == 404 
                ? "Страница не найдена" 
                : "Ошибка HTTP: " + httpEx.Message;
        }
        
        return ex.Message;
    }
    
    protected string GetErrorDetails()
    {
        Exception ex = Server.GetLastError();
        if (ex == null) return string.Empty;
        
        return ex.InnerException != null 
            ? ex.InnerException.Message 
            : string.Empty;
    }
    
    protected string GetErrorType()
    {
        Exception ex = Server.GetLastError();
        if (ex == null) return "unknown";
        
        if (ex is HttpException httpEx)
        {
            return httpEx.GetHttpCode() switch
            {
                401 or 403 => "auth",
                404 => "notfound",
                500 => "server",
                299 => "unaviable"
                _ => "http",
            };
        }
        
        return "application";
    }
}