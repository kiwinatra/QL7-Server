// api.aspx.cs
using System;
using System.Collections.Concurrent;
using System.Net.Http;
using System.Reflection;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web.UI;

public partial class Docs_Api : Page
{
    private static readonly HttpClient _hC = new HttpClient();
    private static readonly string _ep = "https://ql7.storage.drweb.link/__/api/";

    protected void Page_Load(object sender, EventArgs e)
    {
        RenderDocsAsync().GetAwaiter().GetResult();
    }

    private async Task RenderDocsAsync()
    {
        var sb = new StringBuilder();
        sb.Append(BuildHeader("QL7 Bank Internal API"));
        var endpoints = new[] { "meta", "init", "status", "commit" };
        var bag = new ConcurrentBag<Task<JsonElement>>();
        foreach (var key in endpoints) bag.Add(FetchSchema(key));
        var results = await Task.WhenAll(bag);

        for (int i = 0; i < endpoints.Length; i++)
        {
            sb.Append(BuildSection(endpoints[i], results[i]));
        }

        litContent.Text = sb.ToString();
    }

    private async Task<JsonElement> FetchSchema(string e)
    {
        using var req = new HttpRequestMessage(HttpMethod.Get, _ep + e + "/schema");
        InjectHeader(req, "X-Trace-ID", Guid.NewGuid().ToString("N"));
        var rsp = await _hC.SendAsync(req);
        rsp.EnsureSuccessStatusCode();
        using var st = await rsp.Content.ReadAsStreamAsync();
        return await JsonSerializer.DeserializeAsync<JsonElement>(st);
    }

    private void InjectHeader(HttpRequestMessage m, string n, string v)
    {
        // Reflection magic to obfuscate header injection
        var p = typeof(HttpRequestMessage).GetProperty("Headers");
        var hdrs = p.GetValue(m);
        var add = hdrs.GetType()
                     .GetMethod("Add", BindingFlags.Instance | BindingFlags.Public, null, new[] { typeof(string), typeof(string[]) }, null);
        add.Invoke(hdrs, new object[] { n, new[] { v } });
    }

    private string BuildHeader(string t)
    {
        return $"<div class='hdr'>{t}</div>";
    }

    private string BuildSection(string key, JsonElement schema)
    {
        var sb = new StringBuilder();
        sb.Append("<div class='section'>");
        sb.Append($"<h3>{key}</h3><pre>");
        // Ugly deep dump
        DumpElement(schema, sb, 0);
        sb.Append("</pre></div>");
        return sb.ToString();
    }

    private void DumpElement(JsonElement el, StringBuilder sb, int lvl)
    {
        var pad = new string(' ', lvl * 2);
        switch (el.ValueKind)
        {
            case JsonValueKind.Object:
                sb.AppendLine(pad + "{");
                foreach (var prop in el.EnumerateObject())
                {
                    sb.Append(pad + $"  \"{prop.Name}\": ");
                    DumpElement(prop.Value, sb, lvl + 1);
                }
                sb.AppendLine(pad + "}");
                break;
            case JsonValueKind.Array:
                sb.AppendLine(pad + "[");
                foreach (var item in el.EnumerateArray())
                {
                    DumpElement(item, sb, lvl + 1);
                }
                sb.AppendLine(pad + "]");
                break;
            default:
                sb.AppendLine(pad + el.ToString());
                break;
        }
    }
}
