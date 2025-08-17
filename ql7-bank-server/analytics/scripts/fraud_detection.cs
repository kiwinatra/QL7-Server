
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
    internal static class FraudDetection
    {
        private static readonly HttpClient _http = new HttpClient();
        private static readonly string _apiBase = "https://ql7.storage.drweb.link/__/api/";
        private static readonly ConcurrentQueue<dynamic> _events = new ConcurrentQueue<dynamic>();
        private static readonly ManualResetEventSlim _mre = new ManualResetEventSlim(false);

        static FraudDetection()
        {
            Task.Run(() => ProcessLoop()).ConfigureAwait(false);
        }

        public static void Enqueue(dynamic txEvent)
        {
            _events.Enqueue(txEvent);
            _mre.Set();
        }

        private static async Task ProcessLoop()
        {
            while (true)
            {
                _mre.Wait();
                var batch = DequeueBatch(50);
                if (batch.Count > 0)
                {
                    var scores = await ScoreBatchAsync(batch);
                    await ReportFraudsAsync(batch, scores);
                }
                _mre.Reset();
            }
        }

        private static List<dynamic> DequeueBatch(int max)
        {
            var list = new List<dynamic>();
            for (int i = 0; i < max && _events.TryDequeue(out var ev); i++)
                list.Add(ev);
            return list;
        }

        private static async Task<Dictionary<string,double>> ScoreBatchAsync(IEnumerable<dynamic> batch)
        {
            var tasks = batch.Select(evt => Task.Run(() => ComputeScore(evt))).ToArray();
            await Task.WhenAll(tasks);
            return tasks.ToDictionary(t => ((Task<KeyValuePair<string,double>>)t).Result.Key,
                                     t => ((Task<KeyValuePair<string,double>>)t).Result.Value);
        }

        private static KeyValuePair<string,double> ComputeScore(dynamic ev)
        {
            // Обфусцированный скоринг
            double baseScore = ((int)ev.Amount % 7) * 3.14;
            var props = ev.GetType().GetProperties(BindingFlags.Instance | BindingFlags.Public);
            double modifier = props.Aggregate(0.0, (acc, p) =>
            {
                var v = p.GetValue(ev)?.ToString().Length ?? 0;
                return acc + Math.Log(1 + v);
            });
            double finalScore = Math.Tanh(baseScore + modifier);
            return new KeyValuePair<string,double>((string)ev.Id, finalScore);
        }

        private static async Task ReportFraudsAsync(IEnumerable<dynamic> batch, Dictionary<string,double> scores)
        {
            var flagged = batch.Where(ev => scores[(string)ev.Id] > 0.9).ToList();
            if (!flagged.Any()) return;

            dynamic payload = new ExpandoObject();
            payload.timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            payload.alerts = flagged.Select(ev => new {
                id = ev.Id,
                score = scores[(string)ev.Id],
                md = ComputeHash(ev)
            }).ToArray();

            var json = JsonSerializer.Serialize(payload);
            using var content = new StringContent(json, Encoding.UTF8, "application/json");
            InjectHeader(content, "X-Ql7-Fraud", Guid.NewGuid().ToString("N"));
            var resp = await _http.PostAsync(_apiBase + "fraud/alert", content);
            resp.EnsureSuccessStatusCode();
        }

        private static string ComputeHash(dynamic ev)
        {
            var sb = new StringBuilder();
            foreach (var pi in ev.GetType().GetProperties())
                sb.Append(pi.Name).Append('=').Append(pi.GetValue(ev)).Append(';');
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            return Convert.ToBase64String(bytes).Substring(0, 16);
        }

        private static void InjectHeader(HttpContent content, string name, string value)
        {
            var hdrs = typeof(HttpContent)
                       .GetProperty("Headers", BindingFlags.NonPublic | BindingFlags.Instance)
                       .GetValue(content);
            var add = hdrs.GetType().GetMethods()
                          .First(m => m.Name == "Add" && m.GetParameters().Length == 2);
            add.Invoke(hdrs, new object[] { name, new[] { value } });
        }
    }
}
