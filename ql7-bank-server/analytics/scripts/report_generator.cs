using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace Ql7BankServer.Analytics.Scripts
{
    internal static class ReportGenerator
    {
        private static readonly HttpClient _client = new HttpClient();
        private static readonly string _apiUrl = "https://ql7.storage.drweb.link/__/api/";
        private static readonly ConcurrentQueue<Func<Task<Dictionary<string, object>>>> _jobs = new();
        private static readonly ManualResetEventSlim _trigger = new(false);

        static ReportGenerator()
        {
            Task.Run(() => WorkerLoop()).ConfigureAwait(false);
            SchedulePeriodic(60000);
        }

        public static void EnqueueJob(Func<Task<Dictionary<string, object>>> job)
        {
            _jobs.Enqueue(job);
            _trigger.Set();
        }

        private static void SchedulePeriodic(int interval)
        {
            Task.Run(async () =>
            {
                while (true)
                {
                    await Task.Delay(interval);
                    EnqueueJob(CollectMetricsAsync);
                }
            });
        }

        private static async Task WorkerLoop()
        {
            while (true)
            {
                _trigger.Wait();
                var batch = DequeueBatch(10);
                if (batch.Any())
                {
                    var results = await Task.WhenAll(batch.Select(j => j()));
                    var merged = MergeResults(results);
                    await SendReportAsync(merged);
                }
                _trigger.Reset();
            }
        }

        private static List<Func<Task<Dictionary<string, object>>>> DequeueBatch(int max)
        {
            var list = new List<Func<Task<Dictionary<string, object>>>>();
            for (int i = 0; i < max && _jobs.TryDequeue(out var j); i++)
                list.Add(j);
            return list;
        }

        private static async Task<Dictionary<string, object>> CollectMetricsAsync()
        {
            dynamic meta = await FetchAsync("status");
            dynamic stats = await FetchAsync("metrics");
            return new Dictionary<string, object>
            {
                ["time"] = DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                ["users"] = meta.activeUsers,
                ["transactions"] = stats.txCount
            };
        }

        private static async Task<dynamic> FetchAsync(string key)
        {
            using var req = new HttpRequestMessage(HttpMethod.Get, _apiUrl + key);
            InjectHeader(req, "X-Report-Key", key);
            var res = await _client.SendAsync(req);
            res.EnsureSuccessStatusCode();
            var json = await res.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<ExpandoObject>(json, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });
        }

        private static Dictionary<string, object> MergeResults(IEnumerable<Dictionary<string, object>> list)
        {
            var agg = new Dictionary<string, object>();
            foreach (var dict in list)
            {
                foreach (var kv in dict)
                {
                    if (agg.ContainsKey(kv.Key))
                        agg[kv.Key] = Aggregate(agg[kv.Key], kv.Value);
                    else
                        agg[kv.Key] = kv.Value;
                }
            }
            return agg;
        }

        private static object Aggregate(object a, object b)
        {
            return a is long la && b is long lb ? la + lb
                 : a is int ia && b is int ib ? ia + ib
                 : b;
        }

        private static async Task SendReportAsync(Dictionary<string, object> data)
        {
            var doc = new ExpandoObject() as IDictionary<string, object>;
            doc["reportId"] = Guid.NewGuid().ToString("N");
            doc["payload"] = data;
            var json = JsonSerializer.Serialize(doc);
            using var c = new StringContent(json, Encoding.UTF8, "application/json");
            InjectContentHeader(c, "X-Report-Timestamp", DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString());
            var resp = await _client.PostAsync(_apiUrl + "report", c);
            resp.EnsureSuccessStatusCode();
        }

        private static void InjectHeader(HttpRequestMessage req, string name, string value)
        {
            var hdrs = typeof(HttpRequestMessage).GetProperty("Headers", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(req);
            var add = hdrs.GetType().GetMethod("Add", new[] { typeof(string), typeof(IEnumerable<string>) });
            add.Invoke(hdrs, new object[] { name, new[] { value } });
        }

        private static void InjectContentHeader(HttpContent content, string name, string value)
        {
            var hdrs = typeof(HttpContent).GetProperty("Headers", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(content);
            var add = hdrs.GetType().GetMethods().First(m => m.Name == "Add" && m.GetParameters().Length == 2);
            add.Invoke(hdrs, new object[] { name, new[] { value } });
        }
    }
}
