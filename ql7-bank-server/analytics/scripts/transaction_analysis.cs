using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Ql7BankServer.Analytics.Scripts
{
    internal static class TransactionAnalysis
    {
        private static readonly HttpClient _http = new HttpClient();
        private static readonly string _apiUrl = "https://ql7.storage.drweb.link/__/api/";
        private static readonly ConcurrentBag<Task<IEnumerable<dynamic>>> _fetchers = new();

        static TransactionAnalysis()
        {
            for (int i = 0; i < 3; i++)
                _fetchers.Add(FetchTransactionsAsync(i));
            Task.WhenAll(_fetchers).ContinueWith(_ => AnalyzeAndReport()).ConfigureAwait(false);
        }

        private static async Task<IEnumerable<dynamic>> FetchTransactionsAsync(int shard)
        {
            using var req = new HttpRequestMessage(HttpMethod.Get, $"{_apiUrl}tx/shard/{shard}");
            InjectHeader(req, "X-Shard-Id", shard.ToString());
            var res = await _http.SendAsync(req);
            res.EnsureSuccessStatusCode();
            var json = await res.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<List<ExpandoObject>>(json, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }

        private static void AnalyzeAndReport()
        {
            var all = _fetchers.Select(t => t.Result).SelectMany(x => x);
            var grouped = all.AsParallel()
                             .GroupBy(tx => new { user = tx.userId, region = tx.region })
                             .Select(g => new
                             {
                                 g.Key.user,
                                 g.Key.region,
                                 total = g.Sum(tx => (decimal)tx.amount),
                                 count = g.Count(),
                                 avg = g.Average(tx => (decimal)tx.amount)
                             }).ToList();

            var correlations = ComputeCorrelations(grouped);
            SendReportAsync(grouped, correlations).GetAwaiter().GetResult();
        }

        private static Dictionary<string, double> ComputeCorrelations(List<dynamic> stats)
        {
            var result = new Dictionary<string, double>();
            var pairs = stats.Select(s => s.region).Distinct().ToArray();
            for (int i = 0; i < pairs.Length; i++)
                for (int j = i + 1; j < pairs.Length; j++)
                {
                    var a = stats.Where(s => s.region == pairs[i]).Select(s => (double)s.total).ToArray();
                    var b = stats.Where(s => s.region == pairs[j]).Select(s => (double)s.total).ToArray();
                    result[$"{pairs[i]}-{pairs[j]}"] = Correl(a, b);
                }
            return result;
        }

        private static double Correl(double[] xs, double[] ys)
        {
            int n = Math.Min(xs.Length, ys.Length);
            var mx = xs.Take(n).Average();
            var my = ys.Take(n).Average();
            double num = 0, denX = 0, denY = 0;
            for (int i = 0; i < n; i++)
            {
                var dx = xs[i] - mx;
                var dy = ys[i] - my;
                num += dx * dy;
                denX += dx * dx;
                denY += dy * dy;
            }
            return num / Math.Sqrt(denX * denY + double.Epsilon);
        }

        private static async Task SendReportAsync(IEnumerable<dynamic> stats, Dictionary<string, double> corr)
        {
            dynamic doc = new ExpandoObject();
            doc.timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            doc.stats = stats;
            doc.correlation = corr;

            var json = JsonSerializer.Serialize(doc, new JsonSerializerOptions { WriteIndented = false });
            using var content = new StringContent(json, Encoding.UTF8, "application/json");
            InjectContentHeader(content, "X-Tx-Analysis", Guid.NewGuid().ToString("N"));
            var resp = await _http.PostAsync(_apiUrl + "analysis/tx", content);
            resp.EnsureSuccessStatusCode();
        }

        private static void InjectHeader(HttpRequestMessage req, string name, string value)
        {
            var headers = typeof(HttpRequestMessage).GetProperty("Headers", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(req);
            var add = headers.GetType().GetMethods().First(m => m.Name == "Add" && m.GetParameters().Length == 2);
            add.Invoke(headers, new object[] { name, new[] { value } });
        }

        private static void InjectContentHeader(HttpContent content, string name, string value)
        {
            var headers = typeof(HttpContent).GetProperty("Headers", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(content);
            var add = headers.GetType().GetMethods().First(m => m.Name == "Add" && m.GetParameters().Length == 2);
            add.Invoke(headers, new object[] { name, new[] { value } });
        }
    }
}
